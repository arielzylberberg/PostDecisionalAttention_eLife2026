function run_dtb_fake_data_attention_shift(values_flag)


addpath('../functions/');
addpath(genpath('../matlab_functions/'));


if nargin==0
    values_flag = 'uniform';
end

%%

load ../prepro_dwell_time_distrib/dwell_duration_pd.mat
pd = [pd_first, pd_middle];

d = load('../prepro_krajbich2010/data_krajbich2010.mat');

p_start_with_right = 1 - nanmean(d.first_fix_loc_with_interp);

do_save_model_flag = 1;

params = load('../prepro_aDDM_parameter_conversion/params_fits_krajbich2010.mat');



%%


switch values_flag
    case 'as_exp'
        values = [d.vleft, d.vright];
        nreps = 10;
        values = repmat(values,nreps,1);
%         I = abs(diff(values,[],2))<=5;
        I = ~any(isnan(values),2);
        values = values(I,:);
        group = repmat(d.group, nreps, 1);
        group = group(I);



    case 'uniform'
        % this is how Krajbich does it (?), repeating each unique pair many
        % times... it is wrong since the pairs are not balanced in the data
        values = [d.vleft, d.vright, d.group];
        uni_values = unique(values,'rows');
        I = ~any(isnan(uni_values),2);
        uni_values = uni_values(I,:);
        nreps_per_pair = 10;
        values = repmat(uni_values,nreps_per_pair,1);
        group = values(:,3);
        values = values(:,[1,2]);

    case 'uniform_same'
        % this is how Krajbich does it (?), repeating each unique pair many
        % times... it is wrong since the pairs are not balanced in the data
        values = [d.vleft, d.vright];
        uni_values = unique(values,'rows');
        I = ~any(isnan(uni_values),2);
        uni_values = uni_values(I,:);
        nreps_per_pair = 400;
        values = repmat(uni_values,nreps_per_pair,1);
        group = values(:,3);
        values = values(:,[1,2]);

end

savefilename = ['sim_dat_',values_flag];

t = [0:0.001:15];
seed = 5830;
m = dtb_fake_data('Brectif',-1000,'srho', -1 ,'USfunc','Exponential','a',0,...
    'd',0,'t',t,'B0',params.B,'kappa',params.kappa,...
    'values',values,...
    'y0',0.0,...
    'ndt_mu',params.t_nd,'ndt_sigma',0.0,...
    'p_start_with_right',p_start_with_right,...
    'boost',params.omega,...
    'pd',pd,... 
    'seed',seed);


m.make_fakedata();

m.diffuse_to_bound();

% m.do_basic_plots();

% compare w/ data



% plot model & data choice & RT
% d = out;




%% split by last fix
att = motionenergy.remove_post_decision_samples(m.attention_focus, m.t, m.decision_time);
[datamp,timeslocked] = eventlockedmatc(att,m.t,m.decision_time);
tind = findclose(timeslocked,0)-1;
f_last = datamp(tind,:);

%%
if do_save_model_flag
    % now make left positive
    
    sim_data.choice = m.winner==2;
    
    sim_data.vright = m.values(:,2);
    sim_data.vleft = m.values(:,1);
    sim_data.values = m.values;
    sim_data.dv = m.values(:,1) - m.values(:,2);
    sim_data.group = ones(size(m.coh));
    sim_data.RT = m.RT;
    sim_data.DecTime = m.decision_time;
    sim_data.focus_last = f_last==0;

    sim_data.focus = 1 - att;
    sim_data.t_focus = m.t;

    sim_data.group = group;
    save(savefilename,'-struct','sim_data','-v7.3');
end

end