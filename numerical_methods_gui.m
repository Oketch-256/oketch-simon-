function numerical_methods_gui()
    % Create the main GUI figure
    fig = figure('Name', 'Numerical Methods GUI', 'Position', [100, 100, 900, 600], ...
                 'NumberTitle', 'off', 'MenuBar', 'none');

    % Results display area
    results_text = uicontrol('Style', 'edit', 'Position', [450, 50, 400, 500], ...
                            'Max', 10, 'Min', 0, 'HorizontalAlignment', 'left', ...
                            'Enable', 'inactive', 'String', 'Results will appear here...');

    % Function input
    uicontrol('Style', 'text', 'Position', [20, 550, 120, 20], 'String', 'Function f(x):');
    func_input = uicontrol('Style', 'edit', 'Position', [150, 550, 250, 20], 'String', '-4.9*x^2 + 15*x + 10');

    % Bisection method inputs
    uicontrol('Style', 'text', 'Position', [30, 500, 120, 20], 'String', 'Bisection Method:');
    uicontrol('Style', 'text', 'Position', [20, 470, 30, 20], 'String', 'a:');
    a_input = uicontrol('Style', 'edit', 'Position', [60, 470, 50, 20], 'String', '0');
    uicontrol('Style', 'text', 'Position', [120, 470, 30, 20], 'String', 'b:');
    b_input = uicontrol('Style', 'edit', 'Position', [160, 470, 50, 20], 'String', '4');
    uicontrol('Style', 'text', 'Position', [220, 470, 70, 20], 'String', 'Tolerance:');
    tol_input = uicontrol('Style', 'edit', 'Position', [290, 470, 50, 20], 'String', '0.001');
    uicontrol('Style', 'pushbutton', 'Position', [360, 470, 80, 25], 'String', 'Solve Bisection', ...
              'Callback', @(src,event)bisection_callback(func_input, a_input, b_input, tol_input, results_text));

    % Secant method inputs
    uicontrol('Style', 'text', 'Position', [30, 420, 120, 20], 'String', 'Secant Method:');
    uicontrol('Style', 'text', 'Position', [20, 390, 30, 20], 'String', 'x0:');
    x0_input = uicontrol('Style', 'edit', 'Position', [60, 390, 50, 20], 'String', '2');
    uicontrol('Style', 'text', 'Position', [120, 390, 30, 20], 'String', 'x1:');
    x1_input = uicontrol('Style', 'edit', 'Position', [160, 390, 50, 20], 'String', '3');
    uicontrol('Style', 'text', 'Position', [220, 390, 70, 20], 'String', 'Tolerance:');
    tol_input2 = uicontrol('Style', 'edit', 'Position', [290, 390, 50, 20], 'String', '0.001');
    uicontrol('Style', 'pushbutton', 'Position', [360, 390, 80, 25], 'String', 'Solve Secant', ...
              'Callback', @(src,event)secant_callback(func_input, x0_input, x1_input, tol_input2, results_text));

    % Simpson's 1/3 rule inputs
    uicontrol('Style', 'text', 'Position', [30, 340, 150, 20], 'String', 'Simpson''s 1/3 Rule:');
    uicontrol('Style', 'text', 'Position', [20, 310, 30, 20], 'String', 'a:');
    a_input2 = uicontrol('Style', 'edit', 'Position', [60, 310, 50, 20], 'String', '0');
    uicontrol('Style', 'text', 'Position', [120, 310, 30, 20], 'String', 'b:');
    b_input2 = uicontrol('Style', 'edit', 'Position', [160, 310, 50, 20], 'String', '3');
    uicontrol('Style', 'text', 'Position', [220, 310, 30, 20], 'String', 'n:');
    n_input = uicontrol('Style', 'edit', 'Position', [260, 310, 50, 20], 'String', '6');
    uicontrol('Style', 'pushbutton', 'Position', [360, 310, 80, 25], 'String', 'Solve Simpson', ...
              'Callback', @(src,event)simpson_callback(func_input, a_input2, b_input2, n_input, results_text));

    % Lagrange interpolation inputs
    uicontrol('Style', 'text', 'Position', [20, 250, 150, 20], 'String', 'Lagrange Interpolation:');
    uicontrol('Style', 'text', 'Position', [20, 220, 100, 20], 'String', 'x (comma sep):');
    x_input = uicontrol('Style', 'edit', 'Position', [120, 220, 150, 20], 'String', '0,1,2,3');
    uicontrol('Style', 'text', 'Position', [20, 190, 100, 20], 'String', 'y (comma sep):');
    y_input = uicontrol('Style', 'edit', 'Position', [120, 190, 150, 20], 'String', '10,20.1,20.4,10.9');
    uicontrol('Style', 'text', 'Position', [20, 160, 100, 20], 'String', 'Point to evaluate:');
    eval_input = uicontrol('Style', 'edit', 'Position', [120, 160, 50, 20], 'String', '1.5');
    uicontrol('Style', 'pushbutton', 'Position', [180, 160, 100, 25], 'String', 'Solve Lagrange', ...
              'Callback', @(src,event)lagrange_callback(x_input, y_input, eval_input, results_text));

    % Clear results button
    uicontrol('Style', 'pushbutton', 'Position', [450, 20, 100, 25], 'String', 'Clear Results', ...
              'Callback', @(src,event)set(results_text, 'String', 'Results will appear here...'));
