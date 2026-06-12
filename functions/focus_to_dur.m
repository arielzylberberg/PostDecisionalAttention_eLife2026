function  


dt = t(2)-t(1);
focus_interp = focus;
focus_interp(isnan(focus_interp)) = -1;
focus_interp = do_interpolate(focus_interp); % interpolate!
ntr = size(focus_interp,1);
for i=1:ntr
    [start, val, len, rn] = RunsCount(focus_interp(i,:));
    I = ismember(val,[0,1]);
    dwells(i).roi = val(I);
    dwells(i).len_steps = len(I);
    dwells(i).start_step = start(I);
end

focus_dur = nan(size(focus));
for i=1:ntr
    for j=1:length(dwells(i).start_step)
        ind = dwells(i).start_step(j):(dwells(i).start_step(j) + dwells(i).len_steps(j)-1);
        focus_dur(i, ind) = dwells(i).len_steps(j) * dt;
    end
end
    
end