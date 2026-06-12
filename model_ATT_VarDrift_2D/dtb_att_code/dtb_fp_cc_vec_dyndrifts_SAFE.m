function P = dtb_fp_cc_vec_dyndrifts_SAFE(drift_t_matrix,t,Bup,Blo,y,y0,notabs_flag,varargin)
% Chang-Cooper method to solve 1D FP with multiple (vector) drifts over time.
% Stable version with drift clipping (limits |Pe|) and diagonal regularization.
%
% Usage (backward-compatible):
%   P = dtb_fp_cc_vec_dyndrifts(drift_t_matrix,t,Bup,Blo,y,y0,notabs_flag)
% Optional name-value pairs in varargin:
%   'var'     : diffusion variance (default 1)
%   'eps_reg' : small ridge added to matrix diagonal (default 1e-12)
%   'pe_clip' : clamp |Peclet| = |mu*dy/var| to this value (default 50)
%
% 2015  AZ wrote original
% 2022  AZ added matrix-of-drifts support
% 2025  Stable: clipping + ridge (this version)

% ---------- Parse options ----------
var     = 1;
eps_reg = 1e-9;     % tiny diagonal ridge
pe_clip = 20;        % max |Pe| -> avoids overflow/ill-conditioning
i = 1;
while i <= numel(varargin)
    if ischar(varargin{i}) || (isstring(varargin{i}) && isscalar(varargin{i}))
        key = lower(string(varargin{i}));
        switch key
            case "var",      var = varargin{i+1};
            case "eps_reg",  eps_reg = varargin{i+1};
            case "pe_clip",  pe_clip = varargin{i+1};
        end
        i = i + 2;
    else
        i = i + 1;
    end
end

% ---------- Basic sizes ----------
dt = t(2) - t(1);
dy = y(2) - y(1);
ny = length(y);
nt = length(t);

% Expand any flat bounds
if numel(Bup)==1, Bup = repmat(Bup,nt,1); end
if numel(Blo)==1, Blo = repmat(Blo,nt,1); end

P = struct('drift',drift_t_matrix,'t',t,'Bup',Bup,'Blo',Blo,'y',y,'y0',y0,...
    'notabs_flag',notabs_flag);

nd = size(drift_t_matrix,1);

% ---------- Outputs ----------
P.up.pdf_t = zeros(nd,nt);
P.lo.pdf_t = zeros(nd,nt);
if notabs_flag
    P.notabs.pdf = zeros(nd,ny,nt);
end
p_threshold = 1.0E-5; % stop when essentially all trajectories have absorbed

% ---------- Helpers ----------
% Clip drift to keep |Pe| = |mu*dy/var| <= pe_clip
drift_clip_val = (pe_clip * var) / max(dy, realmin);   % avoid /0
clip_mu = @(mu) max(min(mu, drift_clip_val), -drift_clip_val);

% Assemble stable matrix for the first time slice
mu0 = clip_mu(drift_t_matrix(:,1));
M   = chang_cooper_sparsematrix(mu0, nd, ny, dy, dt, var);

% Add tiny diagonal ridge to keep the system well-conditioned
% (scale ridge relative to matrix norm to be safely negligible)
if eps_reg > 0
    M = M + eps_reg * speye(nd*ny);
end

% ---------- Time stepping ----------
yr = repmat(y(:),nd,1);
u  = repmat(y0(:),nd,1);

for k = 2:nt
    % Implicit step
    u = M \ u;
    ur = reshape(u,ny,nd);
    
    % Hitting (absorption) at bounds
    P.up.pdf_t(:,k) = sum(ur(y>=Bup(k),:),1);
    P.lo.pdf_t(:,k) = sum(ur(y<=Blo(k),:),1);

    % Zero out-of-bounds mass for next step
    outofbounds = yr<=Blo(k) | yr>=Bup(k);
    u(outofbounds) = 0;

    % Save full density if requested
    if notabs_flag
        ur(y>=Bup(k),:) = 0;
        ur(y<=Blo(k),:) = 0;
        P.notabs.pdf(:,:,k) = ur';
    end
    
    % Early stop if all conditions have terminated
    if sum(sum(ur,1) < p_threshold) == nd
        % Fill remaining times with zeros (already default) and break
        break;
    end
    
    % Update matrix if drift changed at this time
    if any(drift_t_matrix(:,k) ~= drift_t_matrix(:,k-1))
        muk = clip_mu(drift_t_matrix(:,k));
        M   = chang_cooper_sparsematrix(muk, nd, ny, dy, dt, var);
        if eps_reg > 0
            M = M + eps_reg * speye(nd*ny);
        end
    end
end

% ---------- Summaries ----------
if notabs_flag
    P.notabs.pos_t = sum(P.notabs.pdf(:,y'>=0,:),2);
    P.notabs.neg_t = sum(P.notabs.pdf(:,y'< 0,:),2);
end

P.up.p = sum(P.up.pdf_t,2);
P.lo.p = sum(P.lo.pdf_t,2);

t = t(:);
P.up.mean_t = transpose(t' * P.up.pdf_t') ./ P.up.p;
P.lo.mean_t = transpose(t' * P.lo.pdf_t') ./ P.lo.p;

P.up.cdf_t = cumsum(P.up.pdf_t,2);
P.lo.cdf_t = cumsum(P.lo.pdf_t,2);

end
