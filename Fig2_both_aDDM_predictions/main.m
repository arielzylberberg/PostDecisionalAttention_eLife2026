function main()
% Generates Figure 1: aDDM predictions for the last-fixation bias and the
% dwell-time advantage split by choice accuracy.
%
% Panel A: Association between last-fixation focus and choice as a function
%          of overall value (sum of left and right ratings).
%
% Panel B: Dwell-time advantage (chosen minus unchosen) as a function of
%          response time, split by consistent vs. inconsistent choices.
%
% USAGE:
%   main()
%
% Requires: sim_dat_as_exp.mat (aDDM simulation, same folder)
% Output:   fig_aDDM_pred.pdf

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

%% load aDDM simulation data
d = load('./sim_dat_as_exp.mat');
if isfield(d, 'm')
    d = d.m;
end

%% Panel A: last-fixation bias vs. overall value
[pregre, ~, ~, ~] = calc_and_plot_split_sum_value(d);
drawnow;

%% Panel B: delta-dwell time split by accuracy
t_focus = d.t_focus(1, :);
focus   = d.focus;
RT      = d.RT;
choice  = d.choice;
dv      = d.dv;
group   = d.group;

att        = motionenergy.remove_post_decision_samples(focus, t_focus, RT);
dt         = t_focus(2) - t_focus(1);
delta_gaze = dt * nansum(sum(att == 1, 2) - sum(att == 0, 2), 2);  % seconds

[~, O] = dwell_advantage_vs_RT_split_by_accuracy(delta_gaze, RT, choice, dv, group);

%% compose figure
p = publish_plot(1, 2);
set(gcf, 'Position', [302, 288, 845, 327]);

p.copy_from_ax(pregre.h_ax, 1, 1);

p.current_ax(2);
colores = movshon_colors(2);

dataLine(1) = terrorbar(O.correct.t, O.correct.x, O.correct.s, ...
    'color', colores(1,:), 'marker', 'o', ...
    'markerfacecolor', colores(1,:), 'markeredgecolor', 'w');
hold all
dataLine(2) = terrorbar(O.error.t, O.error.x, O.error.s, ...
    'color', colores(2,:), 'marker', 'o', ...
    'markerfacecolor', colores(2,:), 'markeredgecolor', 'w');
axis tight
plot(xlim, [0, 0], 'k--');

xlabel('Response time [s]');
ylabel({'\DeltaDwell Time [s]', '(chosen - unchosen)'});
htext = legend_color({'consistent choices', 'inconsistent choices'}, dataLine(1,:));

%% formatting
p.format('FontSize', 11, 'MarkerSize', [9, 9], 'LineWidthPlot', 1, 'LineWidthAxes', 0.5);
set(htext, 'FontSize', 10);
p.offset_axes();

ht = p.letter_the_plots('show', [1, 2]);
set(ht, 'FontSize', 15);

p.shrink(1:2, 0.9, 0.9);
p.displace_ax(2, 0.05, 1);
drawnow;

%% save
p.append_to_pdf('fig_aDDM_pred', 1, 1);

end
