function [params, logisticFun] = fitLogisticLeastSquares(x, y)
    % fitLogisticLeastSquares: Fits a logistic function to data by minimizing
    % the unweighted sum of squared residuals.
    %
    % Inputs:
    %   x - Vector of x data points
    %   y - Vector of corresponding mean probabilities y(x)
    %
    % Output:
    %   params - Fitted parameters [a, b] for the logistic function

    % Logistic function definition
    logisticFun = @(p, x) 1 ./ (1 + exp(-(p(1) + p(2) * x)));

    % Objective function for unweighted least squares
    objective = @(p) sum((y - logisticFun(p, x)).^2);

    % Initial guesses for parameters [a, b]
    initialParams = [0, 1];

    % Fit parameters using fminsearch
    options = optimset('Display', 'off'); % Suppress output
    params = fminsearch(objective, initialParams, options);
end
