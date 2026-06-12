function main()
% Plots gaze toward the chosen item locked to response time.
%
% Panel A: Time-course of P(looking at chosen item) from -800 ms to +200 ms
%          relative to the response, averaged across subjects (bars = 95% CI).
%
% Panel B: Per-subject scatter of P(looking at chosen item) in the last
%          200 ms before vs. first 200 ms after the response.
%
% USAGE:
%   main()
%
% Requires: ../data/data_krajbich2010.mat
% Output:   fig_pre_post_gaze.pdf

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

%% load data
d = load('../data/data_krajbich2010.mat');

%% align fixations to response time
[datamp, timeslocked] = eventlockedmatc( ...
    d.focus_all, d.t_focus(:)', d.RT, [1, 1]);
% datamp: time × trials

%% per-subject P(looking at chosen item) in [-200, 0] and [0, 200] ms windows
F = nan(max(d.group), 2);
for i = 1:2
    if i == 1
        tind = timeslocked >= -0.2 & timeslocked < 0;
    else
        tind = timeslocked >  0    & timeslocked <= 0.2;
    end
    a = mean(datamp(tind,:)' == d.choice,    2);   % fraction looking at chosen
    b = mean(datamp(tind,:)' == (1-d.choice), 2);  % fraction looking at unchosen
    f = a ./ (a + b);
    [~, F(:,i)] = curva_media(f, d.group, [], 0);
end

%% orient so that chosen = 1 regardless of left/right
S = datamp';          % trials × time
I = d.choice == 0;
S(I,:) = 1 - S(I,:);

%% figure
p = publish_plot(1, 2);
set(gcf, 'Position', [302, 396, 783, 319]);
p.displace_ax(1, -0.02, 1);

%% Panel A: time-course locked to response
p.current_ax(1);

tind = timeslocked >= -0.8 & timeslocked <= 0.2;
[~, s] = curva_media(S, d.group, [], 0);

niceBars2(timeslocked(tind), nanmean(s(:, tind)), ...
    1.96 * stderror(s(:, tind)), [0, 0, 0], 0.2);
hold all
plot(xlim, [0.5, 0.5], 'k:');
plot([0, 0], [0.4, 0.9], 'k--');
ylim([0.4, 0.9]);
xlim([-0.8, 0.2]);
xlabel('Time from response [s]');
ylabel('P. look at chosen item');

%% Panel B: pre vs. post scatter (per subject)
p.current_ax(2);

plot(F(:,1), F(:,2), ...
    'marker', 'o', 'LineStyle', 'none', ...
    'markerEdgeColor', 0.4*[1,1,1], ...
    'markerFaceColor', 0.7*[1,1,1], ...
    'LineWidth', 0.1);

limi = [0.4, 1.0];
xlim(limi); ylim(limi);
hold on
plot(xlim, ylim, 'color', 0.7*[1,1,1]);
xlabel({'P. look at chosen', '(last 200 ms before resp.)'});
ylabel({'P. look at chosen', '(first 200 ms after resp.)'});
set(gca, 'tickdir', 'out');
same_xytick(p.h_ax(2));

%% formatting
p.format('FontSize', 11, 'LineWidthAxes', 0.5, 'MarkerSize', 6);

h = p.letter_the_plots('show', 1:2);
set(h, 'FontSize', 14);
displace_ax(h, -0.01, 1);

p.shrink(1:2, 0.9, 0.9);
drawnow;

%% save
p.append_to_pdf('fig_pre_post_gaze', 1, 1);

end
