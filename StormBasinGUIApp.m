function StormBasinGUIApp

    % 1. Create the Main Figure 
    fig = uifigure('Name', 'Storm Water Detention Basin Design & Sim', ...
                   'Position', [100 100 850 600]);

    % 2. Input Panel (Left Side) 
    input_panel = uipanel(fig, 'Title', 'Input Parameters', ...
                              'Position', [20 50 250 500]);

    % Initial values from your script
    A_initial = 100; % Watershed area
    C_initial = 0.8; % Runoff coefficient
    I_initial = 5; % Rainfall intensity
    target_initial = 0.1; % Target reduction
    depth_initial = 10; % Basin depth

    % Create Labels and Edit Fields (A, C, I, target_peak_reduction, basin_depth)
    % Area (A)
    uilabel(input_panel, 'Text', 'Watershed Area (acres):', 'Position', [20 420 150 22]);
    A_field = uieditfield(input_panel, 'numeric', 'Value', A_initial, ...
                                    'Position', [170 420 60 22]);

    % Runoff Coefficient (C)
    uilabel(input_panel, 'Text', 'Runoff Coeff (C):', 'Position', [20 380 150 22]);
    C_field = uieditfield(input_panel, 'numeric', 'Value', C_initial, ...
                                    'Position', [170 380 60 22]);

    % Rainfall Intensity (I)
    uilabel(input_panel, 'Text', 'Rainfall Intensity (in/hr):', 'Position', [20 340 150 22]);
    I_field = uieditfield(input_panel, 'numeric', 'Value', I_initial, ...
                                    'Position', [170 340 60 22]);

    % Target Peak Reduction
    uilabel(input_panel, 'Text', 'Target Peak Reduction (frac):', 'Position', [20 300 150 22]);
    target_field = uieditfield(input_panel, 'numeric', 'Value', target_initial, ...
                                         'Position', [170 300 60 22]);

    % Basin Depth
    uilabel(input_panel, 'Text', 'Basin Depth (ft):', 'Position', [20 260 150 22]);
    depth_field = uieditfield(input_panel, 'numeric', 'Value', depth_initial, ...
                                       'Position', [170 260 60 22]);

    % Run Button
    uibutton(fig, 'Text', 'Run Design & Simulation', ...
                 'Position',[20 45 250 30] , ...
                 'ButtonPushedFcn', @(~,~) run_simulation_callback());
    % 2b. Save Plots Button
    uibutton(fig, 'Text', 'Save Plots (PNG)', ...
                 'Position',[20 10 250 30], ... % Adjusted position
                 'ButtonPushedFcn', @(~,~) save_plots_callback(fig)); % Pass the figure handle
    % 3. Output/Results Panel (Right Side) 
    results_panel = uipanel(fig, 'Title', 'Results & Metrics', ...
                                'Position', [290 50 540 500]);

    % Text Area for Optimal Parameters and Performance Metric
    metrics_area = uitextarea(results_panel, 'Value', 'Press "Run" to see results...', ...
                                      'Position', [20 330 500 120]);

    % Axes for Hydrographs
    ax1 = uiaxes(results_panel, 'Position', [30 200 480 120]);
    title(ax1, 'Inflow Hydrograph');
    xlabel(ax1, 'Time (hr)');
    ylabel(ax1, 'Flow (cfs)');
    grid(ax1, 'on');

    ax2 = uiaxes(results_panel, 'Position', [30 50 480 120]);
    title(ax2, 'Outflow Hydrograph');
    xlabel(ax2, 'Time (hr)');
    ylabel(ax2, 'Flow (cfs)');
    grid(ax2, 'on');


    % 4. Callback Function (The core logic)
    function run_simulation_callback()
        % 1. Get current input values
        A = A_field.Value;
        C = C_field.Value;
        I = I_field.Value;
        target_peak_reduction = target_field.Value;
        basin_depth = depth_field.Value;
        storm_duration = 24; % Fixed for this example

        % 2. Core Design and Simulation Logic (from your script)

        % Compute peak inflow
        peak_inflow = rational_method(A, C, I); % cfs

        % Design: Optimize storage volume and orifice diameter
        objective = @(x) x(1);
        constraints = @(x) design_constraints(x, peak_inflow, target_peak_reduction, basin_depth);
        x0 = [1000, 1];
        lb = [100, 0.1]; ub = [1e5, 5];
        options = optimoptions('fmincon', 'Display', 'off'); % Turn off command line display
        
        try
            [opt_params, ~] = fmincon(objective, x0, [], [], [], [], lb, ub, constraints, options);
            storage_volume = opt_params(1);
            orifice_diam = opt_params(2);
        catch ME
             metrics_area.Value = sprintf('Optimization Error: %s', ME.message);
             return;
        end


        % Simulation: Generate inflow hydrograph and simulate basin
        t_sim = 0:0.1:storm_duration;
        t_hydrograph = 0:0.01:storm_duration;

        % Generate inflow hydrograph (Simplified triangular hydrograph)
        inflow_rate = peak_inflow * (t_hydrograph / storm_duration) .* exp(1 - t_hydrograph / storm_duration);

        % Solve ODE
        basin_ode_func = @(t,y) basin_ode(t, y, inflow_rate, t_hydrograph, orifice_diam, storage_volume, basin_depth);
        [~, outflow_depth] = ode45(basin_ode_func, t_sim, 0);

        % Compute actual outflow rate
        outflow_rate = (pi/4 * orifice_diam^2) * sqrt(2*32.2 * max(outflow_depth, 0));

        % Performance metrics
        peak_outflow = max(outflow_rate);
        reduction_achieved = (peak_inflow - peak_outflow) / peak_inflow;

        if reduction_achieved >= target_peak_reduction
            reduction_status = 'Design meets target reduction requirements.';
        else
            reduction_status = 'Design **DOES NOT** meet target reduction requirements.';
        end

        % 3. Update GUI elements
        
        % Update Metrics Text Area
        metrics_text = sprintf('Optimal Storage Volume: %.2f cu ft\nOptimal Orifice Diameter: %.2f ft\n\nPeak Inflow: %.2f cfs\nPeak Outflow: %.2f cfs\nPeak Flow Reduction: %.1f%%\n\n%s', ...
                               storage_volume, orifice_diam, peak_inflow, peak_outflow, reduction_achieved * 100, reduction_status);
        metrics_area.Value = metrics_text;

        % Plot Inflow Hydrograph
        plot(ax1, t_hydrograph, inflow_rate, 'b');
        title(ax1, 'Inflow Hydrograph');
        xlabel(ax1, 'Time (hr)');
        ylabel(ax1, 'Flow (cfs)');
        grid(ax1, 'on');

        % Plot Outflow Hydrograph
        plot(ax2, t_sim, outflow_rate, 'r');
        title(ax2, 'Outflow Hydrograph');
        xlabel(ax2, 'Time (hr)');
        ylabel(ax2, 'Flow (cfs)');
        grid(ax2, 'on');
    end
