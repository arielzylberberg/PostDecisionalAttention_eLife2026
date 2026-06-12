function [err, P, pChoiceT] = wrapper_dtb_parametricbound_rt_extATT_VarDrift_2D(theta,...
    values, ATT, choice, c, pars, plot_flag)
% wrapper_dtb_parametricbound_rt_extATT_ValueNoise_2D
% by Ariel Zylberberg
% Modified to implement value noise marginalization instead of additive drift noise

%% Parameters
kappa  = theta(1);
B0     = theta(2);
a      = theta(3);
d      = theta(4);
coh0   = theta(5);
y0a    = theta(6);
omega  = theta(7);
std_value = theta(8);

%% Optional flags
notabs_flag = isfield(pars, 'notabs_flag') && pars.notabs_flag;

if isfield(pars, 't')
    t = pars.t;
    dt = t(2) - t(1);
else
    dt = 0.0005;
    t = 0:dt:10;
end

%% Bounds
if isfield(pars, 'USfunc')
    USfunc = pars.USfunc;
else
    USfunc = 'Exponential';
end
[Bup, Blo] = expand_bounds(t, B0, a, d, USfunc);

%% Grid for value noise marginalization
n_bins = 5;
q = linspace(0, 1, n_bins + 1);
v_noise = norminv((q(1:end-1) + q(2:end))/2, 0, std_value); % shape: [1, n_bins]

%% Prepare state space
y = linspace(min(Blo)-0.3, max(Bup)+0.3, 750)';
y0a = clip(y0a, Blo(1), Bup(1));
y0 = zeros(size(y));
y0(findclose(y, y0a)) = 1;
y0 = y0 / sum(y0);

%% Marginalize over value noise
P_up = zeros(size(values,1), length(t));
P_lo = zeros(size(values,1), length(t));

for i = 1:n_bins
    for j = 1:n_bins
        v1_noisy = values(:,1) + v_noise(i);
        v2_noisy = values(:,2) + v_noise(j);


        coh_att_1 = v1_noisy - v2_noisy * omega;
        coh_att_0 = v1_noisy * omega - v2_noisy;
        coh = bsxfun(@times, (ATT == 1), coh_att_1) + ...
              bsxfun(@times, (ATT == 0), coh_att_0);

        % coh_att_2 = v2_noisy - v1_noisy * omega;
        % coh_att_1 = v2_noisy * omega - v1_noisy;
        % coh = bsxfun(@times, (ATT == 1), coh_att_2) + ...
        %       bsxfun(@times, (ATT == 0), coh_att_1);

        [ucoh, ~, idx_ucoh] = unique((coh + coh0), 'rows');
        drift_t_matrix = kappa * ucoh;

        Paux = dtb_fp_cc_vec_dyndrifts_SAFE(drift_t_matrix, t, Bup, Blo, y, y0, notabs_flag);

        P_up = P_up + Paux.up.pdf_t(idx_ucoh,:) / (n_bins^2);
        P_lo = P_lo + Paux.lo.pdf_t(idx_ucoh,:) / (n_bins^2);
    end
end

P.up.pdf_t = P_up;
P.lo.pdf_t = P_lo;
P.t = t;
P.Bup = Bup;
P.Blo = Blo;
P.trial_idx = [1:size(values,1)]';  % not used anymore in marginalized version

%% Likelihood
if numel(choice) > 1
    dec_step = sum(~isnan(ATT),2);
    I = dec_step > 0;
    pChoiceT = nan(length(dec_step),2);

    [err, ~, pChoiceT(I,:)] = logl_choice_dec_time(P_up(I,:), P_lo(I,:), choice(I), dec_step(I));
    pUpGivenDecTime = pChoiceT(:,2) ./ sum(pChoiceT,2);

    %% Print
    fprintf('err=%.3f kappa=%.2f B0=%.2f a=%.2f d=%.2f coh0=%.2f y0=%.2f omega=%.2f std_value=%.2f\n',...
        err,kappa,B0,a,d,coh0,y0a,omega,std_value);

    %% Optional plot
    if plot_flag
        figure(1); clf
        set(gcf,'Position',[311 393 885 247]);

        subplot(1,2,1);
        plot(t, Bup, 'k'); hold on;
        plot(t, Blo, 'k');
        xlim([0,5]); xlabel('Time'); ylabel('DV');

        subplot(1,2,2);
        delta_v = values(:,2) - values(:,1);
        [tt,xx,ss] = curva_media(choice, delta_v, [], 0);
        terrorbar(tt, xx, ss, 'color', 'k', 'LineStyle', 'none', 'Marker', '.', 'markersize', 20);
        hold on;
        [tt,xx] = curva_media(pUpGivenDecTime, delta_v, [], 0);
        plot(tt, xx, 'k');
        xlabel('\Delta value'); ylabel('P rightward');
        format_figure(gcf,'LineWidthPlot',1,'MarkerSize',16);
        drawnow;
    end
else
    err = [];
end

end
