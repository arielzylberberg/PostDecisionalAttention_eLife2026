function p = fn_run_plot_best_two_rows(d,m, flags)

%%
flags.recalc_late_onset_bias = 1; 
flags.recalc_magnitude_effect = 1;

idx = abs(d.dv)<=5;
idx_m = abs(m.dv)<=5;


%% prep fig 
p = publish_plot(2,5);
set(gcf,'Position',[252   410  1231   477]);


p.shrink(1:8,0.9,0.95);
p.delete_ax(10);
p.shrink([4,5],0.8,1);
p.displace_ax(5,-0.03,1);




% set(gcf,'Position',[506  208  859  768])
% 
% p.shrink(1:9,0.9,0.9);
% 
% rect = p.rect_from_axes(4:6);
% 
% num_axes = 4;
% separation = 0.04;
% dim = 1;
% p.new_axes_in_rect(rect,num_axes,separation,dim);
% p.delete_ax(4:6);
% 
% p.resort_axes();
% 
% p.shrink([5,6],0.8,1);
% p.displace_ax(5,0.05,1);



%% choice, RT and split_by_last

compact_flag = 1;
p_aux = do_plot_psychometric(d, m, idx, idx_m, flags.use_tot_fix_as_RT, compact_flag);
% p.copy_from_ax(p_aux.h_ax(1),1);
p.copy_from_ax(p_aux.h_ax(3),1);    
p.copy_from_ax(p_aux.h_ax(2),2,1);



%% residuals RT, magnitude effect

p_aux = do_calc_and_plot_magnitude_effect(d,m,idx,idx_m, flags.recalc_magnitude_effect);
p.copy_from_ax(p_aux.h_ax(1), 3,1);


%% late onset bias

p_aux = do_calc_and_plot_late_onset_bias(d, m, flags.use_tot_fix_as_RT_in_LOB_plot, flags.recalc_late_onset_bias);
p.copy_from_ax(p_aux.h_ax(1), 4);
p.copy_from_ax(p_aux.h_ax(2), 5,1);

% p.current_ax(4);
% ylabel({'Prob. of looking at','the chosen item'});

p.current_ax(4);
hold on
plot(xlim,[0.5,0.5],'k--');

p.current_ax(5);
hold on
plot(xlim,[0.5,0.5],'k--');



%% Magnitude effect on Last Fixation Bias

[pregre,pch,B,PVAL] = calc_and_plot_split_sum_value(d);
close(pch.h_fig);

a = get(pregre.h_ax,'children');
X = a(1).XData;
Y = a(1).YData;
S = a(1).YPositiveDelta;

[pregre_m,pch,B,PVAL] = calc_and_plot_split_sum_value(m);
close(pch.h_fig);

a = get(pregre_m.h_ax,'children');

XM = a(1).XData;
YM = a(1).YData;
SM = a(1).YPositiveDelta;

figure(p.h_fig);
p.current_ax(6);

c = get_colores();
terrorbar(X,Y,S,'marker','o','color','k','LineStyle','none','markerfacecolor','k','markeredgecolor','k');


hold all; 
niceBars2(XM, YM, SM, c.model,0.4);

ylim([-0.5, 3.5]); 

ylabel('Influence last fix. on choice (\beta)');
% xlabel('r_{left} + r_{right}');
xlabel({'Overall value','(left + right)'})

%% Delta dwell time consistent and inconsistent


if nanmean(d.RT)>500 % in miliseconds or seconds?
    cte = 1000;
else
    cte = 1;
end

att = motionenergy.remove_post_decision_samples(d.focus,d.t_focus(1,:),d.RT);
delta_gaze = sum(att==1,2) - sum(att==0,2);
dt = d.t_focus(1,2) - d.t_focus(1,1);
delta_gaze = dt * nansum(delta_gaze,2) / cte; % in seconds
[paux, Od] = dwell_advantage_vs_RT_split_by_accuracy(delta_gaze, d.RT, d.choice, d.dv, d.group);

