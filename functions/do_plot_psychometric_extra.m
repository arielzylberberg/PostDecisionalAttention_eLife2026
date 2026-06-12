function p = do_plot_psychometric_extra(d, m, idx, idx_m, flag_use_totfix_as_RT, flag_compact)

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
    colores = cbrewer('qual','Set1',9);
    % colores = cbrewer('qual','Paired',12);
    colores = colores([2,3],:);
    color_data_points = colores;
    color_model = [0,0,0];
else
%     colores = cbrewer('qual','Paired',12);
%     colores = colores([5,6],:);
%     color_data_points = [0.5,0.5,0.5; 0,0,0];
%     color_model = [1,0,0];
    
    c = get_colores();
    color_data = c.data;
    color_data_points = c.data_last_fix;
    color_data_last_fix = c.data_last_fix;
    color_model_last_fix = c.model_last_fix;
    color_model = c.model;
end

color_split_sum = [1,0,0; 0,0,0];




p = publish_plot(4,1);
set(gcf,'Position',[468  170  251  930]);

%% psychometric
p.next();

if average_over_Ss_flag
    [tt,xx] = curva_media_hierarch(d.choice,d.dv,d.group,idx,0);
    terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data,'marker','o','linestyle','none','MarkerFaceColor',color_data);

    if length(nanunique(m.group))==1
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

% plot(tt,xx,'k');
ylabel({'Prob. choose','item on right'});

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
    RTvar = d.RT/1000;
    RTvar_model = m.RT;
end

if average_over_Ss_flag
    [tt,xx] = curva_media_hierarch(RTvar,d.dv,d.group,idx,0);
    terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data,'marker','o','linestyle','none','MarkerFaceColor',color_data);

    if length(nanunique(m.group))==1
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

%% split by last fix
p.next();


if average_over_Ss_flag

    if length(nanunique(m.group(:)))==1

        [tt,xx] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==1,0);
        h2(3) = plot(tt,xx,'color',color_data_last_fix(1,:));
        hold all
        [tt,xx] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==0,0);
        h2(4) = plot(tt,xx,'color',color_data_last_fix(2,:));

    else
        [tt,xx] = curva_media_hierarch(m.choice(:),m.dv(:),m.group(:),idx_m & m.focus_last(:)==1,0);
        [~,hl] = niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_model_last_fix(1,:),alpha);
%         set(hl,'LineStyle','--');


        [tt,xx] = curva_media_hierarch(m.choice(:),m.dv(:),m.group(:),idx_m & m.focus_last(:)==0,0);
        niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_model_last_fix(2,:),alpha);
    end

    [tt,xx] = curva_media_hierarch(d.choice,d.dv,d.group, idx & d.focus_last==1,0);
    terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data_points(1,:),'marker','o','linestyle','none','MarkerFaceColor',color_data_points(1,:));

    [tt,xx] = curva_media_hierarch(d.choice,d.dv,d.group, idx & d.focus_last==0,0);
    terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data_points(2,:),'marker','o','linestyle','none','MarkerFaceColor',color_data_points(2,:));

    if flag_compact==1 % testing - include the 1st plot
        [tt,xx] = curva_media_hierarch(d.choice,d.dv,d.group, idx,0);
        terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data,'marker','o','linestyle','none','MarkerFaceColor',color_data);
        [tt,xx] = curva_media_hierarch(m.choice(:),m.dv(:),m.group(:),idx_m,0);
        niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_model,alpha);

    end

else
    [tt,xx,ss] = curva_media(d.choice,d.dv,idx & d.focus_last==1,0);
    terrorbar(tt,xx,ss,'color',color_data_last_fix(1,:),'marker','.','linestyle','none');
    [tt,xx,ss] = curva_media(d.choice,d.dv,idx & d.focus_last==0,0);
    terrorbar(tt,xx,ss,'color',color_data_last_fix(2,:),'marker','.','linestyle','none');

    [tt,xx,ss] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==1,0);
    niceBars2(tt,xx,ss,color_model_last_fix(1,:),alpha);
    [tt,xx,ss] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==0,0);
    niceBars2(tt,xx,ss,color_model_last_fix(2,:),alpha);
end


ylabel({'Prob. choose','item on right'});


%% split by last fix and by SUM

s = d.vright + d.vleft;
sm = m.vright + m.vleft;
I = zeros(numel(s),2);
Im = zeros(numel(sm),2);

% median split by participant
u = nanunique(d.group);
for i=1:length(u)
    K = d.group==u(i) & idx==1;
    I(K,1) = s(K)<nanmedian(s(K));
    I(K,2) = s(K)>=nanmedian(s(K));
end

u = nanunique(m.group(:));
for i=1:length(u)
    K = m.group(:)==u(i) & idx_m==1;
    Im(K,1) = sm(K)<nanmedian(sm(K));
    Im(K,2) = sm(K)>=nanmedian(sm(K));
end


p.next();


