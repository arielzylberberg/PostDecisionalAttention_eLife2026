function [params, logisticFun] = fitLogisticMLE(x, y, n)
    % fitLogisticMLE: Fits a logistic function to binomial data using MLE.
    %
    % Inputs:
    %   x  - Vector of x data points
    %   y  - Vector of mean probabilities (correct proportions)
    %   n  - Vector of number of trials for each x
    %
    % Output:
    %   params - Fitted parameters [a, b] for the logistic function

    % Logistic function definition
    logisticFun = @(p, x) 1 ./ (1 + exp(-(p(1) + p(2) * x)));

    % Log-likelihood function
    logLikelihood = @(p) -sum( ...
        n .* y .* log(logisticFun(p, x)) + ...
        n .* (1 - y) .* log(1 - logisticFun(p, x)) ...
    );

    % Initial guesses for parameters [a, b]
    initialParams = [0, 1];

    % Fit parameters using fminsearch
    options = optimset('Display', 'off'); % Suppress output
    params = fminsearch(logLikelihood, initialParams, options);
end
