function [err,P,pChoiceT] = wrapper_dtb_parametricbound_rt_extATT(theta,values,ATT,choice,c,pars,plot_flag)
% function [err,P] = wrapper_dtb_parametricbound_rt_ATT(theta,rt,values,pd_fix_dur,choice,c,pars,plot_flag)
% written by ariel zylberberg (ariel.zylberberg@gmail.com)


%%
kappa  = theta(1);
B0     = theta(2);
a      = theta(3);
d      = theta(4);
coh0   = theta(5);
y0a    = theta(6);
omega  = theta(7);

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

    % dec_time = nansum(ATT,2)*dt;
    dec_step = sum(~isnan(ATT),2);
    I = dec_step>0; % some trials may have no fixations to the items
    pChoiceT = nan(length(dec_step),2);

    p_up_pdf = P.up.pdf_t(P.trial_idx,:);
    p_lo_pdf = P.lo.pdf_t(P.trial_idx,:);

    [err,~,pChoiceT(I,:)] = logl_choice_dec_time(p_up_pdf(I,:),p_lo_pdf(I,:),choice(I),dec_step(I));

    pUpGivenDecTime = pChoiceT(:,2)./sum(pChoiceT,2);

    %% print
    fprintf('err=%.3f kappa=%.2f B0=%.2f a=%.2f d=%.2f coh0=%.2f y0=%.2f omega=%.2f \n',...
        err,kappa,B0,a,d,coh0,y0a,omega);

    %%

    if plot_flag

        figure(1);clf
        set(gcf,'Position',[311  393  885  247]);

        subplot(1,2,1);
        plot(t,P.Bup,'k');
        hold all
        plot(t,P.Blo,'k');
        xlim([0,5])
        xlabel('Time');
        ylabel('DV');

        subplot(1,2,2);

        subplot(1,2,2);
        delta_v = values(:,2)-values(:,1);
        [tt,xx,ss] = curva_media(choice,delta_v,[],0);
        terrorbar(tt,xx,ss,'color','k','LineStyle','none','Marker','.','markersize',20);
        hold all
        [tt,xx] = curva_media(pUpGivenDecTime, delta_v,[],0);
        plot(tt,xx,'k');
        xlabel('\Delta value');
        ylabel('P rightward');


        
%         subplot(1,3,3);
%         [tt,xx,ss] = curva_media(dec_time,delta_v,choice==1,0);
%         terrorbar(tt,xx,ss,'color','b','LineStyle','none','Marker','.','markersize',20);
%         hold all
%         [tt,xx,ss] = curva_media(dec_time,delta_v,choice==0,0);
%         terrorbar(tt,xx,ss,'color','r','LineStyle','none','Marker','.','markersize',20);
% 
%         [tt,xx] = curva_media(P.up.mean_t(idx_ucoh), delta_v,[],0);
%         plot(tt,xx,'b');
%         [tt,xx] = curva_media(P.lo.mean_t(idx_ucoh), delta_v,[],0);
%         plot(tt,xx,'r');
%         xlabel('\Delta value');
%         ylabel('Decision time');


        format_figure(gcf,'LineWidthPlot',1,'MarkerSize',16);

        drawnow

    end

else
    err = [];
end

end



