addpath(genpath('../../matlab_functions/'));

% load the pd of the fixations
load('../simulate_aDDM_model_real_fixations/fix_durations_minus_last','pd');

% load some dots data
load(fullfile('/Users/arielzy/Dropbox/Data/1 - LAB/15 - code/22-DTB_1D','test_data.mat'));
% keep fewer trials
idx = 1:100;
c = c(idx);
choice = choice(idx);
coh = coh(idx);
rt = rt(idx);


%%
ntr = length(rt);
values = zeros(ntr,2);
values(coh<0,1) = -1*coh(coh<0);
values(coh>0,2) = coh(coh>0);

%%

dt = 0.001; % a bit larger than usual, for speed
t  = 0:dt:10;
pars.t = t;

%%
kappa = 15;
ndt_m = 0.2;
ndt_s = 0.01;
B0    = 1;
a     = 0;
d     = 0;
coh0  = 0;
y0    = 0;
omega = 0.7;
plot_flag = 1;

theta = [kappa,ndt_m,ndt_s,B0,a,d,coh0,y0,omega];
[err,P] = wrapper_dtb_parametricbound_rt_ATT(theta,rt,values,pd,choice,c,pars,plot_flag);

%% fit
% kappa, ndt_mu, ndt_sigma, B0, a, d, coh0, y0, omega
tl = [5,  0.1, .01 ,0.5  , -1, -3,0,0,0];
th = [40, 0.7, .15 ,4    , 2 ,4,0,0,0];
tg = [15, 0.2, .02 ,1    , 0.1 ,1,0,0,0];

plot_flag = true;


fn_fit = @(theta) (wrapper_dtb_parametricbound_rt_ATT(theta,rt,values,pd,choice,c,pars,plot_flag));

options = optimset('Display','final','TolFun',.1,'FunValCheck','on');
ptl = tl;
pth = th;
[theta,fval,exitflag,output] = bads(@(theta) fn_fit(theta),tg,tl,th,ptl,pth,options);
