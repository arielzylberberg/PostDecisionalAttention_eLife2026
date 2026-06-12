function p = do_plot_two_rows(d,m,flags)


% average_over_Ss_flag = 1;

%%

%%
idx = abs(d.dv)<=5;
idx_m = abs(m.dv)<=5;

%%
p = publish_plot(2,3);
set(gcf,'Position',[384  332  682  373]);
p.shrink(1:length(p.h_ax),0.8,0.8);
% p.displace_ax(7,-0.015,1);

% p.displace_ax(1:3,0.05,2);

%%

p_aux = do_plot_psychometric(d, m, idx, idx_m, flags.use_tot_fix_as_RT);
p.copy_from_ax(p_aux.h_ax(1),1);
p.copy_from_ax(p_aux.h_ax(2),2);
p.copy_from_ax(p_aux.h_ax(3),4);


%% residuals RT, magnitude effect

p_aux = do_calc_and_plot_magnitude_effect(d,m,idx,idx_m, flags.recalc_magnitude_effect);
p.copy_from_ax(p_aux.h_ax(1), 3);


%% late onset bias
p_aux = do_calc_and_plot_late_onset_bias(d, m, flags.use_tot_fix_as_RT_in_LOB_plot, flags.recalc_late_onset_bias);
p.copy_from_ax(p_aux.h_ax(1), 5);
p.copy_from_ax(p_aux.h_ax(2), 6);

same_ylim(p.h_ax([5,6]));
same_xscale(p.h_ax([5,6]));
set(p.h_ax(6),'ycolor','none');
% p.displace_ax(5,0.02,1);
p.displace_ax(6,-0.025,1);


%%
% p.format('FontSize',10,'LineWidthPlot',1,'LineWidthAxes',0.5,'MarkerSize',[12,5]);
p.format('FontSize',11,'LineWidthPlot',0.5,'LineWidthAxes',0.5,'MarkerSize',[12,5]);


% ht = p.letter_the_plots('show',[1,2,3,4,5]);
% set(ht,'FontSize',13);
% displace_ax(ht,-0.02,1);
% displace_ax(ht, 0.08,2);

set(p.h_ax([1,2,4]),'xtick',[-5:2:5]);
p.xlabel({'Value difference','(right - left)'},[1,2,4]);
p.ylabel('P(choose right item)',[1,4]);
p.ylabel('P(look at chosen item)',[5]);
p.xlabel({'Value sum','(right + left)'},3);


% p.xlabel({'Time from','stim. onset [s]'}, 5);

set(p.h_ax(3),'xtick',[0:5:20],'xticklabel',[0:5:20]);
set(p.h_ax(6),'xtick',[-1:0.2:0],'xticklabel',[-1:0.2:0]);

close_all_but(p.h_fig);

h = p.letter_the_plots('show',1:5);
set(h,'FontSize',14);

figfilename = 'fig_model_summary_two_rows';
p.append_to_pdf(figfilename,1,1);


end