end

% Bisection Method Callback
function bisection_callback(func_input, a_input, b_input, tol_input, results_text)
    try
        % Get inputs
        func_str = get(func_input, 'String');
        a = str2double(get(a_input, 'String'));
        b = str2double(get(b_input, 'String'));
        tol = str2double(get(tol_input, 'String'));
        
        % Validate inputs
        if isnan(a) || isnan(b) || isnan(tol)
            error('Please enter valid numbers for a, b, and tolerance');
        end
        
        if a >= b
            error('a must be less than b');
        end
        
        if tol <= 0
            error('Tolerance must be positive');
        end
        
        % Define the function
        f = str2func(['@(x) ' func_str]);
        
        % Check if f(a) and f(b) have opposite signs
        fa = f(a);
        fb = f(b);
        
        if fa * fb >= 0
            error('f(a) and f(b) must have opposite signs for bisection method');
        end
        
        % Bisection method implementation
        iter = 0;
        max_iter = 1000;
        results = {};
        
        while (b - a) / 2 > tol && iter < max_iter
            c = (a + b) / 2;
            fc = f(c);
            
            results{end+1} = sprintf('Iteration %d: a=%.6f, b=%.6f, c=%.6f, f(c)=%.6f', ...
                                    iter, a, b, c, fc);
            
            if fc == 0
                break;
            elseif fa * fc < 0
                b = c;
                fb = fc;
            else
                a = c;
                fa = fc;
            end
            
            iter = iter + 1;
        end
        
        root = (a + b) / 2;
        
        % Display results
        result_str = sprintf('BISECTION METHOD RESULTS:\n');
        result_str = [result_str sprintf('Function: f(x) = %s\n', func_str)];
        result_str = [result_str sprintf('Interval: [%.4f, %.4f]\n', str2double(get(a_input, 'String')), str2double(get(b_input, 'String')))];
        result_str = [result_str sprintf('Tolerance: %.6f\n\n', tol)];
        result_str = [result_str sprintf('Root found: x = %.8f\n', root)];
        result_str = [result_str sprintf('f(root) = %.8f\n', f(root))];
        result_str = [result_str sprintf('Iterations: %d\n\n', iter)];
        
        if iter >= max_iter
            result_str = [result_str 'WARNING: Maximum iterations reached\n'];
        end
        
        % Show last few iterations
        result_str = [result_str 'Last few iterations:\n'];
        start_idx = max(1, length(results) - 5);
        for i = start_idx:length(results)
            result_str = [result_str results{i} '\n'];
        end
        
        set(results_text, 'String', result_str);
        
    catch ME
        set(results_text, 'String', sprintf('ERROR in Bisection Method:\n%s', ME.message));
    end
