classdef dtb_fake_data < handle
    properties
        
        kappa = 15
        B0 = 1
        a = 0
        d = 0
        srho = -1
        ndt_mu = 0.2
        ndt_sigma = 0.01
        ndt_method_flag = 2
        coh0 = 0
        y0 = 0
        y0std = 0
        y0noise
        Brectif = -200 % a very negative val
        USfunc = 'None'
        boost = 1
        
        p_start_with_right = 0.5
        
        std_noise = 1
        seed = nan
        rstream
        
        ntr_per_coh
        ntrials
        
        pd
%         attention_shift_rate = 0; % shift attention exponentially with mean 1/attention_shift_rate
%         delta_attention_shift = 0; %relative influence of the attention shift; 1:binary effect ;0: no effect

        attention_focus
        attention_shift_flag = 1

        ucoh
        t = [0:0.001:6]
        
        noise
        momentary_evidence
        decision_variable
        ext_noise
        convolve_with_IR = false
        
        coh
        values
        
        winner
        isWinner
        decision_time
        be
        dv1_atdt
        dv2_atdt
        dv1_atbe
        dv2_atbe
        ndt
        RT
        correct
        
        conf_extra_m
        conf_extra_s
        
        confidence
        
        Bup
    end
    
    methods
        function obj = dtb_fake_data(varargin)
            for i=1:2:length(varargin)
                obj.(varargin{i}) = varargin{i+1};
            end
            obj.ntrials = size(obj.values,1);
            obj.coh = diff(obj.values,[],2);
%             obj.coh = -1 * diff(obj.values,[],2);
            obj.ucoh = unique(obj.coh);
            
            obj.set_seed();
        end
        
        function set_seed(obj)
            if isnan(obj.seed)
                %aux = rng('shuffle');
                %aux = rng('shuffle', 'twister')
                obj.seed = sum(100*clock);
            end
            % obj.rstream = RandStream('twister','Seed',obj.seed);
            rng(obj.seed,'twister');
            obj.seed
        end
        
        function make_fakedata(obj)
            
            ntimes = length(obj.t);
            
            % correlated noise
            rho = [sqrt(abs(obj.srho)) sqrt(1-abs(obj.srho)) 0; ...
                sign(obj.srho)*sqrt(abs(obj.srho)) 0 sqrt(1-abs(obj.srho))];
            ev_noise = obj.std_noise * randn(obj.ntrials,ntimes,3);%first one is shared noise
            obj.noise = cell(2,1);
            obj.noise{1} = zeros(obj.ntrials,ntimes);
            obj.noise{2} = zeros(obj.ntrials,ntimes);

            for i=1:3
                for j=1:2
                    obj.noise{j} = obj.noise{j} + squeeze(ev_noise(:,:,i) * rho(j,i));
                end
            end

            
            dt = obj.t(2) - obj.t(1);
            
            % ev

%             evup = obj.kappa * dt * (repmat(obj.values(:,1),1,ntimes));
%             evlo = obj.kappa * dt * (repmat(obj.values(:,2),1,ntimes));

            evup = obj.kappa * dt * (repmat(obj.values(:,2),1,ntimes));
            evlo = obj.kappa * dt * (repmat(obj.values(:,1),1,ntimes));
            
            % attention shifts
            %attention_shift_rate = 1; % shift exponentially with mean 1/attention_shift_rate
            
            if obj.attention_shift_flag==0
                
                s = {evup - evlo + obj.coh0, evlo - evup - obj.coh0};
                s{1}(:,end) = 1000;%to always get a response
                s{2}(:,end) = 1000;%to always get a response

                
            else
                
                ntimes = length(obj.t);
                dt = obj.t(2)-obj.t(1);
                switch_time_cost = 0;
