function main()
% Evaluates the ATT-VarDrift-PD model (intra- and post-decisional attention
% with inter-trial drift-rate variability) using flat-bounds fits.
%
% Loads pre-simulated trials from the ATT-VarDrift flat-bounds model and
% overlays post-decisional gaze dynamics estimated from model_ATT_PD.
%
% USAGE:
%   main()
%
% Requires:
%   ../model_ATT_VarDrift/fits_flat_bounds/model_fits_resample_ATT.mat
%   ../model_ATT_PD/ext_model_params.mat
%   ../data/data_krajbich2010.mat
%
% Output: fig_ATT_VarDrift_PD_FlatBounds.pdf

addpath('../functions/');
addpath(genpath('../matlab_functions/'));

description = 'ATT model (intra- and post-decisional attention, inter-trial drift variability, flat bounds)';

%% load base simulation (VarDrift flat bounds)
m = load('../model_ATT_VarDrift/fits_flat_bounds/model_fits_resample_ATT.mat');

%% load post-decisional gaze parameters
aux        = load('../model_ATT_PD/ext_model_params.mat');
t_sensory  = aux.ndt_sensory;
t_eye_m    = aux.ndt_eye;
t_eye_s    = aux.ndt_eye_s;

%% build post-decisional fixation trace
t  = m.t_focus;
nt = length(t);
dt = t(2) - t(1);

F    = nan(size(m.focus));
tind = ceil(t_sensory / dt) : nt;
F(:, tind) = m.focus_ext(:, 1:length(tind));

ntr   = length(m.choice);
t_eye = max(0, randn(ntr, 1) * t_eye_s + t_eye_m);

s = round((m.DecTime + t_sensory + t_eye) / dt);

for i = 1:ntr
    if ~isnan(s(i))
        tind       = s(i) : nt;
        F(i, tind) = m.choice(i);
    end
end

%% compute focus_last at RT
focus_last = nan(ntr, 1);
RTs = min(round(m.RT / dt), nt);
for i = 1:ntr
    if ~isnan(RTs(i))
        focus_last(i) = F(i, RTs(i));
    end
end

%% clip post-decision gaze
F = motionenergy.remove_post_decision_samples(F, m.t_focus, m.RT);

m.focus      = F;
m.focus_last = focus_last;

%% plot
d = load('../data/data_krajbich2010.mat');

flags.use_tot_fix_as_RT             = 0;
flags.use_tot_fix_as_RT_in_LOB_plot = 0;

m.dw = focus_to_dwells(m.focus, m.t_focus);

p = fn_run_plot_best(d, m, flags);

h = p.text_draw_fig(description);
set(h, 'FontSize', 12);

figname = 'fig_ATT_VarDrift_PD_FlatBounds';
p.append_to_pdf(figname, 1, 1);

end
