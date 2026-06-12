function p = psychometric_split_by_last_fix_and_total_value_unsigned(d, idx_glob)


if nargin==1
    idx_glob = abs(d.vright-d.vleft)<=5;
end

% average_over_Ss_flag = 1;
fitLogistic = 1;

c = get_colores();
color_data = c.data;
color_data_points = c.data_last_fix;
% color_data_last_fix = c.data_last_fix;


% prep
focus_last = d.focus_last(:);
s = d.vright + d.vleft;
% dv = d.dv; % right minus left
choice = d.choice;
group = d.group;


choose_fix_last = choice == focus_last;
dv = d.dv;
dv(focus_last==0) = -1 * dv(focus_last==0);


p = publish_plot(1,1);


I = zeros(numel(s),2);

% median split by participant (low and high sum value)
u = nanunique(group);
for i=1:length(u)
    K = group==u(i) & idx_glob==1 & ~isnan(focus_last);
    I(K,1) = s(K)<nanmedian(s(K));
    I(K,2) = s(K)>=nanmedian(s(K));
end



for i=1:size(I,2) % median splits

    [tt,xx] = curva_media_hierarch(choose_fix_last,dv,group, idx_glob & I(:,i)==1,0);

    if fitLogistic
        [params, logisticFun] = fitLogisticLeastSquares(tt,nanmean(xx,2));
        xFine = linspace(nanmin(dv(idx_glob)),nanmax(dv(idx_glob)),100);
        h(i) = plot(xFine, logisticFun(params, xFine),'color',color_data_points(i,:));
    end
    hold all
end

% so data points are above curve
for i=1:size(I,2) % median splits

    [tt,xx] = curva_media_hierarch(choose_fix_last,dv,group, idx_glob & I(:,i)==1,0);

    terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data_points(i,:),'marker','o','linestyle','none','MarkerFaceColor',color_data_points(i,:),...
        'MarkerEdgeColor','w');
    hold all
    
end

legend(h,'Sum value LOW','Sum value HIGH');

ylabel('P(last fixated item chosen)');
% xlabel('v_{last fixed} - v_{other}');
xlabel({'Last fixated rating','minus other rating'});


end

