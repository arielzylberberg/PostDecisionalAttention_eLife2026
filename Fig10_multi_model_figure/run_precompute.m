function run_precompute()
% Precomputes all numeric quantities needed for the multi-model figure
% and saves them to precomputed.mat.
%
% Run this once (or whenever model simulation files change).
% Then use run_plot.m to regenerate the figure without recomputing.
%
% USAGE:
%   run_precompute()

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

%% -----------------------------------------------------------------------
%  Behavioral data
% ------------------------------------------------------------------------
d   = load('../data/data_krajbich2010.mat');
idx = abs(d.dv) <= 5;

fprintf('Computing data-side quantities...\n');

%% Psychometric: overall
[tt, xx] = curva_media_hierarch(d.choice, d.dv, d.group, idx, 0);
dat.psych_all = mstruct(tt, xx);

%% Psychometric: split by last fixation
[tt, xx] = curva_media_hierarch(d.choice, d.dv, d.group, idx & d.focus_last == 1, 0);
dat.psych_last1 = mstruct(tt, xx);
[tt, xx] = curva_media_hierarch(d.choice, d.dv, d.group, idx & d.focus_last == 0, 0);
dat.psych_last0 = mstruct(tt, xx);

%% Chronometric (RT vs dv)
[tt, xx] = curva_media_hierarch(d.RT, d.dv, d.group, idx, 0);
dat.chron = mstruct(tt, xx);

%% Chronometric using total fixation time (for models like Callaway where RT = sum of dwells)
tot_fix = d.tot_fix_time_with_interp / 1000;   % convert ms → s
[tt, xx] = curva_media_hierarch(tot_fix, d.dv, d.group, idx, 0);
dat.chron_totfix = mstruct(tt, xx);

%% Magnitude effect: RT residuals vs sum value
[p_aux, RTres_d, suma_d] = magnitude_effect_RT_residuals( ...
    d.RT(idx), d.group(idx), d.vright(idx), d.vleft(idx));
close(p_aux.h_fig);
I = ~isnan(RTres_d);
[tt, xx, ss] = curva_media(RTres_d, suma_d, I, 0);
dat.mageff = struct('t', tt, 'x', xx, 's', ss);

%% Beta vs sum value
[pregre, pch, ~, ~] = calc_and_plot_split_sum_value(d);
close(pch.h_fig);
ch = get(pregre.h_ax, 'children');
dat.beta = struct('x', ch(1).XData, 'y', ch(1).YData, 's', ch(1).YPositiveDelta);
close(pregre.h_fig);

%% Delta dwell split by accuracy
t_d   = d.t_focus(:)';
dt_d  = t_d(2) - t_d(1);
att_d = motionenergy.remove_post_decision_samples(d.focus, t_d, d.RT);
dg_d  = dt_d * (sum(att_d == 1, 2) - sum(att_d == 0, 2));
[~, Od] = dwell_advantage_vs_RT_split_by_accuracy(dg_d, d.RT, d.choice, d.dv, d.group, 0);
dat.ddwell = struct( ...
    'correct', struct('t', Od.correct.t, 'x', Od.correct.x, 's', Od.correct.s), ...
    'error',   struct('t', Od.error.t,   'x', Od.error.x,   's', Od.error.s));

%% Choice vs delta dwell
prc = 0:10:100;
rng(42);
[~, vd] = index_prctile_by_group(jitter(d.delta_dwell), prc, d.group);
[tt, xx, ss] = curva_media(d.choice, vd, [], 0);
dat.chvsdw = struct('t', tt, 'x', xx, 's', ss);

%% First-fixation duration vs choice
dfirst = d.first_fix_dur_with_interp;
I      = ~isnan(dfirst);
rng(42);
[~, vd] = index_prctile_by_group(jitter(dfirst(I)), prc, d.group(I));
[tt, xx, ss] = curva_media(d.choice(I) == d.first_fix_loc_with_interp(I), vd, [], 0);
dat.ffd = struct('t', tt, 'x', xx, 's', ss);

