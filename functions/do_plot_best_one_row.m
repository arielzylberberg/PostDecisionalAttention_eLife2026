function p = do_plot_best_one_row(d,m,flags)


% average_over_Ss_flag = 1;

%%

%%
idx = abs(d.dv)<=5;
idx_m = abs(m.dv)<=5;

%%
p = publish_plot(1,7);
% set(gcf,'Position',[89   650  1519   190]);
set(gcf,'Position',[89   635  1519   205]);
% set(gcf,'Position',[121   615  1443   184]); % nice too
p.shrink(1:7,1,0.8);
p.shrink(1:7,0.9,0.9);
p.displace_ax(1:7,0.15,2);

% p.resize_horizontal(1:7,[1,1,1,1,0.7,0.7,1],0.04);
p.resize_horizontal(1:7,[1,1,1,1,0.7,0.7,1],0.034);

% p.displace_ax(7,-0.015,1);

%%

p_aux = do_plot_psychometric(d, m, idx, idx_m, flags.use_tot_fix_as_RT);
% p_aux = do_plot_psychometric_extra(d, m, idx, idx_m, flags.use_tot_fix_as_RT); % in prep, to show also the split by sum
p.copy_from_ax(p_aux.h_ax(1),1);
p.copy_from_ax(p_aux.h_ax(2),3);
p.copy_from_ax(p_aux.h_ax(3),2);


%% residuals RT, magnitude effect

p_aux = do_calc_and_plot_magnitude_effect(d,m,idx,idx_m, flags.recalc_magnitude_effect);
p.copy_from_ax(p_aux.h_ax(1), 4);


%% late onset bias
p_aux = do_calc_and_plot_late_onset_bias(d, m, flags.use_tot_fix_as_RT_in_LOB_plot, flags.recalc_late_onset_bias);
p.copy_from_ax(p_aux.h_ax(1), 5);
p.copy_from_ax(p_aux.h_ax(2), 6);

same_ylim(p.h_ax([5,6]));
same_xscale(p.h_ax([5,6]));
set(p.h_ax(6),'ycolor','none');
% p.displace_ax(5,0.02,1);
p.displace_ax(6,-0.025,1);

%% delta dwell

% [~, O(1)] = dwell_advantage_vs_RT_split_by_accuracy(m.t_focus, m.focus, m.RT, m.choice, m.values(:,1), m.values(:,2), m.group, 0 , flags.recalc_dwell);
% [~, O(2)] = dwell_advantage_vs_RF_split_by_accuracy(d.t_focus(1,:)/1000, d.focus, d.RT/1000, d.choice, d.vleft, d.vright, d.group, 0 );

[~, O(1)] = dwell_advantage_vs_RT_split_by_accuracy(m.t_focus, m.focus, m.RT, m.choice, m.values(:,1), m.values(:,2), m.group, 0);
% [p, out] = dwell_advantage_vs_RT_split_by_accuracy(t, ATT, RT, choice, vleft, vright, group, do_plot_flag)

p.current_ax(7);
clear dataLine
colores = movshon_colors(3);

terrorbar(O.correct.t,O.correct.x,O.correct.s,'color',colores(1,:),'marker','o','LineStyle','-','markerfacecolor',colores(1,:));
hold all
terrorbar(O.error.t,O.error.x,O.error.s,'color',colores(2,:),'marker','o','LineStyle','-','markerfacecolor',colores(2,:));
plot(xlim,[0,0],'k--');

ylabel('\Delta Dwell time [s]');
xlabel('Response time [s]');

% set(dataLine,'LineWidth',1,'Marker','.','MarkerSize',15)

%%
% p.format('FontSize',10,'LineWidthPlot',1,'LineWidthAxes',0.5,'MarkerSize',[12,5]);
p.format('FontSize',11,'LineWidthPlot',0.5,'LineWidthAxes',0.5,'MarkerSize',[12,5]);


ht = p.letter_the_plots('show',[1,2,3,4,5,7]);
set(ht,'FontSize',13);
displace_ax(ht,-0.02,1);
displace_ax(ht, 0.08,2);

set(p.h_ax([1:3]),'xtick',[-5:2:5]);
p.xlabel({'Value difference','(right - left)'},1:3);
p.ylabel('P(choose right item)',[1,2]);
p.ylabel('P(look at chosen item)',[5]);
p.xlabel({'Value sum','(right + left)'},4);
p.ylabel({'\Delta dwell time [s]','(chosen - unchosen)'},7);

% p.xlabel({'Time from','stim. onset [s]'}, 5);

set(p.h_ax(4),'xtick',[0:5:20],'xticklabel',[0:5:20]);
set(p.h_ax(6),'xtick',[-1:0.2:0],'xticklabel',[-1:0.2:0]);

close_all_but(p.h_fig);

figfilename = 'fig_model_summary_one_row';
p.append_to_pdf(figfilename,1,1);

%%




end