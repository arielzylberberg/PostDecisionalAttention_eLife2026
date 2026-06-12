% Quick sanity-check script for the ATT model wrapper.
% Shows how to call wrapper_dtb_parametricbound_rt_ATT with example parameters.
%
% This script is for development/testing purposes; it requires you to supply
% your own data in the variables: rt, values, pd (fixation duration distribution),
% choice, c (correctness), and pars (struct with time vector pars.t).

% Example parameter vector: [kappa, ndt_m, ndt_s, B0, a, d, coh0, y0, omega]
kappa = 15;
ndt_m = 0.2;
ndt_s = 0.01;
B0    = 1;
a     = 0;
d     = 0;
coh0  = 0;
y0    = 0;
omega = 0.7;

dt = 0.001;
t  = 0:dt:10;
pars.t = t;

theta = [kappa, ndt_m, ndt_s, B0, a, d, coh0, y0, omega];

% Uncomment and supply your own data to run:
% plot_flag = 1;
% [err, P] = wrapper_dtb_parametricbound_rt_ATT(theta, rt, values, pd, choice, c, pars, plot_flag);
