function main()
% Plots the Callaway et al. (2021) model predictions against behavioral data.
%
% Generates the multi-panel summary figure comparing model and data on
% choice, RT, magnitude effect, and late-onset bias.
%
% USAGE:
%   main()
%
% Requires:
%   ../data/data_krajbich2010.mat       (behavioral data)
%   ../data/data_Callaway2021.mat (model simulation)
% Output: fig_Callaway2021.pdf

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

%% load data
d = load('../data/data_krajbich2010.mat');
m = load('../data/data_Callaway2021.mat');

flags.use_tot_fix_as_RT             = 1;
flags.use_tot_fix_as_RT_in_LOB_plot = 1;

m.dw = focus_to_dwells(m.focus, m.t_focus);

%% plot
p = fn_run_plot_best(d, m, flags);

h = p.text_draw_fig('Callaway et al. (2021)');
set(h, 'FontSize', 14);

p.append_to_pdf('fig_Callaway2021', 1, 1);

end