% 6. Save Plots Callback Function
    function save_plots_callback(hFig)
        % Open the Save As dialog
        [filename, pathname] = uiputfile('Basin_Hydrographs.png', 'Save Hydrograph Plots As');

        if isequal(filename, 0) || isequal(pathname, 0)
            % User canceled the operation
            uialert(hFig, 'Save operation canceled.', 'Canceled');
            return;
        end

        fullFilePath = fullfile(pathname, filename);

        % Temporarily create a new, clean figure just for the plots
        % This prevents saving the entire GUI layout.
        
        % Check if plots were generated (i.e., if axes contain children)
        if isempty(ax1.Children) && isempty(ax2.Children)
            uialert(hFig, 'Run the simulation first before saving plots.', 'Warning');
            return;
        end
        
        % Create a new figure for exporting
        hExportFig = figure('Visible', 'off'); % Create a hidden figure
        
        % Subplot 1: Inflow
        hAx1_copy = subplot(2, 1, 1);
        copyobj(allchild(ax1), hAx1_copy);
        title(hAx1_copy, 'Inflow Hydrograph');
        xlabel(hAx1_copy, 'Time (hr)');
        ylabel(hAx1_copy, 'Flow (cfs)');
        grid(hAx1_copy, 'on');

        % Subplot 2: Outflow
        hAx2_copy = subplot(2, 1, 2);
        copyobj(allchild(ax2), hAx2_copy);
        title(hAx2_copy, 'Outflow Hydrograph');
        xlabel(hAx2_copy, 'Time (hr)');
        ylabel(hAx2_copy, 'Flow (cfs)');
        grid(hAx2_copy, 'on');
        
        % Print (save) the figure to the specified file path (PNG format)
        print(hExportFig, fullFilePath, '-dpng', '-r300'); % -r300 sets resolution to 300 dpi

        % Close the temporary figure
        close(hExportFig);

        % Display success message
        uialert(hFig, ['Plots successfully saved to: ', fullFilePath], 'Success');
    end

    % 5. Helper Functions (Defined as nested or separate functions) 

    function Q = rational_method(A, C, I)
        Q = C * I * A * 1.00833; % 1 acre-in/hr = 1.00833 cfs
    end

    function [c, ceq] = design_constraints(x, peak_inflow, reduction, depth)
        D = x(2);
        % Constraint: Outflow peak < reduction * inflow peak
        max_outflow = (pi/4 * D^2) * sqrt(2*32.2*depth); % Orifice flow approx at full depth
        c = max_outflow - reduction * peak_inflow;
        ceq = [];
    end

    function dydt = basin_ode(t, y, inflow, t_vec, D, V_max, basin_depth)
        % Interpolate inflow at current time
        inflow_interp = interp1(t_vec, inflow, t, 'linear', 0);

        % Calculate outflow using orifice equation
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
end