if 0
    % in prep: P(last fixated item chosen) vs v_{fix last} - v_{other}
    
    % data
    last_fix_chosen = double(d.focus_last==d.choice);
    last_fix_chosen(isnan(d.focus_last) | isnan(d.choice)) = nan;
    dv_rel = d.dv;
    dv_rel(d.focus_last==0) = -1*dv_rel(d.focus_last==0);
    
    % model
    last_fix_chosen_m = double(m.focus_last(:)==m.choice(:));
    last_fix_chosen_m(isnan(m.focus_last(:)) | isnan(m.choice(:))) = nan;
    dv_rel_m = m.dv(:);
    dv_rel_m(m.focus_last(:)==0) = -1*dv_rel_m(m.focus_last(:)==0);

    % plot model
    for i=1:2
        [tt,xx] = curva_media_hierarch(last_fix_chosen_m,dv_rel_m,m.group(:),idx_m & Im(:,i)==1,0);
        [~,hl(i)] = niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_split_sum(i,:),alpha);
        hold all
    end

    % plot data
    for i=1:2
        [tt,xx] = curva_media_hierarch(last_fix_chosen, dv_rel, d.group, I(:,i)==1 & idx,0);
        h(i) = terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_split_sum(i,:),...
            'marker','o','linestyle','none','MarkerFaceColor',color_split_sum(i,:),...
                'MarkerEdgeColor',color_split_sum(i,:));
        hold all
    end


    ylabel({'Prob. choose','item fixated on last'});



else

lsty = {'--','-'};

if average_over_Ss_flag

    if length(nanunique(m.group(:)))==1

        for i=1:2
        
            [tt,xx] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==1 & Im(:,i)==1,0);
            h2(3) = plot(tt,xx,'color',color_data_last_fix(1,:),'linestyle',lsty{i});
            hold all
            [tt,xx] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==0 & Im(:,i)==1,0);
            h2(4) = plot(tt,xx,'color',color_data_last_fix(2,:),'linestyle',lsty{i});

        end
        

    else
        
        for i=1:2
            [tt,xx] = curva_media_hierarch(m.choice(:),m.dv(:),m.group(:),idx_m & m.focus_last(:)==1 & Im(:,i)==1,0);
            [~,hl(1)] = niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_model_last_fix(1,:),alpha);
    
            [tt,xx] = curva_media_hierarch(m.choice(:),m.dv(:),m.group(:),idx_m & m.focus_last(:)==0 & Im(:,i)==1,0);
            [~,hl(2)] = niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_model_last_fix(2,:),alpha);
            set(hl,'Linestyle',lsty{i});

        end

    end

    for i=1:2
        [tt,xx] = curva_media_hierarch(d.choice,d.dv,d.group, idx & d.focus_last==1 & I(:,i)==1,0);
        h(1) = terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data_points(1,:),'marker','o','linestyle','none','MarkerFaceColor',color_data_points(1,:),...
            'MarkerEdgeColor',color_data_points(1,:));
    
        [tt,xx] = curva_media_hierarch(d.choice,d.dv,d.group, idx & d.focus_last==0 & I(:,i)==1,0);
        h(2) = terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data_points(2,:),'marker','o','linestyle','none','MarkerFaceColor',color_data_points(2,:),...
            'MarkerEdgeColor',color_data_points(2,:));

        if i==1
            set(h,'MarkerFaceColor','w');
        end


    end
    

%     if flag_compact==1 % testing - include the 1st plot
%         [tt,xx] = curva_media_hierarch(d.choice,d.dv,d.group, idx,0);
%         terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data,'marker','o','linestyle','none','MarkerFaceColor',color_data);
%         [tt,xx] = curva_media_hierarch(m.choice(:),m.dv(:),m.group(:),idx_m,0);
%         niceBars2(tt,nanmean(xx,2),stderror(xx,2),color_model,alpha);
%     end

else

    for i=1:2
        [tt,xx,ss] = curva_media(d.choice,d.dv,idx & d.focus_last==1 & I(:,i)==1,0);
        terrorbar(tt,xx,ss,'color',color_data_last_fix(1,:),'marker','.','linestyle','none');
        [tt,xx,ss] = curva_media(d.choice,d.dv,idx & d.focus_last==0 & I(:,i)==1,0);
        terrorbar(tt,xx,ss,'color',color_data_last_fix(2,:),'marker','.','linestyle','none');
    
        [tt,xx,ss] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==1 & Im(:,i)==1,0);
        [hl(1)] = niceBars2(tt,xx,ss,color_model_last_fix(1,:),alpha);
        [tt,xx,ss] = curva_media(m.choice(:),m.dv(:),idx_m & m.focus_last(:)==0 & Im(:,i)==1,0);
        [hl(2)] = niceBars2(tt,xx,ss,color_model_last_fix(2,:),alpha);
        set(hl,'LineStyle',lsty{i});

    end
end


ylabel({'Prob. choose','item on right'});

end


%%

set(p.h_ax,'xtick',[-5:2:5]);
p.xlabel({'Value difference','(right - left)'},1:3);
p.xlabel({'Value difference','(chosen - other)'},4);

p.format('FontSize',12,'LineWidthPlot',1,'LineWidthAxes',0.5);

end
