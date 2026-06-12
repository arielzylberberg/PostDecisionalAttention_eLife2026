function P = dtb_fp_cn_searchbnd2(drift,t,prior,dtdist,y,y0,notabs_flag)
% crank nicholson, 1d advection diffusion

% sanity check
if length(prior)~=length(drift)
    error('error 1, wrong sizes')
end

%norm to 1
prior = prior(:)'/sum(prior);%column vec
cdtdist = cumsum(dtdist/nansum(dtdist));

dt = t(2) - t(1);
dy = y(2) - y(1);
ny = length(y);
nt = length(t);

Bup = nan(nt,1);%bound, assumed symmetric

P = struct('drift',drift,'t',t,'prior',prior,'dtdist',dtdist,'y',y,'y0',y0,...
    'notabs_flag',notabs_flag);

nd = length(drift);

% Preallocate
P.up.pdf_t = zeros(nd,nt);
P.lo.pdf_t = zeros(nd,nt);
if notabs_flag
    P.notabs.pdf = zeros(nd,ny,nt);
end
p_threshold = 1.0E-5; % Threshold for proportion un-terminated to stop simulation

% params advective diffusion equation

[A,B] = crank_nicholson_sparsematrix(drift,nd,ny,dy,dt);

% D = 0.5;% (half?) the variance of the momentary evidence; not the variance as indicated in kiani2009
% sigma = D*dt/(2*dy^2);
% 
% auxA = nan(nd*ny,3);
% auxB = nan(nd*ny,3);
% for idrift = 1:nd
%     a = -1*drift(idrift);
%     rho = a*dt/(4*dy);
%     inds = [1:ny]+ny*(idrift-1);
%     auxA(inds,:) = repmat([-sigma+rho,(1+2*sigma),-(rho+sigma)],ny,1);
%     auxB(inds,:) = repmat([sigma-rho,(1-2*sigma),sigma+rho],ny,1);
% end
% A = spdiags(auxA,-1:1,ny*nd,ny*nd);
% B = spdiags(auxB,-1:1,ny*nd,ny*nd);

yr = repmat(y(:),nd,1);

u = repmat(y0(:),nd,1);

for k = 2:nt
    
    d = B*u;
    u = A\d;
    
    ur = reshape(u,ny,nd); %maybe too slow?
    
    %search B(k)
    if mod(ny,2)==0
        urcollapsed = ur(1:ny/2,:) + ur(ny:-1:(ny/2+1),:);
        yc = -1*y(1:ny/2);
    else
        error('do it for odd ny too')
    end
%     sc = sum(sum(urcollapsed).*prior);
%     fun = @(x) (hazard(k) - sum(sum(urcollapsed(yc>=x,:)).*prior)/sc);
    
%     cdtdist(k)
%     sc = sum(sum(urcollapsed).*prior);
    fun = @(x) (1 - cdtdist(k) - sum(sum(urcollapsed(yc<x,:),1).*prior));
    
    if cdtdist(k) > 0
%     if hazard(k)>0
        x0 = max(y)/2;
        [Bup(k),~,exitflag] = fzero(fun,x0);
%         if exitflag<0
%             aa
%         end
    end
    
    % Select density that has crossed bounds
    P.up.pdf_t(:,k) = sum(ur(y>=Bup(k),:),1);
    P.lo.pdf_t(:,k) = sum(ur(y<=-Bup(k),:),1);
    
    % Keep only density within bounds
    outofbounds = yr<=-Bup(k) | yr>=Bup(k);
    u(outofbounds) = 0;

    % Save if requested
    if notabs_flag
        P.notabs.pdf(:,:,k) = ur';
    end
    
    if sum(sum(ur,1)<p_threshold)==nd
        break;
    end
    
end

if notabs_flag
    P.notabs.pos_t = sum(P.notabs.pdf(:,y'>=0,:),2);
    P.notabs.neg_t = sum(P.notabs.pdf(:,y'< 0,:),2);
end

P.up.p = sum(P.up.pdf_t,2);
P.lo.p = sum(P.lo.pdf_t,2);

t = t(:);

P.up.mean_t = transpose(t'*P.up.pdf_t')./P.up.p;
P.lo.mean_t = transpose(t'*P.lo.pdf_t')./P.lo.p;

P.up.cdf_t = cumsum(P.up.pdf_t,2);
P.lo.cdf_t = cumsum(P.lo.pdf_t,2);

P.Bup = Bup;
P.Blo = -1*Bup;