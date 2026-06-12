function dw = focus_to_dwells(focus, t)

dt = t(2)-t(1);
focus_interp = focus;
focus_interp(isnan(focus_interp)) = -1;
focus_interp = do_interpolate(focus_interp); % interpolate!
for i=1:size(focus_interp,1)
    [start, val, len, rn] = RunsCount(focus_interp(i,:));
    I = ismember(val,[0,1]);
    dwells(i).roi = val(I);
    dwells(i).len = len(I)*dt;
end


% in mat form
max_num_dwells = 30;
ntr = size(focus,1);
dw.roi = nan(ntr,max_num_dwells);
dw.len = nan(ntr,max_num_dwells);
for i=1:ntr
    nn = min(length(dwells(i).roi), max_num_dwells);
    ind = 1:nn;
    dw.roi(i,ind) = dwells(i).roi(ind);
    dw.len(i,ind) = dwells(i).len(ind);
end

dw.num_dwells = sum(~isnan(dw.roi),2);

dw.delta_dwell = nansum(dw.len.*(dw.roi==1),2) - nansum(dw.len.*(dw.roi==0),2);


% last_dwell before NaN
I = dw.num_dwells>0;
dw.last_dwell = nan(ntr,1);
IND = sub2ind(size(dw.roi),find(I),dw.num_dwells(I));
dw.last_dwell(I) = dw.roi(IND)';

dw.last_dwell_dur = nan(ntr,1);
dw.last_dwell_dur(I) = dw.len(IND)';

end