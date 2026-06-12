function main()
% Plots the Jang & Drugowitsch (2021) model predictions against behavioral data.
%
% Generates the multi-panel summary figure comparing model and data on
% choice, RT, magnitude effect, and late-onset bias.
%
% USAGE:
%   main()
%
% Requires:
%   ../data/data_krajbich2010.mat         (behavioral data)
%   ../data/data_Drugowitsch2021.mat (model simulation)
% Output: fig_Drugowitsch2021.pdf

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

%% load data
d = load('../data/data_krajbich2010.mat');
m = load('../data/data_Drugowitsch2021.mat');

flags.use_tot_fix_as_RT             = 0;
flags.use_tot_fix_as_RT_in_LOB_plot = 0;

m.dw = focus_to_dwells(m.focus, m.t_focus);

%% plot
p = fn_run_plot_best(d, m, flags);

h = p.text_draw_fig('Jang & Drugowitsch (2021)');
set(h, 'FontSize', 14);

p.append_to_pdf('fig_Drugowitsch2021', 1, 1);

end
