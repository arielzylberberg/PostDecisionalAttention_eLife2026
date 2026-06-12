function run_make_sim_tau_e()
% Sensitivity analysis: vary tau_e (post-decisional gaze shift latency)
% in the PDG model with flat bounds.
%
% For each of 4 equi-spaced tau_e values (100–400 ms) a FULL independent
% simulation is run (fresh random seed for DTB draws, pre-decisional
% attention, and post-decisional t_eye), so that variability between
% curves reflects genuine Monte Carlo noise rather than shared fluctuations.
%
% The DTB response-time distributions P are pre-computed once per subject
% (they depend only on fitted parameters, not on tau_e), and random trial
% draws are re-sampled inside each tau_e iteration.
%
% Statistics computed using EXACTLY the same functions as the main figure
% (fn_run_plot_best.m):
%
%   Panel 1 – RT-aligned gaze cascade
%              eventlockedmatc + curva_media
%
%   Panel 2 – Influence of last fixation on choice
%              calc_and_plot_split_sum_value  (logistic-regression beta)
%
%   Panel 3 – Delta-Dwell vs RT
%              dwell_advantage_vs_RT_split_by_accuracy  (per-subject decile binning)
%
% Output saved to: tau_e_sensitivity_stats.mat
%
% USAGE
%   cd code_n_data_for_sharing/sensitivity_tau_e
%   run_make_sim_tau_e()

addpath('../model_PDG/simulation_flat_bounds/');
addpath('../model_PDG/fitting_flat_bounds/');
addpath('../functions/');
addpath(genpath('../matlab_functions/'));

%% ---- Configuration --------------------------------------------------
tau_e_vals  = linspace(0.1, 0.4, 4);   % [0.10, 0.20, 0.30, 0.40] s
ndt_sensory = 0.3;                      % sensory delay (s), fixed
nreps       = 10;                       % repetitions per subject (same as run_make_sim_data.m)
nTau        = numel(tau_e_vals);
BASE_SEED   = 45956813;                 % base seed; tau_e loop uses BASE_SEED + itau*10000

fprintf('=== tau_e sensitivity analysis (PDG flat bounds) ===\n');
fprintf('    tau_e values: %s ms\n\n', ...
        strjoin(arrayfun(@(x) sprintf('%.0f', x*1000), tau_e_vals, ...
        'UniformOutput', false), ', '));

%% ---- Load empirical data and fitted parameters ----------------------
fprintf('Loading data and fits ...\n');
d = load('../data/data_krajbich2010.mat', ...
    'dv', 'vright', 'vleft', 'RT', 'choice', 'group', 'first_fix_loc_with_interp');

load('../model_PDG/fitting_flat_bounds/fits/fits.mat', 'vTheta');
vTheta = cat(1, vTheta{:});

load('../data/dwell_duration_pd.mat', 'pd_first', 'pd_middle');
pd = [pd_first, pd_middle];

p_start_with_left = nanmean(d.first_fix_loc_with_interp);
coh               = d.dv;
ugroup            = nanunique(d.group);
ntr               = length(coh);

t       = 0:1/1000:10;
ntimes  = numel(t);
dt      = t(2) - t(1);

tind_sensory = max(1, round(ndt_sensory / dt) + 1);

%% ---- Pre-compute deterministic DTB distributions (per subject) ------
% P{i} is the response-time probability matrix for subject i.
% This is deterministic given vTheta, so compute once outside the tau_e loop.
fprintf('Pre-computing DTB distributions per subject ...\n');
pars     = struct('USfunc', 'Exponential');
P_subj   = cell(numel(ugroup), 1);
filt_idx = cell(numel(ugroup), 1);

for i = 1:numel(ugroup)
    theta        = vTheta(i, :);
    filt         = find(d.group == ugroup(i) & ~isnan(d.choice) & ~isnan(d.RT));
    filt_idx{i}  = filt;
    noise_multip = single(abs(d.vright(filt)) + abs(d.vleft(filt)));

    fn_fit = @(th) wrapper_dtb_parametricbound_rt_scale_noise( ...
                       th, d.RT(filt), coh(filt), noise_multip, d.choice(filt), [], pars, false);
    [~, P] = fn_fit(theta);
    P_subj{i} = P;
