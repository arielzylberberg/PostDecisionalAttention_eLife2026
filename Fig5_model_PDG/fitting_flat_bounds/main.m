function main()
% Fits the PDG model with flat (non-collapsing) bounds to behavioral data.
%
% Same as fitting/main.m but with the bound collapse parameter (a) fixed to zero.
%
% Parameters fitted per subject: kappa, ndt_mu, ndt_sigma, B0, [a=0], d, coh0, y0, noise_scaling
%
% Requires: BADS toolbox (https://github.com/acerbilab/bads)
% Output: fit results saved to ./fits/

addpath('../../functions/');
addpath(genpath('../../matlab_functions/'));
addpath('../fitting/');
% NOTE: Add the BADS toolbox to your path before running:

%%
redo_fit = 1;
overwrite = 1;
savedir = './fits';

%% load data

aux = load('../../data/data_krajbich2010.mat', 'dv', 'vright', 'vleft', 'RT', 'choice', 'group');
d.dv     = aux.dv;
d.vright = aux.vright;
d.vleft  = aux.vleft;
d.RT     = aux.RT;
d.choice = aux.choice;
d.group  = aux.group;

%% prep data

uni_suj = unique(d.group);

if redo_fit
    try
        parpool('local', 10);
    catch
    end
end

if redo_fit
    parfor isuj = 1:length(uni_suj)

        suj = uni_suj(isuj);
        savefilename = ['fit_output_suj', num2str(suj), '.mat'];
        filename = fullfile(savedir, savefilename);

        if overwrite || ~exist(filename, 'file')

            I = d.group == suj & ~isnan(d.RT) & ~isnan(d.choice);
            coh          = d.dv(I);
            rt           = d.RT(I);
            noise_multip = single(abs(d.vright(I)) + abs(d.vleft(I)));
            choice       = d.choice(I);

            %% fitting (flat bounds: upper bound on 'a' is 0)
            plot_flag = false;
            pars      = struct('USfunc', 'Exponential');
            fn_fit    = @(theta) wrapper_dtb_parametricbound_rt_scale_noise( ...
                            theta, rt, coh, noise_multip, choice, [], pars, plot_flag);

            % parameter bounds: kappa, ndt_mu, ndt_sigma, B0, a (fixed=0), d, coh0, y0, noise_scaling
            tl = [0.05, 0.01, 0.01, -0.5, 0, 0, 0, 0, 0];
            th = [3,    1.5,  0.4,   4,   0, 0, 0, 0, 1];
            tg = [1,    0.5,  0.05,  1.5, 0, 0, 0, 0, 0.1];

            options = optimset('Display', 'final', 'TolFun', 0.1, 'FunValCheck', 'on');

            [theta, fval] = bads(@(theta) fn_fit(theta), tg, tl, th, tl, th, options);

            tosave = struct('theta', theta, 'fval', fval);
            save_parallel(filename, tosave, 0);
        end

    end
end

%% collect and save all fits
if redo_fit
    for suj = 1:length(uni_suj)
        savefilename = ['fit_output_suj', num2str(suj)];
        aux          = load(fullfile(savedir, savefilename));
        vTheta{suj}  = aux.theta;
        vFval{suj}   = aux.fval;
    end
    save(fullfile('./fits', 'fits'), 'vTheta', 'vFval');
end

end
