function run_make_external_params()
% Sets the timing parameters for post-decisional gaze in the ATT+PD model.
%
% These parameters control when, after the decision, the gaze follows the
% chosen item (combining sensory delay + eye-movement latency).
%
% ndt_eye     : mean eye-movement latency after decision (s)
% ndt_eye_s   : std of eye-movement latency (s)
% ndt_sensory : sensory delay between decision and gaze shift (s)

ndt_eye     = 0.2;
ndt_eye_s   = 0.05;
ndt_sensory = 0.25;

save('ext_model_params', 'ndt_eye', 'ndt_eye_s', 'ndt_sensory');

end
