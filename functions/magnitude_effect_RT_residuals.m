function [p, RTres, suma] = magnitude_effect_RT_residuals(RT_sec, group,vright, vleft)

uni_group = nanunique(group);

RTres = nan(size(group));

% fit gaussians to RT = f(\Delta value)
% p = publish_plot(6,7);
for i=1:length(uni_group)
    I = group==uni_group(i) & ~isnan(RT_sec);
    x = vleft(I) - vright(I);
    y = RT_sec(I);
    fitfun = fittype( @(a,b,mu,sigma,x) a+b*exp(-1/2*((x-mu)/sigma).^2) ,'coeff',{'a','b','mu','sigma'});
    % fitfun = fittype( @(a,b,c,x) a+b*x.^c );
    x0 = [1.8,0.5,0,1];
    [fitted_curve,gof] = fit(x,y,fitfun,'StartPoint',x0);
    % Save the coeffiecient values for a,b,c and d in a vector
    coeffvals(i,:) = coeffvalues(fitted_curve);

    % p.next();
    % curva_media(y,x,[],2);
    % hold all
    % curva_media(fitted_curve(x),x,[],1);

    RTres(I) = y - fitted_curve(x);

end
% p.format('FontSize',10);

%%


p = publish_plot(1,1);
suma = vright + vleft;
[tt,xx,ss] = curva_media(RTres,suma,~isnan(RTres),3);

I = ~isnan(RTres);
beta = glmfit(suma(I),RTres(I));
hold all
xli = xlim;
plot(xli,xli*beta(2) + beta(1));


xlabel('v_{right}+v_{left}');
ylabel('RT residuals [s]');
p.format();
