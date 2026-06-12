function run_do_plot()

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

d = load('../data/data_krajbich2010.mat');

m = load('./sim_dat_as_exp');

flags.use_tot_fix_as_RT = 0;
flags.use_tot_fix_as_RT_in_LOB_plot = 1;

str = './aDDM_orig_params';

fig_str = 'aDDM, original parameters (Krajbich et al. 2010)';



m.dw = focus_to_dwells(m.focus, m.t_focus); % check if there a better way

%%

p = fn_run_plot_best(d, m, flags);

h = p.text_draw_fig(fig_str);
set(h,'FontSize',13);

saveas(p.h_fig,str);
p.append_to_pdf(str,1,1);



end