% [paux, Od] = dwell_advantage_vs_RT_split_by_accuracy(d.t_focus(1,:)/1000, d.focus, d.RT/1000, d.choice, d.vleft, d.vright, d.group);


att = motionenergy.remove_post_decision_samples(m.focus,m.t_focus,m.RT);
delta_gaze = sum(att==1,2) - sum(att==0,2);
dt = m.t_focus(2) - m.t_focus(1);
delta_gaze = dt * nansum(delta_gaze,2); % in seconds
[paux, Om] = dwell_advantage_vs_RT_split_by_accuracy(delta_gaze, m.RT, m.choice, m.dv, m.group);


colores = movshon_colors(3);

figure(p.h_fig);
p.current_ax(7);

clear hl
hl(1) = terrorbar(Od.correct.t,Od.correct.x,Od.correct.s,'color',colores(1,:),'marker','o','markerfacecolor',colores(1,:),'linestyle','none');
hold all
hl(2) = terrorbar(Od.error.t,Od.error.x,Od.error.s,'color',colores(2,:),'marker','o','markerfacecolor',colores(2,:),'linestyle','none');

hold all
niceBars2(Om.correct.t,Om.correct.x,Om.correct.s,colores(1,:),0.4);
hold all
niceBars2(Om.error.t,Om.error.x,Om.error.s,colores(2,:),0.4);

ylim([-0.2, 0.6]); 
xlim([0.5, 5.5]);

% legend_color({'Consistent choice','Inconsistent choice'}, hl);
ht(1) = text(0.25,0.54,'Consistent choices','color',colores(1,:),'horizontalalignment','left');
ht(2) = text(0.25,0.46,'Inconsistent choices','color',colores(2,:),'horizontalalignment','left');

hold on
p.current_ax(5);
plot(xlim,[0,0],'k--');

xlabel('Response time [s]');
ylabel('\Delta gaze bias [s]');

%% choice vs delta dwell

p_aux = plot_choice_vs_delta_dwell(d,m);
p.copy_from_ax(p_aux.h_ax(1), 8);

%% p choose item looked at first vs first dwell duration
p_aux = plot_first_fix_dur_vs_choice(d,m);
p.copy_from_ax(p_aux.h_ax(1), 9);

%% formatting

close_all_but(p.h_fig);


same_ylim(p.h_ax([4,5]));
set(p.h_ax(4),'xlim',[0,0.5],'xtick',[0,0.3],'xticklabel',[0,0.3]);
set(p.h_ax(5),'xlim',[-0.8,0],'xtick',[-0.6,-0.3,0],'xticklabel',[-0.6,-0.3,0]);
same_xscale(p.h_ax([4,5]));
p.displace_ax(5,-0.04,1);
set(p.h_ax(5),'ycolor','none');


% p.format('FontSize',10,'LineWidthPlot',1,'LineWidthAxes',0.5);
p.format('MarkerSize',[12,4],'FontSize',8);
% set(hl,'LineWidth',1);
% set(h2,'LineWidth',1.5);

set(ht,'FontSize',8);

%set(p.h_ax(4),'xtick',[-1:0.25:0],'xticklabel',[-1:0.25:0]);



% set(p.h_ax([1:2]),'xtick',[-5:2:5]);
% p.xlabel({'Value difference','(left - right)'},1:3);
% set(p.h_ax(4),'xtick',[0:5:20],'xticklabel',[0:5:20]);
% set(p.h_ax(5),'xtick',[0:0.25:0.75]);
% 
% set(p.h_ax(7),'xtick',[-1:1:1]);
% set(p.h_ax(8),'xtick',[0:0.25:1.25]);
% 
% p.displace_ax(6,-0.035,1);

h = p.letter_the_plots('show',[1:4,6:9]);
set(h,'FontSize',11);
displace_ax(h,-0.03,1);
displace_ax(h,-0.013,2);

p.offset_axes();

end








% p.append_to_pdf(figfilename,1,1);