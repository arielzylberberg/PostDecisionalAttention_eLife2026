function [choice, DT] = sample_choice_DT_from_P(P, nreps)


t = P.t;

pup = P.up.pdf_t(P.trial_idx,:);

plo = P.lo.pdf_t(P.trial_idx,:);
T = [t(:);t(:)]; 
nt = length(t);
% sum(pup,2) + pup(plo,2)

n = size(pup,1);
choice = nan(n,nreps);
DT = nan(n,nreps);
for i=1:n
    W = [plo(i,:), pup(i,:)];
    y = randsample(1:(2*nt),nreps, 1, W); 
    choice(i,:) = y>nt;
    DT(i,:) = T(y);

end