function [params, logisticFun] = fitLogisticGaussian(x, y, se)
    % fitLogisticGaussian: Fits a logistic function to data using Gaussian likelihood.
    %
    % Inputs:
    %   x  - Vector of x data points
    %   y  - Vector of mean probabilities y(x) (averaged across participants)
    %   se - Vector of standard errors for y(x)
    %
    % Output:
    %   params - Fitted parameters [a, b] for the logistic function

    % Logistic function definition
    logisticFun = @(p, x) 1 ./ (1 + exp(-(p(1) + p(2) * x)));

    % Log-likelihood function for Gaussian noise
    logLikelihood = @(p) -sum( ...
        0.5 * ((y - logisticFun(p, x)) ./ se).^2 + log(se * sqrt(2 * pi)) ...
    );

    % Initial guesses for parameters [a, b]
    initialParams = [0, 1];

    % Fit parameters using fminsearch
    options = optimset('Display', 'off'); % Suppress output
    params = fminsearch(@(p) -logLikelihood(p), initialParams, options);
end
