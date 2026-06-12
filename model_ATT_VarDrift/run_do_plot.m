function run_do_plot(flag)
% Plots the ATT-VarDrift model predictions against behavioral data.
%
% USAGE:
%   run_do_plot()    % flat bounds (default)
%   run_do_plot(2)   % flat bounds
%
% Must run run_eval_best_resample_ATT_nreps.m first.

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

if nargin == 0
    run_do_plot(2);
    return
end

%%
switch flag
    case 2
        m       = load('./fits_flat_bounds/model_fits_resample_ATT.mat');
        extra   = '_flat_bounds';
        fig_str = 'ATT model (intra-decisional attention, inter-trial drift variability, flat bounds)';
end

%%
d = load('../data/data_krajbich2010.mat');

flags.use_tot_fix_as_RT             = 0;
flags.use_tot_fix_as_RT_in_LOB_plot = 1;

m.dw = focus_to_dwells(m.focus, m.t_focus);

%%
p = fn_run_plot_best(d, m, flags);

h = p.text_draw_fig(fig_str);
set(h, 'FontSize', 13);

figname = ['fig_ATT_VarDrift', extra];
p.append_to_pdf(figname, 1, 1);

end
