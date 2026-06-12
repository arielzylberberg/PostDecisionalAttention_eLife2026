function p = do_calc_and_plot_magnitude_effect(d,m,idx,idx_m, recalc_flag)

if nargin<5 || isempty(recalc_flag)
    recalc_flag = 1;
end

%%

if recalc_flag

    if nargin<3 || isempty(idx)
        idx = true(size(d.choice));
    end
    
    if nargin<4 || isempty(idx_m)
        idx_m = true(size(m.choice));
    end
    
    %% calc
    [~, RTres{1}, suma{1}] = magnitude_effect_RT_residuals(d.RT(idx), d.group(idx),d.vright(idx), d.vleft(idx));
    [~, RTres{2}, suma{2}] = magnitude_effect_RT_residuals(m.RT(idx_m), m.group(idx_m), m.values(idx_m,2), m.values(idx_m,1));

    save preprodata_magnitude_effect RTres suma
    
else
    load preprodata_magnitude_effect

end
%% plot
p = publish_plot(1,1);

% colores = [0,0,0;1,0,0];
c = get_colores();
colores = [c.data; c.model];

% data: dots with error bars
I = ~isnan(RTres{1});
[tt, xx, ss] = curva_media(RTres{1}, suma{1}, I, 0);
terrorbar(tt, xx, ss, 'color', colores(1,:), 'LineStyle', 'none', 'Marker', '.');
hold all

% model: shaded bars
I = ~isnan(RTres{2});
[tt, xx, ss] = curva_media(RTres{2}, suma{2}, I, 0);
niceBars2(tt, xx, ss, colores(2,:), 0.4);
hold all

% regression lines for both
for i = 1:2
    I = ~isnan(RTres{i});
    beta = glmfit(suma{i}(I), RTres{i}(I));
    xli = xlim;
    hl(i) = plot(xli, xli*beta(2) + beta(1), 'color', colores(i,:));
    hold all
end
xlabel({'Overall value','(left + right)'})
ylabel('RT residual [s]')
    
p.format('FontSize',12,'LineWidthPlot',1,'LineWidthAxes',0.5);

end