function main()
% Plots the dwell-time advantage (chosen minus unchosen) as a function of
% response time, split by consistent vs. inconsistent choices, across
% seven datasets.
%
% Panels:
%   1: Krajbich et al. (2010)
%   2: Smith & Krajbich (2018)
%   3: Chen & Krajbich (2016)
%   4: Gwinn & Krajbich (2016)
%   5: Folke et al. (2016)
%   6: Sepulveda et al. (2020) — choose preferred
%   7: Sepulveda et al. (2020) — choose non-preferred
%
% USAGE:
%   main()
%
% Requires:
%   ../data/data_krajbich2010.mat          (Krajbich 2010)
%   ../data/MultAddLastFix.mat       (datasets D2, D3, D4)
%   ../data/data_Folke_2alt.mat      (Folke et al. 2016)
%   ../data/sepulveda2020_food.mat   (Sepulveda et al. 2020)
% Output: fig_dwell_behav.pdf

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

str = {'Krajbich et al. (2010)', ...
       'Smith & Krajbich (2018)', ...
       'Chen & Krajbich (2016)', ...
       'Gwinn & Krajbich (2016)', ...
       'Folke et al. (2016)', ...
       {'Sepulveda et al. (2020)', '(choose preferred)'}, ...
       {'Sepulveda et al. (2020)', '(choose non-pref.)'}};

%% Dataset 1: Krajbich 2010
d = load('../data/data_krajbich2010.mat');
[~, O] = dwell_advantage_vs_RT_split_by_accuracy( ...
    d.delta_dwell, d.RT, d.choice == 1, d.vleft - d.vright, d.group, 0);

%% Datasets 2–4: other Krajbich datasets
D = load('../data/MultAddLastFix.mat');
uni_data = [2, 3, 4];

for i = 1:length(uni_data)
    idata = uni_data(i);
    d = D.(['D', num2str(idata)]);
    d = structfun(@double, d, 'UniformOutput', false);

    [~, O(end+1)] = dwell_advantage_vs_RT_split_by_accuracy( ...
        (d.DwellLeft - d.DwellRight) / 1000, ...
        d.RT / 1000, d.LeftRight == 1, ...
        d.ValueLeft - d.ValueRight, d.SubjectNumber, 0);
end

%% Dataset 5: Folke et al. (2016)
d = load('../data/data_Folke_2alt.mat');
[~, O(end+1)] = dwell_advantage_vs_RT_split_by_accuracy( ...
    d.data.Diff_Dwell_Time / 1000, d.data.RT, d.data.Choice, ...
    d.data.Left_Value - d.data.Right_Value, d.data.Participant, 0);

%% Datasets 6–7: Sepulveda et al. (2020)
dat = load('../data/sepulveda2020_food.mat');
for j = 1:2
    d  = dat.dat(j);
    dw = d.dwell_time_left - d.dwell_time_right;
    [~, O(end+1)] = dwell_advantage_vs_RT_split_by_accuracy( ...
        dw / 1000, d.rt / 1000, d.choices == 0, ...
        d.values(:,1) - d.values(:,2), d.group, 0);
end

N = length(O);

%% p-values
PVAL       = nan(N, 1);
p_one_sided = nan(N, 1);
p_two_sided = nan(N, 1);
for i = 1:N
    k              = O(i).idx_var.consistency;
    PVAL(i)        = O(i).stats.p(k);
    p_one_sided(i) = normcdf(O(i).stats.t(k));
    p_two_sided(i) = 2 * (1 - normcdf(abs(O(i).stats.t(k))));
end
save pvalues PVAL p_one_sided p_two_sided;

%% figure
p = publish_plot(2, ceil(N/2));
set(gcf, 'Position', [222, 367, 1105, 521]);
p.displace_ax(1:4, 0.02, 2);
p.shrink(1:length(p.h_ax), 1, 0.9);

p.delete_ax(5);
p.displace_ax(1, -0.25, 2);
p.displace_ax(1, -0.06, 1);
p.shrink(1, 1.1, 1.1);

colores   = movshon_colors(2);
dataLine  = [];
for i = 1:N
    p.next();
    dataLine(i,1) = terrorbar(O(i).correct.t, O(i).correct.x, O(i).correct.s, ...
        'color', colores(1,:), 'marker', 'o', ...
        'markerfacecolor', colores(1,:), 'markeredgecolor', 'w');
    hold all
    dataLine(i,2) = terrorbar(O(i).error.t, O(i).error.x, O(i).error.s, ...
        'color', colores(2,:), 'marker', 'o', ...
        'markerfacecolor', colores(2,:), 'markeredgecolor', 'w');
    axis tight
    plot(xlim, [0, 0], 'k--');
    h(i) = title(str{i});
    xlabel('Response time [s]');
end

same_ylim(p.h_ax);

htext = legend(dataLine(1,:),{'consistent choices', 'inconsistent choices'});

p.current_ax(1);
ylabel({'\DeltaDwell Time [s]', '(chosen - unchosen)'});
p.current_ax(2);
ylabel({'\DeltaDwell Time [s]', '(chosen - unchosen)'});
p.current_ax(5);
ylabel({'\DeltaDwell Time [s]', '(chosen - unchosen)'});

p.format('FontSize', 10, 'MarkerSize', [7, 7], 'LineWidthPlot', 1);
set(h, 'FontSize', 10);

p.delete_empty_plots();
p.offset_axes();

set(p.h_ax([3,4,6,7]), 'yticklabel', '');

ht = p.letter_the_plots();
set(ht, 'FontSize', 13);
displace_ax(ht, -0.01, 1);
displace_ax(ht,  0.02, 2);

drawnow;

%% save
p.append_to_pdf('fig_dwell_behav', 1, 1);


end
