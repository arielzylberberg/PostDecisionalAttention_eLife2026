function [pregre,B,PVAL] = calc_and_plot_split_delta_dwell_by_sum_value(d)

s = d.vleft + d.vright;


ch = d.choice;

I = ~isnan(d.focus_last);



%if 1 % percentiles

[~,IDX] = index_prctile(s,[0:20:100]);

aIDX = adummyvar(IDX(I));


%%

% now the same with interaction with sum value, for the stats and line
% plot
pregre = publish_plot(1,1);

dv = d.dv;

% delta_dwell = d.dwell_left - d.dwell_right;

dt = d.t_focus(1,2)-d.t_focus(1,1);

focus = motionenergy.remove_post_decision_samples(d.focus, d.t_focus, d.RT);

delta_dwell = (nansum(d.focus==1,2) - nansum(d.focus==0,2)) * dt;

agroup = adummyvar(d.group);
depvar = ch(I);
indepvar = {'dv',dv(I).*agroup(I,:),'bias',agroup(I,:),'delta_dwell', delta_dwell(I), ...
    'delta_dwell_x_sumvalue', s(I) .* delta_dwell(I)};
[beta,idx,stats,x,LRT] = f_regression(depvar,[],indepvar);

B = beta([idx.delta_dwell, idx.delta_dwell_x_sumvalue]);
S = stats.se([idx.delta_dwell, idx.delta_dwell_x_sumvalue]);
PVAL = stats.p([idx.delta_dwell, idx.delta_dwell_x_sumvalue]);

vrange = [0,20];
plot(vrange, B(1) + B(2)*vrange,'k--');
hold all

%%

% the percentiles

% dv = d.vleft - d.vright;
% agroup = adummyvar(d.group);
% depvar = ch(I);
indepvar = {'dv',dv(I).*agroup(I,:),'bias',agroup(I,:),'delta_dwell', aIDX .* delta_dwell(I)};
[beta,idx,stats,x,LRT] = f_regression(depvar,[],indepvar);
B = beta(idx.delta_dwell);
S = stats.se(idx.delta_dwell);

[~,suma] = curva_media(s, IDX,~isnan(IDX),0);



terrorbar(suma,B,S,'marker','o','color','k','LineStyle','none','markerfacecolor','k','markeredgecolor','w');
xlabel('r_{left} + r_{right}');
ylabel('Influence of delta dwell on choice (\beta)');

pregre.format();

%else % interaction with sum value



% end

%%

%p.next();
% psychometric median-split by s
% pch = psychometric_split_by_last_fix_and_total_value(d);
% pch = psychometric_split_by_last_fix_and_total_value_unsigned(d);

drawnow
end