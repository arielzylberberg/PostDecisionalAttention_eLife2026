function [logl,pPred,pChoiceT] = logl_choice_dec_time(p_up_pdf,p_lo_pdf,choice,dec_step)

% t = P.t;

%convolve for non-decision times
%sanity check
ntr = length(choice);


% upDT = P.up.pdf_t; % it is dectime actually
% loDT = P.lo.pdf_t; %


% dect_step = ceil(dec_time/dt);
% [ucoh,~,idx_coh] = unique(coh,'rows');
% ncoh = size(ucoh,1);
p_up = nan(ntr,1);
p_lo = nan(ntr,1);

for i=1:ntr
    p_up(i) = p_up_pdf(i,dec_step(i));
    p_lo(i) = p_lo_pdf(i,dec_step(i));
end
% for i=1:ncoh
% %     inds = coh == ucoh(i);
%     inds = idx_coh==i;
%     %if RT too long, clamp to last
%     J = min(dect_step(inds),nt);
%     p_up(inds) = upDT(i,J);
%     p_lo(inds) = loDT(i,J);
% end

%correct prob by the prob. that the ndt
%is below zero. ?
% ptrunk = 1./(1-normcdf(0,rt-ndt_m,ndt_s));
% p_up = p_up.*ptrunk;
% p_lo = p_lo.*ptrunk;

%clip
p_up(p_up<eps | isnan(p_up) | isinf(p_up)) = eps;
p_lo(p_lo<eps | isnan(p_lo) | isinf(p_lo)) = eps;
pPred = p_up.*(choice==1) + p_lo.*(choice==0);

% pUpGivenDecTime = p_up./(p_up+p_lo);

pChoiceT = [p_lo, p_up];

logl = -sum(log(pPred));
% logl = -nanmean(log(pPred));