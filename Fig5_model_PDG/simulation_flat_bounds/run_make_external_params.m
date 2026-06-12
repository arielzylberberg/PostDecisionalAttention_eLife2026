function run_make_external_params()
% Sets the timing parameters for synthetic eye movements (flat-bounds variant).
%
% These parameters differ from the collapsing-bounds version because the
% model's RT distribution changes with flat bounds, requiring re-calibration
% of the post-decisional gaze timing.

ndt_eye     = 0.35;
ndt_eye_s   = 0.35 / 3;
ndt_sensory = 0.3;

save('ext_model_params', 'ndt_eye', 'ndt_eye_s', 'ndt_sensory');

end
