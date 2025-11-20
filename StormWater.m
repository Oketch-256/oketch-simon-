% Storm Water Detention Basin Design and Simulation
% Inputs: Customize as needed
A = 100; % Watershed area in acres
C = 0.8; % Runoff coefficient
I = 5; % Rainfall intensity in in/hr (for 100-year, 24-hr storm)
target_peak_reduction = 0.1; % Target outflow peak as fraction of inflow peak
storm_duration = 24; % Hours
basin_depth = 10; % Fixed depth in ft

% Function to compute peak inflow
peak_inflow = rational_method(A, C, I); % cfs

% Design: Optimize storage volume and orifice diameter
objective = @(x) x(1); % Minimize volume (cost proxy)
constraints = @(x) design_constraints(x, peak_inflow, target_peak_reduction, basin_depth);
x0 = [1000, 1]; % Initial guess: volume (cu ft), orifice diam (ft)
lb = [100, 0.1]; ub = [1e5, 5];
options = optimoptions('fmincon', 'Display', 'iter');
[opt_params, fval] = fmincon(objective, x0, [], [], [], [], lb, ub, constraints, options);
storage_volume = opt_params(1);
orifice_diam = opt_params(2);

fprintf('Optimal Storage Volume: %.2f cu ft\n', storage_volume);
fprintf('Optimal Orifice Diameter: %.2f ft\n', orifice_diam);

% Simulation: Generate inflow hydrograph and simulate basin
t_sim = 0:0.1:storm_duration; % Time vector for simulation
t_hydrograph = 0:0.01:storm_duration; % separate time vector for hydrograph definiton

% Generate inflow hydrograph
inflow_rate = peak_inflow * (t_hydrograph / storm_duration) .* exp(1 - t_hydrograph / storm_duration); % Simplified triangular hydrograph

% define basin_ode as nested function to access variables
[~, outflow_depth] = ode45(@(t,y) basin_ode(t, y, inflow_rate, t_hydrograph, orifice_diam, storage_volume, basin_depth), t_sim, 0);

% Compute actual outflow rate for plotting
outflow_rate = (pi/4 * orifice_diam^2) * sqrt(2*32.2 * outflow_depth);

% Plot results
figure;
subplot(2,1,1); 
plot(t_hydrograph, inflow_rate); 
title('Inflow Hydrograph'); 
xlabel('Time (hr)'); 
ylabel('Flow (cfs)');
grid on;

subplot(2,1,2); 
plot(t_sim, outflow_rate); 
title('Outflow Hydrograph'); 
xlabel('Time (hr)'); 
ylabel('Flow (cfs)');
grid on;

% Add performance metrics
peak_outflow = max(outflow_rate);
reduction_achieved = (peak_inflow - peak_outflow) / peak_inflow;
fprintf('\nPerformance Metrics:\n');
fprintf('Peak Inflow: %.2f cfs\n', peak_inflow);
fprintf('Peak Outflow: %.2f cfs\n', peak_outflow);
fprintf('Peak Flow Reduction: %.1f%%\n', reduction_achieved * 100);

% check if target reduction is achieved
if reduction_achieved >= target_peak_reduction
    fprintf('Design meets target reduction requirements.\n');
else
    fprintf('Design does not meet target reduction requirements.\n');
end

% Helper Functions
function Q = rational_method(A, C, I)
    Q = C * I * A * 1.00833; % Correct conversion factor: 1 acre-in/hr = 1.00833 cfs
end

function [c, ceq] = design_constraints(x, peak_inflow, reduction, depth) 
    D = x(2);
    % Constraint: Outflow peak < reduction * inflow peak (simplified check)
    max_outflow = (pi/4 * D^2) * sqrt(2*32.2*depth); % Orifice flow approx at full depth
    c = max_outflow - reduction * peak_inflow;
    ceq = []; % No equality constraints
end

function dydt = basin_ode(t, y, inflow, t_vec, D, V_max, basin_depth)
    % Interpolate inflow at current time
    inflow_interp = interp1(t_vec, inflow, t, 'linear', 0);
    
    % Calculate outflow using orifice equation
    % Ensure depth doesn't go negative
    current_depth = max(y, 0);
    if current_depth > 0
        outflow = (pi/4 * D^2) * sqrt(2*32.2 * current_depth);
    else
        outflow = 0;
    end    
    
    % Calculate surface area from volume and depth
    surface_area = V_max / basin_depth;
    
    % Rate of change of depth: d(depth)/dt = (inflow - outflow) / surface_area
    dydt = (inflow_interp - outflow) / surface_area;
end