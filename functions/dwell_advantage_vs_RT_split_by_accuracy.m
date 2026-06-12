function [p, out] = dwell_advantage_vs_RT_split_by_accuracy(delta_gaze, RT, choice, dv, group, do_plot_flag)


if nargin <6 || isempty(do_plot_flag)
    do_plot_flag = 1;
end


% dt = t(2)-t(1);

%%

[~,groupby] = index_prctile_by_group(RT,0:10:100,group);
% [~,groupby] = index_prctile_by_group(RT,0:20:100,group);

I = choice==0;
delta_gaze_signed = delta_gaze;
delta_gaze_signed(I,:) = -1*delta_gaze_signed(I,:);


correct = nan(size(choice));
I = (dv>0 & choice==1) | (dv<0 & choice==0);
correct(I) = 1;
I = (dv>0 & choice==0) | (dv<0 & choice==1);
correct(I) = 0;

%% delta gaze split by accuracy

out = struct();

av_per_subj_flag = 1;
if av_per_subj_flag

    [tt,xx,ss] = curva_media_hierarch(delta_gaze_signed,group,groupby,correct==1,0);
    out.correct.t = nanunique(groupby);
    out.correct.x = nanmean(xx,1);
    out.correct.s = stderror(xx,1);

    [tt,xx,ss] = curva_media_hierarch(delta_gaze_signed,group,groupby,correct==0,0);
    out.error.t = nanunique(groupby);
    out.error.x = nanmean(xx,1);
    out.error.s = stderror(xx,1);

else

    [tt,xx,ss] = curva_media(delta_gaze_signed,groupby,correct==1,0);
    out.correct.t = tt;
    out.correct.x = xx;
    out.correct.s = ss;

    [tt,xx,ss] = curva_media(delta_gaze_signed,groupby,correct==0,0);
    out.error.t = tt;
    out.error.x = xx;
    out.error.s = ss;
end



if 0
    depvar = delta_gaze_signed;
    indepvar = {'group',adummyvar(group),'RT',adummyvar(group).*RT,'consistency',correct};
    testSignificance.vars = [1,2,3];
    [~,idx_var,stats,~,LRT] = f_regression(depvar,[],indepvar,testSignificance);

else % TESTING!!

    depvar = delta_gaze_signed;
    indepvar = {'group',adummyvar(group),'RT',adummyvar(group).*RT,'consistency',correct,'dv',adummyvar(group).*dv};
    testSignificance.vars = [1,2,3, 4];
    [~,idx_var,stats,~,LRT] = f_regression(depvar,[],indepvar,testSignificance);

end



out.stats = stats;
out.LRT = LRT;
out.idx_var = idx_var;

% colores = cbrewer('qual','Set2',3);


if do_plot_flag
    colores = movshon_colors(3);
    p = publish_plot(1,1);
    p.next();

    terrorbar(out.correct.t,out.correct.x,out.correct.s,'color',colores(1,:),'marker','o','markerfacecolor',colores(1,:));
    hold all

    terrorbar(out.error.t,out.error.x,out.error.s,'color',colores(2,:),'marker','o','markerfacecolor',colores(2,:));
    hl = legend('consistent choices','inconsistent choices');

    ylabel('\Delta gaze bias [s]');
    xlabel('Response time [s]');

    p.format('FontSize',14,'LineWidthPlot',1.0,'MarkerSize',7);
else
    p = [];
end

end
