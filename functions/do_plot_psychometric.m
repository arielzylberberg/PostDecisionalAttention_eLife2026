function p = do_plot_psychometric(d, m, idx, idx_m, flag_use_totfix_as_RT, flag_compact)

%%
if nargin<5 || isempty(flag_use_totfix_as_RT)
    flag_use_totfix_as_RT = 0;
end

if nargin<6 || isempty(flag_compact)
    flag_compact = 0;
end

%%
alpha = 0.3;
average_over_Ss_flag = 1;

if flag_compact
    c = get_colores();
    color_data = c.data;
    color_data_points = c.data_last_fix;
    color_data_last_fix = c.data_last_fix;
    color_model_last_fix = c.model_last_fix;
    color_model = c.model;

else
    
    c = get_colores();
    color_data = c.data;
    color_data_points = c.data_last_fix;
    color_data_last_fix = c.data_last_fix;
    color_model_last_fix = c.model_last_fix;
    color_model = c.model;
end




p = publish_plot(3,1);
set(gcf,'Position',[486  159  278  760]);


%% psychometric
p.next();

if average_over_Ss_flag
    [tt,xx] = curva_media_hierarch(d.choice,d.dv,d.group,idx,0);
    terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data,'marker','o','linestyle','none','MarkerFaceColor',color_data);
    hold all

    if isscalar(nanunique(m.group))
        [tt,xx] = curva_media(m.choice,m.dv,idx_m,0);
        h2(1) = plot(tt,xx,'color',color_model);
    else
        [tt,xx] = curva_media_hierarch(m.choice,m.dv,m.group,idx_m,0);
        niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_model,alpha);
    end
else
    [tt,xx,ss] = curva_media(d.choice,d.dv,idx,0);
    terrorbar(tt,xx,ss,'color',color_data,'marker','o','linestyle','none','MarkerFaceColor',color_data);

    [tt,xx,ss] = curva_media(m.choice,m.dv,idx_m,0);
    niceBars2(tt,xx,ss,color_model,alpha);
end


ht(1) = text(-3.5,0.8,'Data','color',color_data,'horizontalalignment','left');
ht(2) = text(-3.5,0.7,'Model','color',color_model,'horizontalalignment','left');


% plot(tt,xx,'k');
ylabel({'Prob. choose','item on left'});

%% chronometric
p.next();

if flag_use_totfix_as_RT
    dwell_sum = d.tot_fix_time_with_interp/1000;
    
    if isfield(m,'dwell1')
        dwell_sum_model = m.dwell1 + m.dwell2;
    else
        dwell_sum_model = nansum(~isnan(m.focus),2)*(m.t_focus(2)-m.t_focus(1));
    end
    
    RTvar = dwell_sum;
    RTvar_model = dwell_sum_model;

else

    RTvar = d.RT;
    RTvar_model = m.RT;
end

if average_over_Ss_flag
    [tt,xx] = curva_media_hierarch(RTvar,d.dv,d.group,idx,0);
    terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data,'marker','o','linestyle','none','MarkerFaceColor',color_data);
    hold all
    
    if isscalar(nanunique(m.group))
        [tt,xx] = curva_media(RTvar_model, m.dv, idx_m, 0);
        h2(2) = plot(tt,xx,'color',color_model);
    else
        [tt,xx] = curva_media_hierarch(RTvar_model,m.dv,m.group,idx_m,0);
        niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_model,alpha);
    end

else

    [tt,xx,ss] = curva_media(RTvar,d.dv,idx,0);
    terrorbar(tt,xx,ss,'color','k','marker','o','linestyle','none','MarkerFaceColor','k');
    % [tt,xx,ss] = curva_media(mean_RT,d.dv,idx,0);
    [tt,xx,ss] = curva_media(RTvar_model,m.dv,idx_m,0);
    niceBars2(tt,xx,ss,color_model,alpha);
    % plot(tt,xx,'k');
end

if flag_use_totfix_as_RT
    ylabel('Total fixation time [s]');
else
    ylabel('Response time [s]');
end

if flag_compact
    ht(3) = text(-5.5,2.65,'Data','color',color_data,'horizontalalignment','left');
    ht(4) = text(-5.5,2.5,'Model','color',color_model,'horizontalalignment','left');
end

%% split by last fix
p.next();

% colores = [1,0,0;1,0,0];

clear hl
if average_over_Ss_flag

    if isscalar(nanunique(m.group(:)))

        [tt,xx] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==1,0);
        hl(1) = plot(tt,xx,'color',color_data_last_fix(1,:));
        hold all
        [tt,xx] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==0,0);
        hl(2) = plot(tt,xx,'color',color_data_last_fix(2,:));

    else
        [tt,xx] = curva_media_hierarch(m.choice(:),m.dv(:),m.group(:),idx_m & m.focus_last(:)==1,0);
        [~,hl(1)] = niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_model_last_fix(1,:),alpha);
%         set(hl,'LineStyle','--');


        [tt,xx] = curva_media_hierarch(m.choice(:),m.dv(:),m.group(:),idx_m & m.focus_last(:)==0,0);
        [~,hl(2)] = niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_model_last_fix(2,:),alpha);

    end

    [tt,xx] = curva_media_hierarch(d.choice,d.dv,d.group, idx & d.focus_last==1,0);
    hl(1) = terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data_points(1,:),'marker','o','linestyle','none','MarkerFaceColor',color_data_points(1,:));

    [tt,xx] = curva_media_hierarch(d.choice,d.dv,d.group, idx & d.focus_last==0,0);
    hl(2) = terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data_points(2,:),'marker','o','linestyle','none','MarkerFaceColor',color_data_points(2,:));

    if flag_compact==1 % testing - include the 1st plot
        [tt,xx] = curva_media_hierarch(d.choice,d.dv,d.group, idx,0);
        terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data,'marker','o','linestyle','none','MarkerFaceColor',color_data);
        [tt,xx] = curva_media_hierarch(m.choice(:),m.dv(:),m.group(:),idx_m,0);
        niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_data,alpha);

    end

else
    [tt,xx,ss] = curva_media(d.choice,d.dv,idx & d.focus_last==1,0);
    hl(1) = terrorbar(tt,xx,ss,'color',color_data_last_fix(1,:),'marker','.','linestyle','none');
    [tt,xx,ss] = curva_media(d.choice,d.dv,idx & d.focus_last==0,0);
    hl(2) = terrorbar(tt,xx,ss,'color',color_data_last_fix(2,:),'marker','.','linestyle','none');

    [tt,xx,ss] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==1,0);
    niceBars2(tt,xx,ss,color_model_last_fix(1,:),alpha);
    [tt,xx,ss] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==0,0);
    niceBars2(tt,xx,ss,color_model_last_fix(2,:),alpha);
end


% legend_color({'Left fix. last','Right fix. last'}, hl);

ht_last(1) = text(1,0.1,'Last dwell on left','color',color_data_last_fix(1,:),'horizontalalignment','left');
ht_last(2) = text(1,0.2,'Last dwell on right','color',color_data_last_fix(2,:),'horizontalalignment','left');


ylabel({'Prob. choose','item on left'});



%%

set(p.h_ax,'xtick',[-5:2:5]);
p.xlabel({'Value difference','(left - right)'},1:3);

p.format('FontSize',12,'LineWidthPlot',1,'LineWidthAxes',0.5);
set(ht,'FontSize',8);
set(ht_last,'FontSize',8);

end
