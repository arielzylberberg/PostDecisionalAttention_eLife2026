function run_make_sim_data(sim_flag)
% Simulates behavior from the PDG model with flat bounds using best-fitting parameters.
%
% Same as simulation/run_make_sim_data.m but uses fits from fitting_flat_bounds/.
%
% sim_flag = 1 (default): simulate 10 repetitions, save as 'model_sim.mat'
% sim_flag = 2: 1 repetition for parameter recovery
%
% Must run fitting_flat_bounds/main.m first.

if nargin == 0 || isempty(sim_flag)
    sim_flag = 1;
end

addpath('../fitting_flat_bounds/');
addpath('../../functions/');
addpath(genpath('../../matlab_functions/'));

%%
d = load('../../data/data_krajbich2010.mat', 'dv', 'vright', 'vleft', 'RT', ...
    'choice', 'group', 'first_fix_loc_with_interp');
d.values = [d.vleft, d.vright];

load('../fitting_flat_bounds/fits/fits.mat', 'vTheta');
vTheta = cat(1, vTheta{:});

coh    = d.dv;
ugroup = nanunique(d.group);

%%
switch sim_flag
    case 1
        rng(45956813, 'twister');
        nreps        = 10;
        savefilename = 'model_sim';
    case 2
        rng(45956814, 'twister');
        nreps        = 1;
        savefilename = 'model_sim_for_recovery';
end

ntr = length(coh);
m   = struct('RT', nan(ntr, nreps), 'dec_t', nan(ntr, nreps), ...
             'non_dec_t', nan(ntr, nreps), 'choice', nan(ntr, nreps), ...
             'group', nan(ntr, nreps), 'coh', nan(ntr, nreps));
m.group = repmat(d.group(:), 1, nreps);

for i = 1:length(ugroup)

    theta        = vTheta(i, :);
    filt         = find(d.group == ugroup(i) & ~isnan(d.choice) & ~isnan(d.RT));
    noise_multip = single(abs(d.vright(filt)) + abs(d.vleft(filt)));

    plot_flag = false;
    pars      = struct('USfunc', 'Exponential');
    fn_fit    = @(theta) wrapper_dtb_parametricbound_rt_scale_noise( ...
                    theta, d.RT(filt), coh(filt), noise_multip, d.choice(filt), [], pars, plot_flag);

    [~, P] = fn_fit(theta);

    pdf = [P.lo.pdf_t, P.up.pdf_t];
    tt  = [P.t, P.t];
    ch  = [zeros(size(P.t)), ones(size(P.t))];
    ind = 1:length(tt);

    for irep = 1:nreps
        for im = 1:length(filt)
            K        = randsample(ind, 1, true, pdf(P.idx_map(im), :));
            m_choice = ch(K)';
            m_DT     = tt(K)';

            ndt_m     = theta(2);
            ndt_s     = theta(3);
            non_dec_t = max(0, ndt_m + randn() * ndt_s);

            m.RT(filt(im), irep)        = m_DT + non_dec_t;
            m.dec_t(filt(im), irep)     = m_DT;
            m.non_dec_t(filt(im), irep) = non_dec_t;
            m.choice(filt(im), irep)    = m_choice;
        end
        m.coh(filt, irep) = coh(filt);
    end

end

m.vleft  = repmat(d.vleft,  nreps, 1);
m.vright = repmat(d.vright, nreps, 1);
m.values = [m.vleft, m.vright];

m.RT        = m.RT(:);
m.dec_t     = m.dec_t(:);
m.non_dec_t = m.non_dec_t(:);
m.choice    = m.choice(:);
m.coh       = m.coh(:);
m.group     = m.group(:);

%% generate synthetic eye movements

aux         = load('ext_model_params');
ndt_eye     = aux.ndt_eye;
ndt_eye_s   = aux.ndt_eye_s;
ndt_sensory = aux.ndt_sensory;

load('../../data/dwell_duration_pd.mat', 'pd_first', 'pd_middle');
pd = [pd_first, pd_middle];

switch_time_cost  = 0;
p_start_with_left = nanmean(d.first_fix_loc_with_interp);

t      = 0:1/1000:10;
ntimes = length(t);
ntrials = length(m.coh);
dt     = t(2) - t(1);

focus_aux = sample_attention_switches_from_pd(ntrials, ntimes, pd, p_start_with_left, dt, switch_time_cost);

tind  = findclose(t, ndt_sensory);
focus = nan(size(focus_aux));
focus(:, tind:end) = focus_aux(:, 1:end - tind + 1);

t_eye = max(0, ndt_eye + randn(ntrials, 1) * ndt_eye_s);
for i = 1:ntrials
    if ~isnan(m.dec_t(i))
        tind           = t > (m.dec_t(i) + ndt_sensory + t_eye(i));
        focus(i, tind) = m.choice(i);
    else
        focus(i, :) = nan;
    end
end

focus = motionenergy.remove_post_decision_samples(focus, t, m.RT);

[datamp, timeslocked] = eventlockedmatc(focus, t, m.RT, [1, 1]);
tind       = findclose(timeslocked, 0);
focus_last = datamp(tind - 1, :)';

m.focus_last = focus_last;
m.focus      = focus;
m.t_focus    = t;
m.dv         = m.coh;

save(savefilename, 'm', '-v7.3');

end
