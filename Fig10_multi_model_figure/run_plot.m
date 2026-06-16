function run_plot()
% Generates the multi-model comparison figure from precomputed data.
%
% Loads precomputed.mat (produced by run_precompute.m) and builds a
% N-row × 7-panel figure. Each row is one model; columns are:
%   1: Choice psychometric — overall + split by last fixation
%   2: Chronometric (RT vs value difference)
%   3: Magnitude effect (RT residuals vs sum value)
%   4: Last-fixation influence on choice (beta vs sum value)
%   5: Delta-dwell time split by accuracy
%   6: Choice vs delta-dwell
%   7: First-fixation duration vs choice
%
% USAGE:
%   run_plot()
%
% Requires: precomputed.mat (run run_precompute.m to generate)
% Output:   fig_multi_model.pdf

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

%% load precomputed quantities
load('precomputed.mat', 'dat', 'M');

N_ROWS   = numel(M);
N_PANELS = 7;
N = N_PANELS * N_ROWS;

%% build figure
p = publish_plot(N_ROWS, N_PANELS);
% set(gcf, 'Position', [50, 50, 1232, 190 * N_ROWS]);
% set(gcf,'Position',[354    59  1164   139 * N_ROWS]);
% set(gcf,'Position',[248    59  1270   834]);
set(gcf,'Position',[248    59  1270   952]);
p.shrink(1:(N_ROWS * N_PANELS), 0.9, 1);

c       = get_colores();
colores = movshon_colors(3);

for irow = 1:N_ROWS
    r   = M(irow);
    off = (irow - 1) * N_PANELS;

    %% Panel 1: combined psychometric (overall + split by last fixation)
    figure(p.h_fig);
    p.current_ax(off + 1);
    % data: split by last fixation
    terrorbar(dat.psych_last1.t, dat.psych_last1.x, dat.psych_last1.s, ...
        'color', colores(1,:), 'marker', 'o', ...
        'markerfacecolor', colores(1,:), 'markeredgecolor', colores(1,:), ...
        'linestyle', 'none');
    hold all;
    terrorbar(dat.psych_last0.t, dat.psych_last0.x, dat.psych_last0.s, ...
        'color', colores(2,:), 'marker', 'o', ...
        'markerfacecolor', colores(2,:), 'markeredgecolor', colores(2,:), ...
        'linestyle', 'none');
    % data: overall
    terrorbar(dat.psych_all.t, dat.psych_all.x, dat.psych_all.s, ...
        'color', c.data, 'marker', 'o', ...
        'markerfacecolor', c.data, 'markeredgecolor', c.data, ...
        'linestyle', 'none');
    % model: split by last fixation
    niceBars2(r.psych_last1.t, r.psych_last1.x, r.psych_last1.s, colores(1,:), 0.4);
    niceBars2(r.psych_last0.t, r.psych_last0.x, r.psych_last0.s, colores(2,:), 0.4);
    % model: overall
    niceBars2(r.psych_all.t, r.psych_all.x, r.psych_all.s, c.model, 0.4);
    % plot(xlim, [0.5, 0.5], 'k:');
    ylim([0, 1]);
    xlabel('\Deltar');
    ylabel('P(right)');

    %% Panel 2: chronometric (RT vs value difference)
    chron_dat = dat.chron;
    if r.use_tot_fix_as_RT, chron_dat = dat.chron_totfix; end
    figure(p.h_fig);
    p.current_ax(off + 2);
    terrorbar(chron_dat.t, chron_dat.x, chron_dat.s, ...
        'color', c.data, 'marker', 'o', ...
        'markerfacecolor', c.data, 'markeredgecolor', c.data, ...
        'linestyle', 'none');
    hold all;
    niceBars2(r.chron.t, r.chron.x, r.chron.s, c.model, 0.4);
    xlabel('\Deltar');
    if r.use_tot_fix_as_RT
        ylabel('Total fixation time [s]');
    else
        ylabel('RT [s]');
    end

    %% Panel 3: magnitude effect (RT residuals vs sum value)
    figure(p.h_fig);
    p.current_ax(off + 3);
    terrorbar(dat.mageff.t, dat.mageff.x, dat.mageff.s, ...
        'color', c.data, 'marker', 'o', ...
        'markerfacecolor', c.data, 'markeredgecolor', c.data, ...
        'linestyle', 'none');
    hold all;
    niceBars2(r.mageff.t, r.mageff.x, r.mageff.s, c.model, 0.4);
    % plot(xlim, [0, 0], 'k:');
    xlabel('\Sigmar');
    ylabel('RT residuals [s]');

    %% Panel 4: last-fixation influence on choice (beta vs sum value)
    figure(p.h_fig);
    p.current_ax(off + 4);
    terrorbar(dat.beta.x, dat.beta.y, dat.beta.s, ...
        'marker', 'o', 'color', c.data, ...
        'LineStyle', 'none', 'markerfacecolor', c.data, 'markeredgecolor', c.data);
    hold all;
    niceBars2(r.beta.x, r.beta.y, r.beta.s, c.model, 0.4);
    plot(xlim, [0, 0], 'k:');
    ylim([-0.5, 3.5]);
    set(gca, 'xtick', 0:5:20, 'xticklabel', 0:5:20);
    xlabel('\Sigmar');
    ylabel('\beta_{last fix}');

    %% Panel 5: delta-dwell split by accuracy
    figure(p.h_fig);
    p.current_ax(off + 5);
    terrorbar(dat.ddwell.correct.t, dat.ddwell.correct.x, dat.ddwell.correct.s, ...
        'color', colores(1,:), 'marker', 'o', ...
        'markerfacecolor', colores(1,:), 'linestyle', 'none');
    hold all;
    terrorbar(dat.ddwell.error.t, dat.ddwell.error.x, dat.ddwell.error.s, ...
        'color', colores(2,:), 'marker', 'o', ...
        'markerfacecolor', colores(2,:), 'linestyle', 'none');
    niceBars2(r.ddwell.correct.t, r.ddwell.correct.x, r.ddwell.correct.s, colores(1,:), 0.4);
    niceBars2(r.ddwell.error.t,   r.ddwell.error.x,   r.ddwell.error.s,   colores(2,:), 0.4);
    plot(xlim, [0, 0], 'k:');
    axis tight;
    ylim([-0.2, 0.6]);
    xlim([0.5,6]);
    xlabel('RT [s]');
    ylabel('\DeltaDwell [s]');

    %% Panel 6: choice vs delta-dwell
    figure(p.h_fig);
    p.current_ax(off + 6);
    terrorbar(dat.chvsdw.t, dat.chvsdw.x, dat.chvsdw.s, ...
        'color', c.data, 'marker', 'o', ...
        'markerfacecolor', c.data, 'markeredgecolor', c.data, ...
        'linestyle', 'none');
    hold all;
    niceBars2(r.chvsdw.t, r.chvsdw.x, r.chvsdw.s, c.model, 0.4);
    plot(xlim, [0.5, 0.5], 'k:');
    xlabel('\DeltaDwell [s]');
    ylabel('P(right)');

    %% Panel 7: first-fixation duration vs choice
    figure(p.h_fig);
    p.current_ax(off + 7);
    terrorbar(dat.ffd.t, dat.ffd.x, dat.ffd.s, ...
        'color', c.data, 'marker', 'o', ...
        'markerfacecolor', c.data, 'markeredgecolor', c.data, ...
        'linestyle', 'none');
    hold all;
    niceBars2(r.ffd.t, r.ffd.x, r.ffd.s, c.model, 0.4);
    plot(xlim, [0.5, 0.5], 'k:');
    xlabel('First Dwell Dur. [s]');
    ylabel('P(choose 1st item)');
