function p = do_plot_few_trials_gaze(t, focus, RT, DT)

if nargin<4
    DT = [];
end

p = publish_plot(1,1);

n = length(RT);
for itr=1:n

    ind = focus(itr,:)==1;
    if sum(ind)>0
        plot(t(ind), itr, 'b.');
    end
    hold all
    ind = focus(itr,:)==0;
    if sum(ind)>0
        plot(t(ind), itr,'r.');
    end

    hold all
    
    plot([RT(itr),RT(itr)],[itr,itr],'k','marker','o','markerfacecolor','k');

%     drawnow    
end

if ~isempty(DT)

    for itr=1:n
        hold all
        h(itr) = plot([DT(itr),DT(itr)],[itr,itr+0.5],'k-');
    end
    
    set(h,'linewidth',1);
end

xlabel('Time [s]');
ylabel('Trial');
p.format('FontSize',14,'MarkerSize',[3,3]);
