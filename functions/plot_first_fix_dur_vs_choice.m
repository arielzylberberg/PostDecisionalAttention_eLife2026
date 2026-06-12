function p = plot_first_fix_dur_vs_choice(d,m)

prc = [0:10:100];
% prc = [0:20:100];

c = get_colores();

p = publish_plot(1,1); 

% data
dfirst = d.first_fix_dur_with_interp;
I = ~isnan(dfirst);
[~,v] = index_prctile_by_group(jitter(dfirst(I)), prc, d.group(I));
[tt,xx,ss] = curva_media(d.choice(I)==d.first_fix_loc_with_interp(I), v,[],0);
% niceBars2(tt,xx,ss,'k',0.4);
% terrorbar(tt,xx,ss,'color',c.data,'marker','.');
terrorbar(tt,xx,ss,'color',c.data,'marker','o','LineStyle','none','MarkerFaceColor','k');

% dtb
dfirst = m.dw.len(:,1);
[~,v] = index_prctile_by_group(jitter(dfirst), prc, m.group);
hold all
[tt,xx,ss] = curva_media(m.choice == m.dw.roi(:,1), v,[],0);
niceBars2(tt,xx,ss,c.model,0.4);
% terrorbar(tt,xx,ss,'color','b','marker','.');

xlabel('First dwell duration [s]');
ylabel('P(choose item looked first)');

