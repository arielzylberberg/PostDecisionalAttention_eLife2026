function res = calc_residuals(depvar, indepvars)

B = glmfit(indepvars, depvar,'normal','link','identity','constant','off');
YHAT = glmval(B,indepvars,'identity','constant','off');

res = depvar-YHAT;
