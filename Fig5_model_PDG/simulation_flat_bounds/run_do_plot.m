function run_do_plot()
% Plots the PDG model (flat bounds) predictions against behavioral data.

addpath('../../functions/');
addpath(genpath('../../matlab_functions/'));

%%
d = load('../../data/data_krajbich2010.mat');

m = load('./model_sim.mat');
m = m.m;

flags.use_tot_fix_as_RT            = 0;
flags.use_tot_fix_as_RT_in_LOB_plot = 0;

fig_str = 'PDG model (flat bounds)';

m.dw = focus_to_dwells(m.focus, m.t_focus);

%%
p = fn_run_plot_best(d, m, flags);

% h = p.text_draw_fig(fig_str);
% set(h, 'FontSize', 13);

p.append_to_pdf('fig_PDG_flat_bounds', 1, 1);

end
