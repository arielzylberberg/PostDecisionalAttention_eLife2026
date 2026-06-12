function ATT = sample_attention_switches_from_pd(ntrials,ntimes,pd,init_bias,dt,switch_time_cost)
% reminder: pd = [pf_first, pd_notfirst];


if nargin<6 || isempty(switch_time_cost)
    switch_time_cost = 0;
end

ATT = zeros(ntrials,ntimes);
ATT(:,1) = rand(ntrials,1)<init_bias; % random

time_cost_steps = round(switch_time_cost / dt);

samp_last_switch = ones(ntrials,1); %


if length(pd)==1
    pd = [pd,pd]; % the first is for the first fix, the second one is for the other ones
end

switch_step = samp_last_switch + round(pd(1).random(ntrials,1)/dt);

for i=2:ntimes
    I = switch_step==i;
    
    nn = min(ntimes,i + time_cost_steps);
    
    ATT(I, nn) = 1 - ATT(I,i-1); % switch
    ATT(I,i:nn-1) = 2; % switch cost, do nothing
    
    % no switch and not in refractory period
    J = ~I & ATT(:,i-1)~=2;
    ATT(J,i) = ATT(J,i-1); % no switch
    
    samp_last_switch(I) = i;
    switch_step(I) = time_cost_steps + samp_last_switch(I) ...
        + round(pd(2).random(sum(I),1)/dt);
end


end