%% -----------------------------------------------------------------------
%  Model definitions
% ------------------------------------------------------------------------
model_defs = { ...
    '../model_ATT/fits_flat_bounds/model_fits_resample_ATT.mat',         'aDDM',               struct('use_tot_fix_as_RT', 0); ...
    '../model_ATT_ADDITIVE/fits_flat_bounds/model_fits_resample_ATT.mat','aDDM-Additive',      struct('use_tot_fix_as_RT', 0); ...
    '../model_ATT_PD/modeldat_FlatBounds.mat',                           'aDDM-PD',            struct('use_tot_fix_as_RT', 0); ...
    '../model_ATT_VarDrift/fits_flat_bounds/model_fits_resample_ATT.mat','aDDM-VarDrift',      struct('use_tot_fix_as_RT', 0); ...
    'VarDrift_PD',                                                        'aDDM-VarDrift-PD',  struct('use_tot_fix_as_RT', 0); ...
    '../data/data_Callaway2021.mat',                                      'Callaway (2021)',   struct('use_tot_fix_as_RT', 1); ...
    '../data/data_Drugowitsch2021.mat',                                   'Drugowitsch (2021)',struct('use_tot_fix_as_RT', 0); ...
    };


% model_defs = { ...
%     '../model_ATT_ADDITIVE/fits_flat_bounds/model_fits_resample_ATT.mat','ATT-Additive',      struct('use_tot_fix_as_RT', 0); ...
%     '../model_ATT_PD/modeldat_FlatBounds.mat',                           'ATT-PD',            struct('use_tot_fix_as_RT', 0); ...
%     '../model_ATT_VarDrift/fits_flat_bounds/model_fits_resample_ATT.mat','ATT-VarDrift',      struct('use_tot_fix_as_RT', 0); ...
%     'VarDrift_PD',                                                        'ATT-VarDrift-PD',  struct('use_tot_fix_as_RT', 0); ...
%     '../data/data_Callaway2021.mat',                                      'Callaway (2021)',   struct('use_tot_fix_as_RT', 1); ...
%     '../data/data_Drugowitsch2021.mat',                                   'Drugowitsch (2021)',struct('use_tot_fix_as_RT', 0); ...
%     };



N = size(model_defs, 1);
prc = 0:10:100;

