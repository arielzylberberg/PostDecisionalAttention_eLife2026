function [err,P] = wrapper_dtb_rt_analytic_weighted(theta,rt,values,choice,c,focus_prc, pars,plot_flag, rt_only_flag)
% function [err,P] = wrapper_dtb_rt_analytic(theta,rt,coh,choice,c,pars,plot_flag)

if nargin<9 || isempty(rt_only_flag)
    rt_only_flag = 0;
end

%%
kappa  = theta(1);
ndt_m  = theta(2);
ndt_s  = theta(3);
B0     = theta(4);
coh0   = theta(5);
y0a    = theta(6);
omega  = theta(7); 

%%

if ~isempty(pars) && isfield(pars,'t')
    t = pars.t;
    dt = t(2)-t(1);
else
    dt = 0.005;
    t  = 0:dt:10;
end

t = t(:);

%% recalc the coherences using the focus prc

values_att = values * 1; 
values_not_att = values * omega; 

values(:,1) = values_not_att(:,1).*(focus_prc) + values_att(:,1).*(1-focus_prc);
values(:,2) = values_not_att(:,2).*(1-focus_prc) + values_att(:,2).*(focus_prc);

coh = values(:,1) - values(:,2);  


%%
Bup = B0;
drift = kappa * uniquetol(coh + coh0);

yp = y0a/B0; % as a proportion of the bound height
P =  analytic_dtb(drift,t,Bup,yp);
% for legacy:
P.drift = drift;
P.Bup = B0;
P.Blo = -B0;
P.up.pdf_t = P.up.pdf_t';
P.lo.pdf_t = P.lo.pdf_t';


%% likelihood


if rt_only_flag==1
    err = logl_RT_1d(P,choice,rt,coh,ndt_m,ndt_s);
elseif rt_only_flag==2 %hack for choice-only
    
    [~,~,idx_coh] = uniquetol(coh);
    p_up = P.up.p(idx_coh);
    p_lo = P.lo.p(idx_coh);
    p_up = p_up(:);
    p_lo = p_lo(:);
    p_up(p_up<eps | isnan(p_up) | isinf(p_up)) = eps;
    p_lo(p_lo<eps | isnan(p_lo) | isinf(p_lo)) = eps;
    pPred = p_up.*(choice==1) + p_lo.*(choice==0);
    err = -sum(log(pPred));
    
else
    err = logl_choiceRT_1d(P,choice,rt,coh,ndt_m,ndt_s);
end




%%
%% print
fprintf('err=%.3f kappa=%.2f ndt_mu=%.2f ndt_s=%.2f B0=%.2f coh0=%.2f y0=%.2f omega=%.2f \n',...
    err,kappa,ndt_m,ndt_s,B0,coh0,y0a,omega);

%%
if plot_flag
    
    figure(1);clf
    
    subplot(1,2,1);
    curva_media(choice,coh,[],3);
    hold all
    ucoh = unique(coh);
    plot(ucoh,P.up.p,'k-');
    xlabel('Motion coherence');
    ylabel('P rightward choice')
    
    subplot(1,2,2);
%     rt_model = (P.up.mean_t.*P.up.p+P.lo.mean_t.*P.lo.p)./(P.up.p+P.lo.p) + ndt_m; %is not exact because it
%     curva_media(rt,coh,[],3);
%     hold all
%     plot(ucoh,rt_model,'b.-');
    
    % only correct trials
    rt_model_c = P.up.mean_t;
    rt_model_c(ucoh<0) = P.lo.mean_t(ucoh<0);
    rt_model_c(ucoh==0) = (P.up.mean_t(ucoh==0)+P.lo.mean_t(ucoh==0))/2;
    rt_model_c = rt_model_c + ndt_m;
    
    curva_media(rt,coh,c==1,3);
    hold all
    plot(ucoh,rt_model_c,'k-');
    xlabel('Motion coherence');
    ylabel('RT (s)')
    
    set(gcf,'Position',[270   793  1084   293])
    format_figure(gcf);
    
    drawnow
    
end