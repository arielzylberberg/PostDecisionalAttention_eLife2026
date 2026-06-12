function main(source_flag)
% Generates ATT+PD model simulations and plots for the ATT model extended
% with post-decisional gaze dynamics.
%
% Takes the fixation traces from the ATT model simulation (model_ATT/fits/)
% and adds post-decisional gaze: after the decision, gaze shifts to the
% chosen item with a latency governed by sensory and eye-movement delays.
%
% USAGE:
%   main()    % runs both variants
%   main(1)   % collapsing bounds
%   main(2)   % flat bounds
%
% Must run model_ATT/run_eval_best_resample_ATT_nreps.m first.
% Must run run_make_external_params.m first.
% Output: modeldat.mat (or modeldat_FlatBounds.mat) in this folder.

if nargin == 0
    % main(1);
    main(2);
    return
end

switch source_flag
    case 1
        m   = load('../model_ATT/fits/model_fits_resample_ATT.mat');
        ext = '';
    case 2
        m   = load('../model_ATT/fits_flat_bounds/model_fits_resample_ATT.mat');
        ext = '_FlatBounds';
end

%%
aux         = load('./ext_model_params.mat');
t_sensory   = aux.ndt_sensory;
t_eye_m     = aux.ndt_eye;
t_eye_s     = aux.ndt_eye_s;

t  = m.t_focus;
nt = length(t);
dt = t(2) - t(1);

F = nan(size(m.focus));

% shift gaze forward by sensory delay (gaze representation lags decision)
tind         = ceil(t_sensory / dt):nt;
F(:, tind)   = m.focus_ext(:, 1:length(tind));

ntr   = length(m.choice);
t_eye = max(0, randn(ntr, 1) * t_eye_s + t_eye_m);

% after decision + sensory delay + eye latency, gaze follows choice
s = round((m.DecTime + t_sensory + t_eye) / dt);

for i = 1:ntr
    if ~isnan(s(i))
        tind         = s(i):nt;
        F(i, tind)   = m.choice(i);
    end
end

% last fixation before RT
focus_last = nan(ntr, 1);
RTs        = min(round(m.RT / dt), nt);
for i = 1:ntr
    if ~isnan(RTs(i))
        focus_last(i) = F(i, RTs(i));
    end
end

F = motionenergy.remove_post_decision_samples(F, m.t_focus, m.RT);

m.focus      = F;
m.focus_last = focus_last;

%%
save(['modeldat', ext], '-struct', 'm', '-v7.3');

%% plot
d = load('../data/data_krajbich2010.mat');

flags.use_tot_fix_as_RT            = 0;
flags.use_tot_fix_as_RT_in_LOB_plot = 0;

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

m.dw = focus_to_dwells(m.focus, m.t_focus);

p = fn_run_plot_best(d, m, flags);

h = p.text_draw_fig('ATT+PD model (intra- and post-decisional attention)');
set(h, 'FontSize', 13);

figname = ['fig_ATT_PD', ext];
p.append_to_pdf(figname, 1, 1);

end