end
fprintf('  Done.\n\n');

%% ---- Storage (allocated after first tau_e iteration) ----------------
gaze_rt_subj = [];
gaze_rt_t    = [];

n_lf_bins = 5;
lf_x      = nan(nTau, n_lf_bins);
lf_y      = nan(nTau, n_lf_bins);
lf_s      = nan(nTau, n_lf_bins);

dd_con_t  = [];
dd_con_y  = [];
dd_con_s  = [];
dd_inc_y  = [];
dd_inc_s  = [];

%% ---- Main loop ------------------------------------------------------
for itau = 1:nTau

    tau_e = tau_e_vals(itau);
    fprintf('Processing tau_e = %.0f ms ...\n', tau_e * 1000);

    % ------------------------------------------------------------------
    % Set fresh seed for this tau_e — all random draws below use this
    % single RNG state (DTB samples, ndt jitter, attention switches,
    % and post-decisional t_eye), making each tau_e fully independent.
    % ------------------------------------------------------------------
    rng(BASE_SEED + itau * 10000, 'twister');

    % ------------------------------------------------------------------
    % 1. DTB simulation (same logic as run_make_sim_data.m, sim_flag=1)
    % ------------------------------------------------------------------
    m        = struct();
    m.RT     = nan(ntr, nreps);
    m.dec_t  = nan(ntr, nreps);
    m.choice = nan(ntr, nreps);
    m.coh    = nan(ntr, nreps);
    m.group  = repmat(d.group(:), 1, nreps);

    for i = 1:numel(ugroup)
        theta = vTheta(i, :);
        filt  = filt_idx{i};
        P     = P_subj{i};

        pdf = [P.lo.pdf_t, P.up.pdf_t];
        tt  = [P.t,        P.t       ];
        ch  = [zeros(size(P.t)), ones(size(P.t))];
        ind = 1:numel(tt);

        for irep = 1:nreps
            for im = 1:numel(filt)
                K         = randsample(ind, 1, true, pdf(P.idx_map(im), :));
                non_dec_t = max(0, theta(2) + randn() * theta(3));
                m.RT(filt(im), irep)     = tt(K) + non_dec_t;
                m.dec_t(filt(im), irep)  = tt(K);
                m.choice(filt(im), irep) = ch(K);
            end
            m.coh(filt, irep) = coh(filt);
        end
    end

    % Flatten (same as run_make_sim_data.m)
    m.vleft  = repmat(d.vleft(:),  nreps, 1);
    m.vright = repmat(d.vright(:), nreps, 1);
    m.RT     = m.RT(:);
    m.dec_t  = m.dec_t(:);
    m.choice = m.choice(:);
    m.coh    = m.coh(:);
    m.group  = m.group(:);
    m.dv     = m.coh;

    ntrials  = numel(m.RT);
    subjects = unique(m.group(~isnan(m.group)));
    n_subj   = numel(subjects);

    % ------------------------------------------------------------------
    % 2. Generate pre-decisional attention switches (RNG continues from
    %    the state after DTB draws, unique per tau_e)
    % ------------------------------------------------------------------
    focus_aux = sample_attention_switches_from_pd( ...
                    ntrials, ntimes, pd, p_start_with_left, dt, 0);

    focus  = nan(ntrials, ntimes, 'single');
    n_copy = ntimes - tind_sensory + 1;
    focus(:, tind_sensory : end) = single(focus_aux(:, 1 : n_copy));
    clear focus_aux

    % ------------------------------------------------------------------
    % 3. Post-decisional gaze shift with this tau_e
    % ------------------------------------------------------------------
    tau_e_sd = tau_e / 3;
    t_eye    = max(0, tau_e + randn(ntrials, 1) * tau_e_sd);

    for i = 1:ntrials
        if ~isnan(m.dec_t(i))
            t_shift = m.dec_t(i) + ndt_sensory + t_eye(i);
            tind    = find(t > t_shift, 1, 'first');
            if ~isempty(tind) && tind <= ntimes
                focus(i, tind : end) = single(m.choice(i));
            end
        end
    end

    % Remove post-RT samples (inline; equivalent to remove_post_decision_samples)
    for i = 1:ntrials
        if ~isnan(m.RT(i))
            tind_rt = find(t > m.RT(i), 1, 'first');
            if ~isempty(tind_rt)
                focus(i, tind_rt : end) = nan;
            end
        end
    end

    focus_d = double(focus);

    % ------------------------------------------------------------------
    % 4. Compute focus_last  (same as run_make_sim_data.m)
    % ------------------------------------------------------------------
    [datamp_fl, timeslocked_fl] = eventlockedmatc(focus_d, t, m.RT, [1, 1]);
    tind_zero  = findclose(timeslocked_fl, 0);
    focus_last = datamp_fl(tind_zero - 1, :)';

    % Build model struct for analysis functions
    m.focus      = focus_d;
    m.t_focus    = t;
    m.focus_last = focus_last;

    % ==================================================================
    % PANEL 1 – RT-aligned gaze cascade
    % ==================================================================
    e_m = focus_d;
    e_m(m.choice == 0, :) = 1 - e_m(m.choice == 0, :);   % flip: chosen = 1

    [datamp_m, timeslocked_m] = eventlockedmatc(e_m, t, m.RT, [1, 0.5]);
    d_m = datamp_m';
    [~, d_m] = curva_media(d_m, m.group, [], 0);   % n_subj × n_time_rt

    tind_rt = timeslocked_m >= -1 & timeslocked_m <= 0;

    if isempty(gaze_rt_t)
        gaze_rt_t    = timeslocked_m(tind_rt);
        n_t_rt       = sum(tind_rt);
        gaze_rt_subj = nan(nTau, n_subj, n_t_rt);
    end
    gaze_rt_subj(itau, :, :) = d_m(:, tind_rt);

    % ==================================================================
    % PANEL 2 – Last-fixation influence
    %   Calls calc_and_plot_split_sum_value exactly as fn_run_plot_best.m
    % ==================================================================
    [pregre_m, pch_m, ~, ~] = calc_and_plot_split_sum_value(m);
    close(pch_m.h_fig);

    a  = get(pregre_m.h_ax, 'children');
    XM = a(1).XData;
    YM = a(1).YData;
    SM = a(1).YPositiveDelta;

    close(pregre_m.h_fig);

    n_bins_lf            = numel(XM);
    lf_x(itau, 1:n_bins_lf) = XM;
    lf_y(itau, 1:n_bins_lf) = YM;
    lf_s(itau, 1:n_bins_lf) = SM;

    % ==================================================================
    % PANEL 3 – Delta-Dwell vs RT
    %   focus already has post-RT = NaN; same as fn_run_plot_best.m panel 8
    % ==================================================================
    delta_gaze = dt * double(nansum(focus_d == 1, 2) - nansum(focus_d == 0, 2));

    [~, Om] = dwell_advantage_vs_RT_split_by_accuracy( ...
                  delta_gaze, m.RT, m.choice, m.dv, m.group, 0);

    if isempty(dd_con_t)
        n_rt_bins = numel(Om.correct.t);
        dd_con_t  = nan(nTau, n_rt_bins);
        dd_con_y  = nan(nTau, n_rt_bins);
        dd_con_s  = nan(nTau, n_rt_bins);
        dd_inc_y  = nan(nTau, n_rt_bins);
        dd_inc_s  = nan(nTau, n_rt_bins);
    end
    dd_con_t(itau, :) = Om.correct.t(:)';
    dd_con_y(itau, :) = Om.correct.x(:)';
    dd_con_s(itau, :) = Om.correct.s(:)';
    dd_inc_y(itau, :) = Om.error.x(:)';
    dd_inc_s(itau, :) = Om.error.s(:)';

    fprintf('    done.\n');

end  % tau_e loop

%% ---- Save -----------------------------------------------------------
fprintf('\nSaving tau_e_sensitivity_stats.mat ...\n');
save('tau_e_sensitivity_stats.mat', ...
    'tau_e_vals', ...
    'gaze_rt_subj', 'gaze_rt_t', ...
    'lf_x', 'lf_y', 'lf_s', ...
    'dd_con_t', 'dd_con_y', 'dd_con_s', ...
    'dd_inc_y', 'dd_inc_s');

fprintf('Done. Run run_plot_tau_e_sensitivity.m to generate the figure.\n');
end