%% -----------------------------------------------------------------------
%  Per-model quantities
% ------------------------------------------------------------------------
for imod = 1:N
    src   = model_defs{imod, 1};
    label = model_defs{imod, 2};
    fl    = model_defs{imod, 3};

    fprintf('Processing model %d/%d: %s ...\n', imod, N, label);

    % load
    if strcmp(src, 'VarDrift_PD')
        m = build_VarDrift_PD();
    else
        m = load(src);
    end
    m.dw  = focus_to_dwells(m.focus, m.t_focus);
    idx_m = abs(m.dv) <= 5;

    r = struct();
    r.label            = label;
    r.use_tot_fix_as_RT = fl.use_tot_fix_as_RT;

    %% Psychometric: overall
    [tt, xx] = curva_media_hierarch(m.choice, m.dv, m.group, idx_m, 0);
    r.psych_all = mstruct(tt, xx);

    %% Psychometric: split by last fixation
    [tt, xx] = curva_media_hierarch(m.choice, m.dv, m.group, idx_m & m.focus_last == 1, 0);
    r.psych_last1 = mstruct(tt, xx);
    [tt, xx] = curva_media_hierarch(m.choice, m.dv, m.group, idx_m & m.focus_last == 0, 0);
    r.psych_last0 = mstruct(tt, xx);

    %% Chronometric
    % For Callaway, m.RT is already total fixation time (use_tot_fix_as_RT=1),
    % so m.RT is the correct RT variable for all models.
    RTvar_m = m.RT;
    [tt, xx] = curva_media_hierarch(RTvar_m, m.dv, m.group, idx_m, 0);
    r.chron = mstruct(tt, xx);

    %% Magnitude effect
    [p_aux, RTres_m, suma_m] = magnitude_effect_RT_residuals( ...
        RTvar_m(idx_m), m.group(idx_m), m.values(idx_m,2), m.values(idx_m,1));
    close(p_aux.h_fig);
    I = ~isnan(RTres_m);
    [tt, xx, ss] = curva_media(RTres_m, suma_m, I, 0);
    r.mageff = struct('t', tt, 'x', xx, 's', ss);

    %% Beta vs sum value
    [pregre_m, pch_m, ~, ~] = calc_and_plot_split_sum_value(m);
    close(pch_m.h_fig);
    ch = get(pregre_m.h_ax, 'children');
    r.beta = struct('x', ch(1).XData, 'y', ch(1).YData, 's', ch(1).YPositiveDelta);
    close(pregre_m.h_fig);

    %% Delta dwell split by accuracy
    dt_m  = m.t_focus(2) - m.t_focus(1);
    att_m = motionenergy.remove_post_decision_samples(m.focus, m.t_focus, RTvar_m);
    dg_m  = dt_m * (sum(att_m == 1, 2) - sum(att_m == 0, 2));
    [~, Om] = dwell_advantage_vs_RT_split_by_accuracy(dg_m, RTvar_m, m.choice, m.dv, m.group, 0);
    r.ddwell = struct( ...
        'correct', struct('t', Om.correct.t, 'x', Om.correct.x, 's', Om.correct.s), ...
        'error',   struct('t', Om.error.t,   'x', Om.error.x,   's', Om.error.s));

    %% Choice vs delta dwell
    dt_m = m.t_focus(2) - m.t_focus(1);
    dwm  = dt_m * (sum(m.focus == 1, 2) - sum(m.focus == 0, 2));
    rng(42);
    [~, vm] = index_prctile_by_group(dwm, prc, m.group);
    [tt, xx, ss] = curva_media(m.choice, vm, [], 0);
    r.chvsdw = struct('t', tt, 'x', xx, 's', ss);

    %% First-fixation duration vs choice
    dfirst_m = m.dw.len(:, 1);
    rng(42);
    [~, vm] = index_prctile_by_group(jitter(dfirst_m), prc, m.group);
    [tt, xx, ss] = curva_media(m.choice == m.dw.roi(:, 1), vm, [], 0);
    r.ffd = struct('t', tt, 'x', xx, 's', ss);

    M(imod) = r;
end

%% save
save('precomputed.mat', 'dat', 'M', '-v7.3');
fprintf('Saved precomputed.mat\n');

end

% -------------------------------------------------------------------------
function s = mstruct(tt, xx)
% Pack curva_media_hierarch output into a compact struct.
s = struct('t', tt, 'x', nanmean(xx, 2), 's', stderror(xx, 2));
end

% -------------------------------------------------------------------------
function m = build_VarDrift_PD()
m   = load('../model_ATT_VarDrift/fits_flat_bounds/model_fits_resample_ATT.mat');
aux = load('../model_ATT_PD/ext_model_params.mat');

t_sensory = aux.ndt_sensory;
t_eye_m   = aux.ndt_eye;
t_eye_s   = aux.ndt_eye_s;

t  = m.t_focus;
nt = length(t);
dt = t(2) - t(1);

F         = nan(size(m.focus));
tind      = ceil(t_sensory / dt):nt;
F(:, tind) = m.focus_ext(:, 1:length(tind));

ntr   = length(m.choice);
t_eye = max(0, randn(ntr, 1) * t_eye_s + t_eye_m);
s     = round((m.DecTime + t_sensory + t_eye) / dt);

for i = 1:ntr
    if ~isnan(s(i))
        F(i, s(i):nt) = m.choice(i);
    end
end

focus_last = nan(ntr, 1);
RTs = min(round(m.RT / dt), nt);
for i = 1:ntr
    if ~isnan(RTs(i))
        focus_last(i) = F(i, RTs(i));
    end
end

F            = motionenergy.remove_post_decision_samples(F, m.t_focus, m.RT);
m.focus      = F;
m.focus_last = focus_last;
end
