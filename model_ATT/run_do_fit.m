function run_do_fit(param_set, data_source)
% Fits the ATT model (multiplicative intra-decisional attention) to data.
%
% USAGE:
%   run_do_fit(1, 1)          % fits aDDM (param_set=1) to real data
%   run_do_fit(3, 1)          % flat bounds variant [default]
%   run_do_fit(1, 2)          % fit to simulated ATT data (parameter recovery)
%   run_do_fit(1, 3)          % fit to data simulated from the PDG model
%
% PARAM_SET:
%   1 = collapsing bounds, omega free (full aDDM)
%   2 = collapsing bounds, omega fixed = 1 (no attention weight)
%   3 = flat bounds, omega free
%   4 = flat bounds, omega fixed = 1
%
% DATA_SOURCE:
%   1 = real behavioral data
%   2 = data simulated from ATT model (for parameter recovery)
%   3 = data simulated from PDG model (cross-model recovery)
%
% Parameters: kappa, B0, a, d, coh0, y0, omega
%
% Requires: BADS toolbox (https://github.com/acerbilab/bads)
% Output: fit results saved to ./fits/ (or fits_flat_bounds/, etc.)

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
    case 3
        folder_name_ext = '_to_sim_VAR_data';
end

%% load data
datadir = '../data/';
data    = load(fullfile(datadir, 'data_krajbich2010.mat'));

dt = 0.001;

if data_source == 1

    values = [data.vleft, data.vright];
    group  = data.group;
    RT     = data.RT;
    choice = data.choice;

elseif data_source == 2

    if param_set == 1
        temp = load('./fits/model_fits_resample_ATT.mat');
    elseif param_set == 3
        temp = load('./fits_flat_bounds/model_fits_resample_ATT.mat');
    end

    ind    = temp.NumRep == 1;
    choice = temp.choice(ind);
    focus  = temp.focus(ind, :);
    values = temp.values(ind, :);
    t_focus = temp.t_focus;
    dt     = t_focus(2) - t_focus(1);
    group  = temp.group(ind);
    RT     = temp.RT(ind);

elseif data_source == 3

    temp = load('../model_PDG/simulation/model_sim.mat');
    idx  = find(diff(temp.m.group) < 0, 1);
    I    = 1:idx;

    values = [temp.m.vleft(I), temp.m.vright(I)];
    group  = temp.m.group(I);
    RT     = temp.m.RT(I);
    choice = temp.m.choice(I);
    dt     = temp.m.t_focus(2) - temp.m.t_focus(1);
    focus  = temp.m.focus(I, :);

    [~, idx2]  = sort(isnan(focus), 2);
    ATT        = focus(sub2ind(size(focus), repmat((1:size(focus,1))', 1, size(focus,2)), idx2));

end

uni_group    = unique(group);
nsuj         = length(uni_group);
ignore_trials = isnan(RT) | isnan(choice);

%% build ATT matrix
% NOTE: t must be derived from ATT size (not set independently) to ensure
% the time vector and ATT columns are perfectly aligned.

if data_source == 1
    max_time_steps = 10 / dt;
    ATT = dwells_to_mat(data.dwells, dt, max_time_steps);  % dt in seconds
    t   = (1:size(ATT, 2)) * dt - dt;                     % [0, dt, 2*dt, ..., (n-1)*dt]
elseif data_source == 2
    ATT = focus;
    t   = t_focus;
elseif data_source == 3
    % ATT is already set above from the PDG simulation; build t to match
    t = (1:size(ATT, 2)) * dt - dt;
end

pars.t = t;

%%
dofit_flag   = 1;
overwrite_flag = 1;

if dofit_flag

    try
        parpool('local', 10);
    catch
    end

    switch param_set

        case 1  % collapsing bounds, omega free (full aDDM)
            kappa = [0.1, 10,  2];
            B0    = [0.5, 10,  1];
            a     = [-1,   1,  0];
            d     = [0,    0,  0];
            y0    = [0,    0,  0];
            coh0  = [0,    0,  0];
            omega = [0,    1,  0.5];
            folder_save_name = ['fits', folder_name_ext];

        case 2  % collapsing bounds, omega fixed = 1
            kappa = [0.1, 10,  2];
            B0    = [0.5, 10,  1];
            a     = [-1,   1,  0];
            d     = [0,    0,  0];
            y0    = [0,    0,  0];
            coh0  = [0,    0,  0];
            omega = [1,    1,  1];
            folder_save_name = ['fits_no_omega', folder_name_ext];

        case 3  % flat bounds, omega free
            kappa = [0.1, 10,  2];
            B0    = [0.5, 10,  1];
            a     = [0,    0,  0];
            d     = [0,    0,  0];
            y0    = [0,    0,  0];
            coh0  = [0,    0,  0];
            omega = [0,    1,  0.5];
            folder_save_name = ['fits_flat_bounds', folder_name_ext];

        case 4  % flat bounds, omega fixed = 1
            kappa = [0.1, 10,  2];
            B0    = [0.5, 10,  1];
            a     = [0,    0,  0];
            d     = [0,    0,  0];
            y0    = [0,    0,  0];
            coh0  = [0,    0,  0];
            omega = [1,    1,  1];
            folder_save_name = ['fits_flat_bounds_no_omega', folder_name_ext];

    end

    % rows: [lower, upper, initial guess]; cols: parameters [kappa, B0, a, d, coh0, y0, omega]
    params = cat(1, kappa, B0, a, d, coh0, y0, omega);
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
            fn_fit    = @(theta) wrapper_dtb_parametricbound_rt_extATT( ...
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
