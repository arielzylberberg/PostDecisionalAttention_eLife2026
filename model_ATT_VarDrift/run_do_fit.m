function run_do_fit(param_set, data_source)
% Fits the ATT-VarDrift model (additive intra-decisional attention with
% inter-trial drift-rate variability) to data.
%
% USAGE:
%   run_do_fit(3, 1)   % flat bounds variant [default]
%
% PARAM_SET:
%   1 = collapsing bounds, omega free
%   3 = flat bounds, omega free
%
% DATA_SOURCE:
%   1 = real behavioral data
%
% Parameters: kappa, B0, a, d, coh0, y0, omega, std_drift
%
% Requires: BADS toolbox (https://github.com/acerbilab/bads)
% Output: fit results saved to ./fits_flat_bounds/

addpath('./dtb_att_code/');
addpath('../functions/');
addpath(genpath('../matlab_functions/'));
% NOTE: Add the BADS toolbox to your path before running:

if nargin == 0 || isempty(param_set)
    param_set   = 3;
    data_source = 1;
elseif nargin == 1 || isempty(data_source)
    data_source = 1;
end

%% output folder suffix by data source
switch data_source
    case 1
        folder_name_ext = '';
    case 2
        folder_name_ext = '_to_sim_data';
end

%% load data
datadir = '../data/';
data    = load(fullfile(datadir, 'data_krajbich2010.mat'));

dt = 0.001;

values = [data.vleft, data.vright];
group  = data.group;
RT     = data.RT;
choice = data.choice;

uni_group    = unique(group);
nsuj         = length(uni_group);
ignore_trials = isnan(RT) | isnan(choice);

%% build ATT matrix
max_time_steps = 10 / dt;
ATT = dwells_to_mat(data.dwells, dt, max_time_steps);
t   = (1:size(ATT, 2)) * dt - dt;

pars.t = t;

%%
dofit_flag     = 1;
overwrite_flag = 1;

if dofit_flag

    try
        parpool('local', 10);
    catch
    end

    switch param_set

        case 1  % collapsing bounds, omega free
            kappa     = [0.1, 10,  0.5];
            B0        = [0.5, 10,  1];
            a         = [-1,   1,  0];
            d         = [0,    0,  0];
            y0        = [0,    0,  0];
            coh0      = [0,    0,  0];
            omega     = [0,    1,  0.5];
            std_drift = [0,    3,  0.5];
            folder_save_name = ['fits', folder_name_ext];

        case 3  % flat bounds, omega free
            kappa     = [0.1, 10,  0.5];
            B0        = [0.5, 10,  1];
            a         = [0,    0,  0];
            d         = [0,    0,  0];
            y0        = [0,    0,  0];
            coh0      = [0,    0,  0];
            omega     = [0,    1,  0.5];
            std_drift = [0,    3,  0.5];
            folder_save_name = ['fits_flat_bounds', folder_name_ext];

    end

    % rows: [lower, upper, initial guess]; cols: parameters
    % [kappa, B0, a, d, coh0, y0, omega, std_drift]
    params = cat(1, kappa, B0, a, d, coh0, y0, omega, std_drift);
    tl     = params(:, 1)';
    th     = params(:, 2)';
    tguess = params(:, 3)';

    Nguess = 1;
    vtg    = tguess';

    w = combvec(1:nsuj, 1:Nguess);

    parfor i = 1:size(w, 1)
        suj_id = w(i, 1);
        tg_id  = w(i, 2);
        filename = [folder_save_name, '/fits_', num2str(suj_id), '_', num2str(tg_id), '.mat'];
        if overwrite_flag == 1 || ~exist(filename, 'file')

            I  = group == uni_group(suj_id) & ~ignore_trials;
            tg = vtg(:, tg_id)';

            plot_flag = 0;
            fn_fit    = @(theta) wrapper_dtb_parametricbound_rt_extATT_VarDrift( ...
                            theta, values(I,:), ATT(I,:), choice(I), [], pars, plot_flag);

            options = optimset('Display', 'final', 'TolFun', 0.1, 'FunValCheck', 'on');
            [theta, fval] = bads(@(theta) fn_fit(theta), tg, tl, th, tl, th, options);

            tosave = struct('theta', theta, 'fval', fval);
            save_parallel(filename, tosave, 0);
        end
    end

    %% select best fit across initial guesses and save summary
    for i = 1:length(uni_group)
        for j = 1:Nguess
            filename    = [folder_save_name, '/fits_', num2str(uni_group(i)), '_', num2str(j)];
            aux         = load(filename, 'theta', 'fval');
            vfval(j)    = aux.fval;
        end
        [~, J]        = min(vfval);
        filename      = [folder_save_name, '/fits_', num2str(uni_group(i)), '_', num2str(J)];
        aux           = load(filename);
        filename_best = [folder_save_name, '/fits_', num2str(uni_group(i))];
        save_parallel(filename_best, aux, 0);
    end

    for i = 1:length(uni_group)
        filename    = [folder_save_name, '/fits_', num2str(uni_group(i))];
        aux         = load(filename);
        vFval(i)    = aux.fval;
        vTheta(i,:) = aux.theta;
    end
    save(fullfile(folder_save_name, 'fits'), 'vFval', 'vTheta');

end

end
