function main()
% Plots the association between last-fixation focus and choice as a
% function of overall value (\Sigma r), across four datasets.
%
% Panels (left to right):
%   A: Krajbich et al. (2010)
%   B: Smith & Krajbich (2018)
%   C: Chen & Krajbich (2016)
%   D: Gwinn & Krajbich (2016)
%
% USAGE:
%   main()
%
% Requires:
%   ../data/data_krajbich2010.mat      (Krajbich 2010)
%   ../data/MultAddLastFix.mat   (datasets D2, D3, D4)
% Output: fig_effect_last.pdf

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

%%
n = 4;
p = publish_plot(1, n);
set(gcf, 'Position', [219, 483, 1109, 238]);

data_names = {'Krajbich et al. (2010)', ...
              'Smith & Krajbich (2018)', ...
              'Chen & Krajbich (2016)', ...
              'Gwinn & Krajbich (2016)'};

%% Panel A: Krajbich 2010
d = load('../data/data_krajbich2010.mat');
[pregre, pch, ~, PVAL] = calc_and_plot_split_sum_value(d);
p.copy_from_ax(pregre.h_ax, 1, 1);
close(pch.h_fig);
PVALUES = PVAL(2);
drawnow;

%% Panels B–D: other Krajbich datasets
D = load('../data/MultAddLastFix.mat');
uni_data = [2, 3, 4];

for i = 1:length(uni_data)
    idata = uni_data(i);
    d = D.(['D', num2str(idata)]);
    d = structfun(@double, d, 'UniformOutput', false);

    e.vleft      = d.ValueLeft;
    e.vright     = d.ValueRight;
    e.focus_last = d.ROI == 1;
    e.choice     = d.LeftRight == 1;
    e.group      = d.SubjectNumber;
    e.dv         = d.ValueLeft - d.ValueRight;

    [pregre, pch, ~, PVAL] = calc_and_plot_split_sum_value(e);
    p.copy_from_ax(pregre.h_ax, 1 + i, 1);
    close(pch.h_fig);
    PVALUES(end+1) = PVAL(2);
    drawnow;
end

%% formatting
for i = 1:n
    ht(i) = p.text_draw(i, data_names{i}, 'center');
end

h = p.letter_the_plots('show', 1:4);
displace_ax(h, 0.005, 1);

p.same_ylim_by_row();

for i = 2:n
    p.current_ax(i);
    ylabel('');
end

displace_ax(ht, 0.05, 2);

p.format('FontSize', 10, 'MarkerSize', [6, 6], 'LineWidthPlot', 0.75);
set(ht, 'FontSize', 10);
set(h, 'interpreter', 'tex', 'FontSize', 12);
displace_ax(h, -0.015, 1);
displace_ax(h,  0.025, 2);

p.offset_axes();

%% p-value annotations


% pvalues
clear hpv
for i=1:n
    pval = PVALUES(i);
    if pval<1e-8
        pstr = 'p<10^{-8}';
    else
        if pval<0.0005
            pval = num2str(redondear(pval, 4));
        elseif pval<0.005
            pval = num2str(redondear(pval, 3));
        else
            pval = num2str(redondear(pval, 2));
        end
        pstr = ['p=',pval];
    end
    hpv(i) = p.text_draw(i, pstr,'lower_right');
    
end

set(hpv,'FontSize',9);
displace_ax(hpv,0.05,2);



set(p.h_ax, 'xtick', 0:5:20, 'xticklabel', 0:5:20);
set(p.h_ax, 'ylim', [-0.5, 4]);
p.unlabel_center_plots();
p.xlabel('Overall value (\Sigmar)');

drawnow;



%% save
p.append_to_pdf('fig_effect_last', 1, 1);

end
