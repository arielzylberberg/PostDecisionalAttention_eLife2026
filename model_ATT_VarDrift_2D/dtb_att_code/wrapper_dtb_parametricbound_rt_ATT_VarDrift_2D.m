function [err,P,ATT] = wrapper_dtb_parametricbound_rt_ATT_VarDrift_2D(theta,rt,values,pd_fix_dur,choice,c,pars,plot_flag)
% function [err,P] = wrapper_dtb_parametricbound_rt_ATT(theta,rt,values,pd_fix_dur,choice,c,pars,plot_flag)
% written by ariel zylberberg (ariel.zylberberg@gmail.com)

%% Parameters
kappa  = theta(1);
ndt_m  = theta(2);
ndt_s  = theta(3);
B0     = theta(4);
a      = theta(5);
d      = theta(6);
coh0   = theta(7);
y0a    = theta(8);
omega  = theta(9);
std_value = theta(10);

%% Optional flags
notabs_flag = isfield(pars, 'notabs_flag') && pars.notabs_flag;

if isfield(pars, 't')
    t = pars.t;
    dt = t(2)-t(1);
else
    dt = 0.0005;
    t  = 0:dt:10;
end

%% Attention sampling
ntrials = length(choice);
ntimes = length(t);
p_start_with_right = 0.26;
switch_time_cost = 0;
ATT = sample_attention_switches_from_pd(ntrials, ntimes, pd_fix_dur, p_start_with_right, dt, switch_time_cost);

%% Quadrature grid for value noise
n_bins = 5;
q = linspace(0, 1, n_bins + 1);
v_noise = norminv((q(1:end-1) + q(2:end))/2, 0, std_value);  % [1 x n_bins]

%% Bounds
if isfield(pars, 'USfunc')
    USfunc = pars.USfunc;
else
    USfunc = 'Exponential';
end
[Bup, Blo] = expand_bounds(t, B0, a, d, USfunc);

%% State space
y = linspace(min(Blo)-0.3, max(Bup)+0.3, 750)';
y0a = clip(y0a, Blo(1), Bup(1));
y0 = zeros(size(y));
y0(findclose(y, y0a)) = 1;
y0 = y0 / sum(y0);

%% Marginalization over value noise
P_up = zeros(size(values,1), length(t));
P_lo = zeros(size(values,1), length(t));
P_up_mean_t = zeros(size(values,1), 1);
P_lo_mean_t = zeros(size(values,1), 1);

for i = 1:n_bins
    for j = 1:n_bins
        v1_noisy = values(:,1) + v_noise(i);
        v2_noisy = values(:,2) + v_noise(j);


        coh_att_1 = v1_noisy - v2_noisy * omega;
        coh_att_0 = v1_noisy * omega - v2_noisy;
        coh = bsxfun(@times, (ATT == 1), coh_att_1) + ...
              bsxfun(@times, (ATT == 0), coh_att_0);

        [ucoh, ~, idx_ucoh] = unique((coh + coh0), 'rows');
        drift_t_matrix = kappa * ucoh;

        Paux = dtb_fp_cc_vec_dyndrifts(drift_t_matrix, t, Bup, Blo, y, y0, notabs_flag);

        P_up = P_up + Paux.up.pdf_t(idx_ucoh,:) / (n_bins^2);
        P_lo = P_lo + Paux.lo.pdf_t(idx_ucoh,:) / (n_bins^2);

        if isfield(Paux.up, 'mean_t') && isfield(Paux.lo, 'mean_t')
            P_up_mean_t = P_up_mean_t + Paux.up.mean_t(idx_ucoh) / (n_bins^2);
            P_lo_mean_t = P_lo_mean_t + Paux.lo.mean_t(idx_ucoh) / (n_bins^2);
        end
    end
end

P.up.pdf_t = P_up;
P.lo.pdf_t = P_lo;
P.up.mean_t = P_up_mean_t;
P.lo.mean_t = P_lo_mean_t;
P.t = t;
P.Bup = Bup;
P.Blo = Blo;
P.trial_idx = ones(size(values,1),1); % placeholder

%% Likelihood
if numel(choice) > 1
    err = logl_choiceRT_1d_att(P, choice, rt, coh, ndt_m, ndt_s);

    fprintf('err=%.3f kappa=%.2f ndt_mu=%.2f ndt_s=%.2f B0=%.2f a=%.2f d=%.2f coh0=%.2f y0=%.2f omega=%.2f std_value=%.2f\n',...
        err, kappa, ndt_m, ndt_s, B0, a, d, coh0, y0a, omega, std_value);

    %% Plotting
    if plot_flag
        m = prctile(rt,99.5);
        figure(1); clf; set(gcf,'Position',[311 393 885 247]);

        subplot(1,3,1);
        plot(t, P.Bup, 'k'); hold on;
        plot(t, P.Blo, 'k');
        if ~isnan(m); xlim([0, m]); end
        xlabel('Time'); ylabel('DV');

        subplot(1,3,2);
        delta_v = values(:,2) - values(:,1);
        [tt,xx,ss] = curva_media(choice, delta_v, [], 0);
        terrorbar(tt, xx, ss, 'color', 'k', 'LineStyle', 'none', 'Marker', '.', 'markersize', 20);
        hold on;
        [tt,xx] = curva_media(P_up(:,end), delta_v, [], 0);
        plot(tt, xx, 'k');
        xlabel('\Delta value'); ylabel('P rightward');

        subplot(1,3,3);
        [tt,xx,ss] = curva_media(rt, delta_v, choice==1, 0);
        terrorbar(tt, xx, ss, 'color', 'b', 'LineStyle', 'none', 'Marker', '.', 'markersize', 20);
        hold on;
        [tt,xx,ss] = curva_media(rt, delta_v, choice==0, 0);
        terrorbar(tt, xx, ss, 'color', 'r', 'LineStyle', 'none', 'Marker', '.', 'markersize', 20);
        [tt,xx] = curva_media(P.up.mean_t + ndt_m, delta_v, [], 0); plot(tt,xx,'b');
        [tt,xx] = curva_media(P.lo.mean_t + ndt_m, delta_v, [], 0); plot(tt,xx,'r');
        xlabel('\Delta value'); ylabel('RT');

        format_figure(gcf, 'LineWidthPlot', 1, 'MarkerSize', 16);
        drawnow;
    end
else
    err = [];
end

end