end

% Secant Method Callback
function secant_callback(func_input, x0_input, x1_input, tol_input, results_text)
    try
        % Get inputs
        func_str = get(func_input, 'String');
        x0 = str2double(get(x0_input, 'String'));
        x1 = str2double(get(x1_input, 'String'));
        tol = str2double(get(tol_input, 'String'));
        
        % Validate inputs
        if isnan(x0) || isnan(x1) || isnan(tol)
            error('Please enter valid numbers for x0, x1, and tolerance');
        end
        
        if x0 == x1
            error('x0 and x1 must be different');
        end
        
        if tol <= 0
            error('Tolerance must be positive');
        end
        
        % Define the function
        f = str2func(['@(x) ' func_str]);
        
        % Secant method implementation
        iter = 0;
        max_iter = 1000;
        results = {};
        
        while iter < max_iter
            fx0 = f(x0);
            fx1 = f(x1);
            
            if abs(fx1) < tol
                break;
            end
            
            % Secant formula
            x2 = x1 - fx1 * (x1 - x0) / (fx1 - fx0);
            
            results{end+1} = sprintf('Iteration %d: x=%.8f, f(x)=%.8f', ...
                                    iter, x1, fx1);
            
            if abs(x2 - x1) < tol
                break;
            end
            
            x0 = x1;
            x1 = x2;
            iter = iter + 1;
        end
        
        % Display results
        result_str = sprintf('SECANT METHOD RESULTS:\n');
        result_str = [result_str sprintf('Function: f(x) = %s\n', func_str)];
        result_str = [result_str sprintf('Initial guesses: x0=%.4f, x1=%.4f\n', str2double(get(x0_input, 'String')), str2double(get(x1_input, 'String')))];
        result_str = [result_str sprintf('Tolerance: %.6f\n\n', tol)];
        result_str = [result_str sprintf('Root found: x = %.8f\n', x1)];
        result_str = [result_str sprintf('f(root) = %.8f\n', f(x1))];
        result_str = [result_str sprintf('Iterations: %d\n\n', iter)];
        
        if iter >= max_iter
            result_str = [result_str 'WARNING: Maximum iterations reached\n'];
        end
        
        % Show last few iterations
        result_str = [result_str 'Last few iterations:\n'];
        start_idx = max(1, length(results) - 5);
        for i = start_idx:length(results)
            result_str = [result_str results{i} '\n'];
        end
        
        set(results_text, 'String', result_str);
        
    catch ME
        set(results_text, 'String', sprintf('ERROR in Secant Method:\n%s', ME.message));
    end
end

