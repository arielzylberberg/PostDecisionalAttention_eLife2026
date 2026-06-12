function run_do_plot(flag)
% Plots the ATT model predictions against behavioral data.
%
% Loads the pre-computed simulation output and generates the multi-panel
% summary figure comparing model and data on choice, RT, magnitude effect,
% and late-onset bias.
%
% USAGE:
%   run_do_plot()    % runs both variants
%   run_do_plot(1)   % collapsing bounds
%   run_do_plot(2)   % flat bounds
%
% Must run run_eval_best_resample_ATT_nreps.m first.

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

if nargin == 0
    % run_do_plot(1);
    run_do_plot(2);
    return
end

%%
switch flag
    case 1
        m       = load('./fits/model_fits_resample_ATT.mat');
        extra   = '';
        fig_str = 'ATT model (multiplicative intra-decisional attention)';
    case 2
        m       = load('./fits_flat_bounds/model_fits_resample_ATT.mat');
        extra   = '_flat_bounds';
        fig_str = 'ATT model (multiplicative intra-decisional attention, flat bounds)';
end

%%
d = load('../data/data_krajbich2010.mat');

flags.use_tot_fix_as_RT            = 0;
flags.use_tot_fix_as_RT_in_LOB_plot = 1;

m.dw = focus_to_dwells(m.focus, m.t_focus);

%%
p = fn_run_plot_best(d, m, flags);

h = p.text_draw_fig(fig_str);
set(h, 'FontSize', 13);

figname = ['fig_ATT', extra];
p.append_to_pdf(figname, 1, 1);

end
