function run_eval_best_resample_ATT_nreps(datasource, nreps)
% Simulates behavior from the ATT-ADDITIVE model using best-fitting parameters.
%
% Runs subject-by-subject simulations with nreps repetitions, sampling
% fixation durations from log-normal distributions fit to the data.
% Stores choices, RTs, decision times, and fixation traces.
%
% USAGE:
%   run_eval_best_resample_ATT_nreps(2, 10)   % flat bounds [default]
%
% datasource: 1 = fits/ (collapsing bounds), 2 = fits_flat_bounds/
% nreps:      number of simulation repetitions (default = 10)
%
% Must run run_do_fit.m first.
% Output: model_fits_resample_ATT.mat saved into the fits folder.

addpath('./dtb_att_code/');
addpath('../functions/');
addpath(genpath('../matlab_functions/'));

if nargin < 1, datasource = 2; end
if nargin < 2, nreps = 10; end

baseSeed = 2223423908;

%% load behavioral data
datadir   = '../data/';
data      = load(fullfile(datadir, 'data_krajbich2010.mat'));
values    = [data.vleft, data.vright];
group     = data.group;
uni_group = unique(group);
RT        = data.RT;
choice    = data.choice;
ignore    = isnan(RT) | isnan(choice);

%% choose folder
switch datasource
    case 1
        datafolder = 'fits';
        figname    = 'fig_single_subj_resample';
    case 2
        datafolder = 'fits_flat_bounds';
        figname    = 'fig_single_subj_resample_flat_bounds';
end

%% time grid
dt = 0.001;
t  = 0:dt:10;
pars.t = t;

%% fixation duration distributions (from data)
load('../data/dwell_duration_pd.mat', 'pd_first', 'pd_middle');
pd = [pd_first, pd_middle];

%% preallocate
Ntr = numel(choice);
T   = numel(t);

choice_all    = nan(Ntr, nreps);
decTime_all   = nan(Ntr, nreps);
nonDec_all    = nan(Ntr, nreps);
focusLast_all = nan(Ntr, nreps);
ATT_all       = nan(Ntr, T, nreps);

NumRep = repmat(1:nreps, Ntr, 1);
NumRep = NumRep(:);

%% simulate
delete(gcp('nocreate'));
parpool(5);

parfor rep = 1:nreps
    rng(baseSeed + rep, 'twister');

    choice_model   = nan(Ntr, 1);
    dec_time_model = nan(Ntr, 1);
    non_dec_time   = nan(Ntr, 1);
    ATT_rep        = nan(Ntr, T);

    for i = 1:numel(uni_group)
        S   = uni_group(i);
        aux = load(fullfile(datafolder, sprintf('fits_%d.mat', S)));
        I   = (group == S) & ~ignore;
        thet = aux.theta;

        ndt_mu    = 0.01;
        ndt_sigma = 0.01;
        theta     = [thet(1), ndt_mu, ndt_sigma, thet(2:end)];

        plot_flag = 0;
        fn_fit    = @(th) wrapper_dtb_parametricbound_rt_ATT_additive( ...
                        th, RT(I), values(I,:), pd, choice(I), [], pars, plot_flag);
        [~, P, ATT_sub] = fn_fit(theta);

        ATT_rep(I, :) = ATT_sub;

        fI = find(I);
        for k = 1:numel(fI)
            idx = randsample(1:2*T, 1, true, ...
                [P.lo.pdf_t(P.trial_idx(k),:), P.up.pdf_t(P.trial_idx(k),:)]);
            choice_model(fI(k)) = (idx > T);
            t_idx = mod(idx, T);
            if t_idx == 0, t_idx = T; end
            dec_time_model(fI(k)) = t(t_idx);
        end

        non_dec_time(I) = max(0, mean(RT(fI)) - mean(dec_time_model(fI)));
    end

    focus_last = nan(Ntr, 1);
    for j = 1:Ntr
        if ~isnan(dec_time_model(j))
            step         = min(T, floor(dec_time_model(j) / dt));
            focus_last(j) = ATT_rep(j, step);
        end
    end

    choice_all(:, rep)    = choice_model;
    decTime_all(:, rep)   = dec_time_model;
    nonDec_all(:, rep)    = non_dec_time;
    ATT_all(:, :, rep)    = ATT_rep;
    focusLast_all(:, rep) = focus_last;
end

RT_all = decTime_all + nonDec_all;

ATT_all = permute(ATT_all, [1, 3, 2]);
ATT_all = reshape(ATT_all, [Ntr * nreps], T);

ATT_all_ext = ATT_all;
ATT_all     = motionenergy.remove_post_decision_samples(ATT_all, t, decTime_all(:));

%% save
m = struct( ...
    'focus',      ATT_all, ...
    'focus_ext',  ATT_all_ext, ...
    'DecTime',    decTime_all(:), ...
    'NonDecTime', nonDec_all(:), ...
    't_focus',    t, ...
    'RT',         RT_all(:), ...
    'choice',     choice_all(:), ...
    'dv',         repmat(data.dv(:), nreps, 1), ...
    'NumRep',     NumRep, ...
    'focus_last', focusLast_all(:), ...
    'group',      repmat(group(:), nreps, 1), ...
    'vleft',      repmat(data.vleft, nreps, 1), ...
    'vright',     repmat(data.vright, nreps, 1), ...
    'values',     repmat(values, nreps, 1));

save(fullfile(datafolder, 'model_fits_resample_ATT'), '-struct', 'm', '-v7.3');

%% summary plot
p  = publish_plot(2, 1);
dv = data.dv;
p.next();
curva_media(m.choice(:), m.dv(:), [], 1); hold on
curva_media(choice, dv, ~isnan(choice), 3);
ylabel('Prob. choose right');

p.next();
curva_media(m.RT(:), m.dv(:), [], 1); hold on
curva_media(RT, dv, ~isnan(choice), 3);
xlabel('\Delta value'); ylabel('RT');
p.format();
p.append_to_pdf(figname, 0, 1);

end
