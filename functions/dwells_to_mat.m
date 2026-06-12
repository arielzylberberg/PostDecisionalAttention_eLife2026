function ATT = dwells_to_mat(dwells, dt_sec, max_time_steps)
% change the format of the dwells, from cell to a matrix with dimensions
% ntr x ntimes, where ntimes has a resolution of dt_msec 

ntr = length(dwells);
% maxt = 10000/dt_msec;% in time steps

ATT = nan(ntr,max_time_steps);
for i=1:ntr
    % out.dwells(i).len
    % out.dwells(i).roi
    e = [0;cumsum(dwells(i).len)] / dt_sec;
    e = round(e);
    
    e(e>max_time_steps) = []; % up to max_time_steps

    for j=1:length(e)-1
        ind = (e(j)+1):e(j+1);
        val = dwells(i).roi(j);
        ATT(i,ind) = val;
    end
end

end