% Simpson's 1/3 Rule Callback
function simpson_callback(func_input, a_input, b_input, n_input, results_text)
    try
        % Get inputs
        func_str = get(func_input, 'String');
        a = str2double(get(a_input, 'String'));
        b = str2double(get(b_input, 'String'));
        n = str2double(get(n_input, 'String'));
        
        % Validate inputs
        if isnan(a) || isnan(b) || isnan(n)
            error('Please enter valid numbers for a, b, and n');
        end
        
        if a >= b
            error('a must be less than b');
        end
        
        if n <= 0 || mod(n, 2) ~= 0
            error('n must be a positive even integer');
        end
        
        % Define the function
        f = str2func(['@(x) ' func_str]);
        
        % Simpson's 1/3 rule implementation
        h = (b - a) / n;
        x = a:h:b;
        
        sum_odd = 0;
        sum_even = 0;
        
        % Calculate sums for odd and even indices
        for i = 2:n
            if mod(i, 2) == 0  % Even index
                sum_even = sum_even + f(x(i));
            else  % Odd index
                sum_odd = sum_odd + f(x(i));
            end
        end
        
        % Simpson's formula
        integral = (h/3) * (f(a) + f(b) + 4*sum_even + 2*sum_odd);
        
        % Display results
        result_str = sprintf('SIMPSON''S 1/3 RULE RESULTS:\n');
        result_str = [result_str sprintf('Function: f(x) = %s\n', func_str)];
        result_str = [result_str sprintf('Interval: [%.4f, %.4f]\n', a, b)];
        result_str = [result_str sprintf('Number of subintervals (n): %d\n', n)];
        result_str = [result_str sprintf('Step size (h): %.6f\n\n', h)];
        result_str = [result_str sprintf('Approximate integral: %.8f\n', integral)];
        
        % Display function values at nodes
        result_str = [result_str sprintf('\nFunction values at nodes:\n')];
        for i = 1:min(length(x), 10)  % Show first 10 points to avoid clutter
            result_str = [result_str sprintf('x=%.4f, f(x)=%.6f\n', x(i), f(x(i)))];
        end
        if length(x) > 10
            result_str = [result_str sprintf('... (showing first 10 of %d points)\n', length(x))];
        end
        
        set(results_text, 'String', result_str);
        
    catch ME
        set(results_text, 'String', sprintf('ERROR in Simpson''s Rule:\n%s', ME.message));
    end
end

% Lagrange Interpolation Callback
function lagrange_callback(x_input, y_input, eval_input, results_text)
    try
        % Get inputs
        x_str = get(x_input, 'String');
        y_str = get(y_input, 'String');
        x_eval = str2double(get(eval_input, 'String'));
        
        % Parse comma-separated values
        x_points = str2num(['[' x_str ']']);
        y_points = str2num(['[' y_str ']']);
        
        % Validate inputs
        if isempty(x_points) || isempty(y_points)
            error('Please enter valid numbers for x and y points');
        end
        
        if length(x_points) ~= length(y_points)
            error('Number of x points must equal number of y points');
        end
        
        if length(x_points) < 2
            error('At least 2 points are required for interpolation');
        end
        
        if isnan(x_eval)
            error('Please enter a valid number for the evaluation point');
        end
        
        % Lagrange interpolation implementation
        n = length(x_points);
        result = 0;
        
        % Calculate Lagrange basis polynomials
        for i = 1:n
            term = y_points(i);
            for j = 1:n
                if j ~= i
                    term = term * (x_eval - x_points(j)) / (x_points(i) - x_points(j));
                end
            end
            result = result + term;
        end
        
        % Display results
        result_str = sprintf('LAGRANGE INTERPOLATION RESULTS:\n');
        result_str = [result_str sprintf('Data points:\n')];
        for i = 1:n
            result_str = [result_str sprintf('  (%.4f, %.4f)\n', x_points(i), y_points(i))];
        end
        result_str = [result_str sprintf('\nEvaluation point: x = %.4f\n', x_eval)];
        result_str = [result_str sprintf('Interpolated value: y = %.8f\n\n', result)];
        
        % Show Lagrange basis polynomials
        result_str = [result_str sprintf('Lagrange basis polynomials L_i(x):\n')];
        for i = 1:min(n, 5)  % Show first 5 to avoid clutter
            poly_str = '';
            for j = 1:n
                if j ~= i
                    if ~isempty(poly_str)
                        poly_str = [poly_str ' * '];
                    end
                    poly_str = [poly_str sprintf('(x - %.2f)/(%.2f - %.2f)', ...
                                x_points(j), x_points(i), x_points(j))];
                end
            end
            result_str = [result_str sprintf('L_%d(x) = %s\n', i, poly_str)];
        end
        if n > 5
            result_str = [result_str sprintf('... (showing first 5 of %d basis polynomials)\n', n)];
        end
        
        set(results_text, 'String', result_str);
        
    catch ME
        set(results_text, 'String', sprintf('ERROR in Lagrange Interpolation:\n%s', ME.message));
    end
end