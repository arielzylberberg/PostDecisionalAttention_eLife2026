function p = do_calc_and_plot_late_onset_bias(dat, m, align_model_to_flag, recalc_flag)


if nargin<4 || isempty(recalc_flag)
    recalc_flag = 1;
end


if recalc_flag
    %% for data

    switch align_model_to_flag
        case 0 % chronometric time
            t = dat.t_focus(1,:);
            e = dat.focus;
            RT = dat.RT;

        case 1 % tot-fix time
            max_time_steps = 15000;
            dt_sec = 1/1000;
            ATT = dwells_to_mat(dat.dwells, dt_sec, max_time_steps);
            t = [1:max_time_steps]*dt_sec;
            e = ATT;
            RT = (dat.dwell_left+dat.dwell_right);

    end


    e(dat.choice==0,:) = 1 - e(dat.choice==0,:);
    [datamp,timeslocked] = eventlockedmatc(e,t,RT,[1,0.5]);

    t_ignore_before_resp = 0.5; % ms to ignore before the RT in the stim aligned plot

    e = motionenergy.remove_post_decision_samples(e, t, RT-t_ignore_before_resp);
    [~,e] = curva_media(e,dat.group,[],0); % group -> suj
    d = datamp';
    [~,d] = curva_media(d,dat.group,[],0); % group -> suj


    %% now for model

    % now for model
    t_m = m.t_focus;
    e_m = m.focus;
    e_m(m.choice==0,:) = 1 - e_m(m.choice==0,:);


    switch align_model_to_flag
        case 0 % RT
            t_last_model = m.RT;
        case 1 % total fix time
            dt = t_m(2)-t_m(1);
            t_last_model = nansum(~isnan(m.focus),2) * dt;
            %     case 3 % dec time
            %         t_last_model = m.DecTime;
    end

    [datamp_m, timeslocked_m] = eventlockedmatc(e_m,t_m, t_last_model ,[1,0.5]);

    e_m = motionenergy.remove_post_decision_samples(e_m, t_m, t_last_model - t_ignore_before_resp);
    [~,e_m] = curva_media(e_m,m.group,[],0); % group -> suj
    d_m = datamp_m';
    [~,d_m] = curva_media(d_m,m.group,[],0); % group -> suj

    
    %%
    switch align_model_to_flag
    case 0
        aux = mean(isnan(dat.focus));
        % first_t = t(find(aux<.3,1)); % less than x% of trials are nan's
        first_t = t(find(aux<.5,1)); % less than x% of trials are nan's
    case 1
        first_t = 0;
    end

    %%

    save preprodata_late_onset_bias t e timeslocked d t_m e_m timeslocked_m d_m first_t -v7.3
    
else
    load preprodata_late_onset_bias
    
end

%% now plot

alpha = 0.3;

p = publish_plot(1,2);
set(gcf,'Position',[323  327  722  288]);

p.shrink(1:2,1,0.8);
p.displace_ax(1:2,0.1,2);

p.next();


c = get_colores();
colores = [c.data; c.model];

tind = t>=first_t & t<=0.8;
[errorPatch(1),dataLine(1)] = niceBars2(t(tind), nanmean(e(:,tind)), 1.96 * stderror(e(:,tind)),colores(1,:),alpha);
hold all
% tind = t_m>=first_t & t_m<=0.8;
tind = t_m>=0 & t_m<=0.8;
[~,h(1)] = niceBars2(t_m(tind), nanmean(e_m(:,tind),1), 1.96 * stderror(e_m(:,tind)),colores(2,:),alpha);
xli = xlim;
xli(1) = 0;
xlim(xli);


p.next();
tind = timeslocked>=-1 & timeslocked<=0;
[errorPatch(2),dataLine(2)] = niceBars2(timeslocked(tind), nanmean(d(:,tind)), 1.96 * stderror(d(:,tind)),colores(1,:),alpha);
hold all
% h(2) = plot(timeslocked_m(tind), nanmean(d_m(:,tind)));
tind = timeslocked_m>=-1 & timeslocked_m<=0;
[~,h(2)] = niceBars2(timeslocked_m(tind), nanmean(d_m(:,tind),1), 1.96 * stderror(d_m(:,tind)),colores(2,:),alpha);


set(dataLine,'linewidth',1);
% set(errorPatch,'faceColor',0.5*[1,1,1]);
set(h,'LineWidth',2,'color',colores(2,:),'LineStyle','-');

same_ylim(p.h_ax);
same_xscale(p.h_ax);
set(p.h_ax(2),'ycolor','none');

p.current_ax(1);
switch align_model_to_flag
    case 0
        xlabel({'Time from','stimulus onset [s]'});
    case 1
        xlabel({'Fixation time', 'from stim. onset [s]'});
end

ylabel({'Prob. of looking at','the chosen item'});

p.current_ax(2);
switch align_model_to_flag
    case 0
        xlabel('Time from RT [s]');
    case 1
        xlabel({'Time from','total fix. time [s]'});
end



p.format('FontSize',14);



end