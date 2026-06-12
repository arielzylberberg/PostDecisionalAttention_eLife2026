function [err,P,ATT] = wrapper_dtb_parametricbound_rt_ATT(theta,rt,values,pd_fix_dur,choice,c,pars,plot_flag)
% function [err,P] = wrapper_dtb_parametricbound_rt_ATT(theta,rt,values,pd_fix_dur,choice,c,pars,plot_flag)
% written by ariel zylberberg (ariel.zylberberg@gmail.com)


%%
kappa  = theta(1);
ndt_m  = theta(2);
ndt_s  = theta(3);
B0     = theta(4);
a      = theta(5);
d      = theta(6);
coh0   = theta(7);
y0a    = theta(8);
omega  = theta(9);

%%
if ~isempty(pars) && isfield(pars,'notabs_flag')
    notabs_flag = pars.notabs_flag;
else
    notabs_flag = false;
end

%%

if ~isempty(pars) && isfield(pars,'t')
    t = pars.t;
    dt = t(2)-t(1);
else
    dt = 0.0005;
    t  = 0:dt:10;
end

%% sample attention
ntrials = length(choice);
ntimes = length(t);
p_start_with_left = 0.7415;
switch_time_cost = 0;
ATT = sample_attention_switches_from_pd(ntrials,ntimes,pd_fix_dur,p_start_with_left,dt,switch_time_cost);

%% construct coh (as a matrix ntrials x time now)

coh_att_1 = values(:,1) - values(:,2)*omega; % omega discounts the unatended
coh_att_0 = values(:,1)*omega - values(:,2);
coh = bsxfun(@times,(ATT==1),coh_att_1) + bsxfun(@times,(ATT==0),coh_att_0);


%% bounds
if ~isempty(pars) && isfield(pars,'USfunc')
    USfunc = pars.USfunc;
else
    USfunc = 'Exponential';
end
[Bup,Blo] = expand_bounds(t,B0,a,d,USfunc);

%%

y  = linspace(min(Blo)-0.3,max(Bup)+0.3,750)';

y0a = clip(y0a,Blo(1),Bup(1));

y0 = zeros(size(y));
y0(findclose(y,y0a)) = 1;
y0 = y0/sum(y0);


%%
% prior = Rtable(coh)/sum(Rtable(coh));

%%
% drift = kappa * unique(coh + coh0);
[ucoh, ~,idx_ucoh] = unique((coh + coh0),'rows');
drift_t_matrix = kappa * ucoh;

P = dtb_fp_cc_vec_dyndrifts(drift_t_matrix,t,Bup,Blo,y,y0,notabs_flag);
P.trial_idx = idx_ucoh;

%%

if numel(choice)>1

    %% likelihood

    err = logl_choiceRT_1d_att(P,choice,rt,coh,ndt_m,ndt_s);
%     err = logl_choiceRT_1d_att(P,choice,rt,values,ndt_m,ndt_s);


    %% print
    fprintf('err=%.3f kappa=%.2f ndt_mu=%.2f ndt_s=%.2f B0=%.2f a=%.2f d=%.2f coh0=%.2f y0=%.2f omega=%.2f \n',...
        err,kappa,ndt_m,ndt_s,B0,a,d,coh0,y0a,omega);

    %%

    if plot_flag
        m = prctile(rt,99.5);

        figure(1);clf
        set(gcf,'Position',[311  393  885  247]);

        subplot(1,3,1);
        plot(t,P.Bup,'k');
        hold all
        plot(t,P.Blo,'k');
        if ~isnan(m)
            xlim([0,m])
        end
        xlabel('Time');
        ylabel('DV');

        subplot(1,3,2);
        delta_v = values(:,2)-values(:,1);
        [tt,xx,ss] = curva_media(choice,delta_v,[],0);
        terrorbar(tt,xx,ss,'color','k','LineStyle','none','Marker','.','markersize',20);
        hold all
        [tt,xx] = curva_media(P.up.p(idx_ucoh), delta_v,[],0);
        plot(tt,xx,'k');
        xlabel('\Delta value');
        ylabel('P rightward');

        
        subplot(1,3,3);
        [tt,xx,ss] = curva_media(rt,delta_v,choice==1,0);
        terrorbar(tt,xx,ss,'color','b','LineStyle','none','Marker','.','markersize',20);
        hold all
        [tt,xx,ss] = curva_media(rt,delta_v,choice==0,0);
        terrorbar(tt,xx,ss,'color','r','LineStyle','none','Marker','.','markersize',20);

        [tt,xx] = curva_media(P.up.mean_t(idx_ucoh) + ndt_m, delta_v,[],0);
        plot(tt,xx,'b');
        [tt,xx] = curva_media(P.lo.mean_t(idx_ucoh) + ndt_m, delta_v,[],0);
        plot(tt,xx,'r');
        xlabel('\Delta value');
        ylabel('RT');


        format_figure(gcf,'LineWidthPlot',1,'MarkerSize',16);

        drawnow

    end

else
    err = [];
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% function ATT = sample_attention_switches_from_pd(ntrials,ntimes,pd,init_bias,dt,switch_time_cost)
% 
% 
% if nargin<6 || isempty(switch_time_cost)
%     switch_time_cost = 0;
% end
% 
% ATT = zeros(ntrials,ntimes);
% ATT(:,1) = rand(ntrials,1)<init_bias; % random
% 
% time_cost_steps = round(switch_time_cost / dt);
% 
% samp_last_switch = ones(ntrials,1); %
% % I sample the max of two exponential samples to get the switch time
% switch_step = samp_last_switch + round(pd.random(ntrials,1)/dt);
% 
% for i=2:ntimes
%     I = switch_step==i;
% 
%     nn = min(ntimes,i + time_cost_steps);
% 
%     ATT(I, nn) = 1 - ATT(I,i-1); % switch
%     ATT(I,i:nn-1) = 2; % switch cost, do nothing
% 
%     % no switch and not in refractory period
%     J = ~I & ATT(:,i-1)~=2;
%     ATT(J,i) = ATT(J,i-1); % no switch
% 
%     samp_last_switch(I) = i;
%     switch_step(I) = time_cost_steps + samp_last_switch(I) ...
%         + round(pd.random(sum(I),1)/dt);
% end


% end

