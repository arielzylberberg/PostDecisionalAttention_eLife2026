function p = psychometric_split_by_last_fix_and_total_value(d, idx_glob)


if nargin==1
    idx_glob = abs(d.vright-d.vleft)<=5;
end

% average_over_Ss_flag = 1;
fitLogistic = 1;

c = get_colores();
color_data = c.data;
color_data_points = c.data_last_fix;
color_data_last_fix = c.data_last_fix;


% prep
focus_last = d.focus_last(:);
s = d.vright + d.vleft;
dv = d.dv; % right minus left
choice = d.choice;
group = d.group;

% unsigned_flag = 1;
% if unsigned_flag
%     choice = d.choice == d.focus_last(:);
%     dv = abs(d.dv);
%     focus_last = true(size(focus_last));
% end

p = publish_plot(1,1);


I = zeros(numel(s),2);

% median split by participant
u = nanunique(group);
for i=1:length(u)
    K = group==u(i) & idx_glob==1;
    I(K,1) = s(K)<nanmedian(s(K));
    I(K,2) = s(K)>=nanmedian(s(K));
end



lsty = {'--','-'};



for i=1:size(I,2) % median splits

    [tt,xx] = curva_media_hierarch(choice,dv,group, idx_glob & focus_last==1 & I(:,i)==1,0);
    h(1) = terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data_points(1,:),'marker','o','linestyle','none','MarkerFaceColor',color_data_points(1,:),...
        'MarkerEdgeColor',color_data_points(1,:));
    hold all

    if fitLogistic
        [params, logisticFun] = fitLogisticLeastSquares(tt,nanmean(xx,2));
        xFine = linspace(-5,5,100);
        plot(xFine, logisticFun(params, xFine),'color',color_data_points(1,:),'linestyle',lsty{i});
    end


    [tt,xx] = curva_media_hierarch(choice,dv,group, idx_glob & focus_last==0 & I(:,i)==1,0);
    h(2) = terrorbar(tt,nanmean(xx,2),stderror(xx,2),'color',color_data_points(2,:),'marker','o','linestyle','none','MarkerFaceColor',color_data_points(2,:),...
        'MarkerEdgeColor',color_data_points(2,:));

    if fitLogistic
        [params, logisticFun] = fitLogisticLeastSquares(tt,nanmean(xx,2));
        xFine = linspace(-5,5,100);
        plot(xFine, logisticFun(params, xFine),'color',color_data_points(2,:),'linestyle',lsty{i});
    end

    if i==1
        set(h,'MarkerFaceColor','w');
    end




end



end