%                 params = [1./obj.attention_shift_rate, obj.p_start_with_right];
%                 ATT = sample_attention_switches_double_exp(obj.ntrials,ntimes,params,dt,switch_time_cost);
                

                
                ATT = sample_attention_switches_from_pd(obj.ntrials,ntimes,obj.pd,obj.p_start_with_right,dt,switch_time_cost);

                
                    
                obj.attention_focus = ATT;

                attention_up = obj.attention_focus;

                attention_lo = 1-obj.attention_focus;

                evup_at_up = evup-evlo*obj.boost + obj.coh0;
                evup_at_lo = evup*obj.boost-evlo + obj.coh0;

                evlo_at_up = evlo*obj.boost-evup - obj.coh0;
                evlo_at_lo = evlo-evup*obj.boost - obj.coh0;

                s = {evup_at_up.*attention_up + evup_at_lo.*attention_lo, ...
                    evlo_at_up.*attention_up + evlo_at_lo.*attention_lo};

                %                 s = {evup.*attention_shift_up - evlo.*attention_shift_lo*obj.boost + obj.coh0, ...
                %                      evlo.*attention_shift_lo - evup.*attention_shift_up*obj.boost - obj.coh0};
                s{1}(:,end) = 1000;%to always get a response
                s{2}(:,end) = 1000;%to always get a response
                    
                
            end
            
            % one bias
            obj.y0noise = randn(obj.ntrials,2)*obj.y0std;
            s{1}(:,1) = s{1}(:,1) + obj.y0*obj.B0 + obj.y0noise(:,1);
            % s{2}(:,1) = s{2}(:,1) - obj.y0 + obj.y0noise(:,2);
            s{2}(:,1) = s{2}(:,1) + obj.y0*obj.B0 + obj.y0noise(:,2);
            for i=1:2
                s{i} = s{i} + obj.noise{i}*sqrt(dt);
            end
            %
            obj.momentary_evidence = s;
            
        end
        
        function gaze_post_decision(obj, p_switch_to_chosen_one)
            
            if nargin==0
                p_switch_to_chosen_one = 0;
            end
            dt = obj.t(2)-obj.t(1);
            dt_samp = ceil(obj.decision_time/dt);
            %             rt_samp = ceil(obj.RT/dt);
            p = rand(obj.ntrials,1)<p_switch_to_chosen_one;
            nt = length(obj.t);
            for i=nt:-1:1
                I = p & i>dt_samp;
                obj.attention_focus(I,i) = obj.winner(I) - 1;
                %                 I = p & i>rt_samp;
                %                 obj.attention_shift(I,i) = nan;
            end
            
            
        end
              
        
        function add_external_noise(obj,sigma_ext,repeat_each_column)
            % creates and adds external noise
            
            dt = obj.t(2)-obj.t(1);
            
            s = obj.momentary_evidence;
            [ntr,nt] = size(s{1});
            for i=1:3
                ext_noise{i} = randn(ntr,ceil(nt/repeat_each_column))*sqrt(dt)*sigma_ext;
            end
            
            for i=1:3 %first is shared noise
                ext_noise{i} = repeat_columns(ext_noise{i},repeat_each_column);
                ext_noise{i} = ext_noise{i}(:,1:nt);
                
                %                 s{i} = s{i} + obj.ext_noise{i};
            end
            
            %             obj.momentary_evidence = s;
            
            % use the same anti-correlation as for the races
            rho = [sqrt(abs(obj.srho)) sqrt(1-abs(obj.srho)) 0; ...
                sign(obj.srho)*sqrt(abs(obj.srho)) 0 sqrt(1-abs(obj.srho))];
            obj.ext_noise{1} = zeros(obj.ntrials,nt);
            obj.ext_noise{2} = zeros(obj.ntrials,nt);
            for i=1:3
                for j=1:2
                    obj.ext_noise{j} = obj.ext_noise{j} + ...
                        squeeze(ext_noise{i} * rho(j,i));
                end
            end
            
            
            if obj.convolve_with_IR
                IR = load('impulse_resp');
                % interpolate time
                IRr = interp1(IR.t,IR.me,obj.t * 1000);
                IRr = IRr(1:find(IRr>0,1,'last'));
                IRr = IRr(:);
                for i=1:2
                    nn = conv2(obj.ext_noise{i},IRr')/sum(IRr);
                    nn = nn(:,1:length(obj.t));
                    obj.ext_noise{i} = nn;
                end
            end
            
            for i=1:2
                % obj.ext_noise{i} = obj.ext_noise{i};
                s{i} = s{i} + obj.ext_noise{i};
            end
            
            obj.momentary_evidence = s;
        end
        
        function remove_weak_evidence(obj,thres)
            % for robust integration
            for i=1:length(obj.momentary_evidence)
                ev = obj.momentary_evidence{i};
                ev(abs(ev)<thres) = 0;
                obj.momentary_evidence{i} = ev;
            end
            
        end
        
        function diffuse_to_bound(obj)
            ev = obj.momentary_evidence;
            [obj.winner,obj.isWinner,obj.decision_time,obj.Bup,cev] = ...
                dtb_multi(ev,obj.t,obj.a,obj.d,obj.B0,obj.Brectif,obj.USfunc);
            
            obj.decision_variable = cev;
            
            obj.ndt = calc_ndt(obj.ndt_mu,obj.ndt_sigma,obj.ntrials,obj.ndt_method_flag);
            
            obj.RT = obj.decision_time + obj.ndt;
            
            %accuracy
            model_correct = nan(obj.ntrials,1);
            model_correct(obj.coh>0 & obj.winner==1 | obj.coh<0 & obj.winner==2) = 1;% correct
            model_correct(obj.coh>0 & obj.winner==2 | obj.coh<0 & obj.winner==1) = 0;% incorrect
            model_correct(obj.coh==0) = rand(sum(obj.coh==0),1)>0.5;%
            obj.correct = model_correct;
            
            obj.confidence = [];
            
        end
        
   
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% helper functions %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ndt = calc_ndt(ndt_mu,ndt_sigma,ntrials,method_flag)

% method_flag = 1;
% method_flag = 1;
switch method_flag
    case 1
        m = ndt_mu;
        s = ndt_sigma;
        v = s.^2;
        
        mm  = log((m^2)/sqrt(v+m^2));
        ss  = sqrt(log(v/(m^2)+1));
        
        ndt = lognrnd(mm,ss,[ntrials,1]);
        
    case 2
        
        m = ndt_mu;
        s = ndt_sigma;
        
        ndt = randn([ntrials,1])*s + m;
        while any(ndt<0)
            ndt(ndt<0) = randn(sum(ndt<0),1)*s + m;
        end
end


end


