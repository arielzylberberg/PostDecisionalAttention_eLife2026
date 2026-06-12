function P = dtb_fp_cc_vec_leak(drift,t,Bup,Blo,y,y0,notabs_flag,varargin)
% Chang-Cooper method to solve 1D fp eq.
% Oct2018: add the possibility of leaky integration
% written by Ariel Zylberberg (ariel.zylberberg@gmail.com)

var = 1;
leak_time_constant = inf; % equiv to no leak
for i=1:length(varargin)
    if isequal(varargin{i},'var')
        var = varargin{i+1};
    elseif isequal(varargin{i},'leak')
        leak_time_constant = varargin{i+1};
    end
end

dt = t(2) - t(1);
dy = y(2) - y(1);
ny = length(y);
nt = length(t);

% Expand any flat bounds
if numel(Bup)==1
    Bup = repmat(Bup,nt,1);
end
if numel(Blo)==1
    Blo = repmat(Blo,nt,1);
end

P = struct('drift',drift,'t',t,'Bup',Bup,'Blo',Blo,'y',y,'y0',y0,...
    'notabs_flag',notabs_flag,'leak_time_constant',leak_time_constant);

nd = length(drift);


Mleak = leak_matrix(leak_time_constant, y, dt);
Mleak_vec = sparse( kron(eye(nd),Mleak) );%vectorize over coherences


% Preallocate
P.up.pdf_t = zeros(nd,nt);
P.lo.pdf_t = zeros(nd,nt);
if notabs_flag
    P.notabs.pdf = zeros(nd,ny,nt);
end
p_threshold = 1.0E-5; % Threshold for proportion un-terminated to stop simulation


M = chang_cooper_sparsematrix(drift,nd,ny,dy,dt,var);

yr = repmat(y(:),nd,1);
u = repmat(y0(:),nd,1);

for k = 2:nt
    
    u = Mleak_vec * u; % calcs the leak
    u = M\u;
    ur = reshape(u,ny,nd);
    
    % Select density that has crossed bounds
    P.up.pdf_t(:,k) = sum(ur(y>=Bup(k),:),1);
    P.lo.pdf_t(:,k) = sum(ur(y<=Blo(k),:),1);

    % Keep only density within bounds
    outofbounds = yr<=Blo(k) | yr>=Bup(k);
    u(outofbounds) = 0;

    % Save if requested
    if notabs_flag
        ur(y>=Bup(k),:) = 0;
        ur(y<=Blo(k),:) = 0;
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
