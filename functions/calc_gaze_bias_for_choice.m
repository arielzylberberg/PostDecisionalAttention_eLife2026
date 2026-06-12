function delta_dwell_for_choice = calc_gaze_bias_for_choice(focus, dt_att_msec, choice)


delta_dwell_for_choice = sum(focus==1,2)-sum(focus==0,2);
delta_dwell_for_choice = delta_dwell_for_choice*dt_att_msec/1000;

delta_dwell_for_choice(choice==0) = -1* delta_dwell_for_choice(choice==0);


delta_dwell_for_choice(isnan(choice)) = nan;

end


