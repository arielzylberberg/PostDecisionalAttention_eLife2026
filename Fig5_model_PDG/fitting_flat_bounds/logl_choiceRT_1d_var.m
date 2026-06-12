function [logl,pPred,upRT,loRT] = logl_choiceRT_1d_var(P,choice,rt,idx_map,ndt_m,ndt_s)

t = P.t;

%convolve for non-decision times
%sanity check
if t(1)~=0
    error('for conv to work, t(1) has to be zero');
end
nt = length(t);
dt = t(2)-t(1);
% ntr = length(P.drift);
ntr = length(choice);

method = 2;
switch method
    case 1
        ndt = normpdf(t,ndt_m,ndt_s)*dt;
    case 2
        % Oct 2018
        pd = makedist('Normal','mu',ndt_m,'sigma',ndt_s);
        pd_trunc = truncate(pd,0,inf);
        ndt = pd_trunc.pdf(P.t)*dt;
end

% should speed things up
imax = find(cumsum(ndt)>0.999999,1);
ndt = ndt(1:imax);


upRT = conv2(1,ndt(:),P.up.pdf_t);
loRT = conv2(1,ndt(:),P.lo.pdf_t);
upRT = upRT(:,1:nt);
loRT = loRT(:,1:nt);

rt_step = ceil(rt/dt);
% ucoh = unique(coh);
% ncoh = length(ucoh);
p_up = nan(ntr,1);
p_lo = nan(ntr,1);
uni_idx_map = unique(idx_map);
for i=1:length(uni_idx_map)
    inds = idx_map == uni_idx_map(i);
    %if RT too long, clamp to last
    J = min(rt_step(inds),nt);
    p_up(inds) = upRT(i,J);
    p_lo(inds) = loRT(i,J);
end

%correct prob by the prob. that the ndt
%is below zero. ?
% ptrunk = 1./(1-normcdf(0,rt-ndt_m,ndt_s));
% p_up = p_up.*ptrunk;
% p_lo = p_lo.*ptrunk;

%clip
p_up(p_up<eps | isnan(p_up)) = eps;
p_lo(p_lo<eps| isnan(p_lo)) = eps;
pPred = p_up.*(choice==1) + p_lo.*(choice==0);

logl = -sum(log(pPred));
% logl = -nanmean(log(pPred));