end

%% global formatting
p.format('MarkerSize', [8, 3], 'FontSize', 7, 'LineWidthPlot', 0.75, 'LineWidthAxes', 0.5);

for irow = 1:N_ROWS
    off = (irow - 1) * N_PANELS;
    set(p.h_ax(off + [1, 2]), 'xtick', -5:5:5);
end
set(p.h_ax(5:N_PANELS:end), 'xtick', 0:2:4);   % choice vs delta-dwell (panel 6)
set(p.h_ax(6:N_PANELS:end), 'xtick', -1:1:1);   % choice vs delta-dwell (panel 6)
set(p.h_ax(7:N_PANELS:end), 'xtick', 0:0.5:1.0);   % first fix dur          (panel 7)

%% shift all panels right to open up a left margin for row labels
left_margin = 0.07;   % fraction of figure width reserved for row labels
for ii = 1:numel(p.h_ax)
    pos    = get(p.h_ax(ii), 'Position');
    pos(1) = left_margin + pos(1) * (1 - left_margin);
    pos(3) = pos(3) * (1 - left_margin);
    set(p.h_ax(ii), 'Position', pos);
end

%% column letters (A–G) above each panel type — annotation in figure coords
column_symbols = {'I', 'II', 'III', 'IV', 'V', 'VI', 'VII'};
for icol = 1:N_PANELS
    ax  = p.h_ax(icol);
    pos = get(ax, 'Position');   % [x, y, w, h] in figure-normalised coords
    top = pos(2) + pos(4);       % y of the top edge of this axes
    annotation('textbox', ...
        [pos(1), top + 0.004, pos(3), 0.03], ...
        'String', column_symbols{icol}, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontWeight', 'bold', 'FontSize', 9, ...
        'EdgeColor', 'none', ...
        'FitBoxToText', 'off');
end

%% row labels (Roman numeral + model name) in the left margin
row_symbols = {'A','B','C','D','E','F','G'};
for irow = 1:N_ROWS
    off = (irow - 1) * N_PANELS;
    ax  = p.h_ax(off + 1);
    pos = get(ax, 'Position');   % [x, y, w, h] in figure-normalised coords
    lbl = {[row_symbols{irow}, ':'], M(irow).label};
    annotation('textbox', ...
        [pos(1)-0.1, pos(2), left_margin, pos(4)], ...
        'String', lbl, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'middle', ...
        'FontWeight', 'bold', 'FontSize', 7, ...
        'EdgeColor', 'none', ...
        'FitBoxToText', 'off');
end

drawnow;

set(p.h_ax(1:N-N_ROWS-1),'xticklabel','');
for i=1:(N-N_ROWS-1)
    p.current_ax(i);
    xlabel('');
end
p.offset_axes;
p.append_to_pdf('fig_multi_model', 1, 1);

end
