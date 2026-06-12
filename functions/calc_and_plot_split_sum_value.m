function [pregre,pch,B,PVAL] = calc_and_plot_split_sum_value(d)

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
agroup = adummyvar(d.group);
depvar = ch(I);
indepvar = {'dv',dv(I).*agroup(I,:),'bias',agroup(I,:),'last', (to_vec(d.focus_last(I))==1), ...
    'last_x_sumvalue', s(I) .* (to_vec(d.focus_last(I))==1)};
[beta,idx,stats,x,LRT] = f_regression(depvar,[],indepvar);

B = beta([idx.last, idx.last_x_sumvalue]);
S = stats.se([idx.last, idx.last_x_sumvalue]);
PVAL = stats.p([idx.last, idx.last_x_sumvalue]);

vrange = [0,20];
plot(vrange, B(1) + B(2)*vrange,'k--');
hold all

%%

% the percentiles

dv = d.dv;
agroup = adummyvar(d.group);
depvar = ch(I);
indepvar = {'dv',dv(I).*agroup(I,:),'bias',agroup(I,:),'last', aIDX .* (to_vec(d.focus_last(I))==1)};
[beta,idx,stats,x,LRT] = f_regression(depvar,[],indepvar);
B = beta(idx.last);
S = stats.se(idx.last);

[~,suma] = curva_media(s, IDX,~isnan(IDX),0);



terrorbar(suma,B,S,'marker','o','color','k','LineStyle','none','markerfacecolor','k','markeredgecolor','w');
% xlabel('r_{left} + r_{right}');
xlabel('Overall value (\Sigmar)');
% ylabel('Influence of last fixation on choice (\beta)');
% ylabel({'Association between','last-dwell focus and choice (\beta)'});
ylabel({'Association of last dwell','with choice (\beta)'})
pregre.format();

%else % interaction with sum value



% end

%%

%p.next();
% psychometric median-split by s
% pch = psychometric_split_by_last_fix_and_total_value(d);
pch = psychometric_split_by_last_fix_and_total_value_unsigned(d);

drawnow
end