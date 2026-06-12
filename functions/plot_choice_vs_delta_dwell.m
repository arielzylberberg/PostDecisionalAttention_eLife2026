function p = plot_choice_vs_delta_dwell(d,m)

prc = [0:10:100];

c = get_colores();

p = publish_plot(1,1);

dw = d.delta_dwell;
[~,v] = index_prctile_by_group(jitter(dw), prc, d.group);
[tt,xx,ss] = curva_media(d.choice, v,[],0);
terrorbar(tt,xx,ss,'color',c.data,'marker','o','LineStyle','none','MarkerFaceColor','k');

dt = m.t_focus(2) - m.t_focus(1);
dwm = dt * (sum(m.focus==1,2)-sum(m.focus==0,2));
[~,v] = index_prctile_by_group(dwm, prc, m.group);
hold all
[tt,xx,ss] = curva_media(m.choice, v,[],0);
hold all
niceBars2(tt,xx,ss,c.model,0.4);

symmetric_x(gca);

plot(xlim,[0.5,0.5],'k:');
plot([0,0],ylim,'k:');
xlim([-1.5,1.5]);

xlabel('Dwell Left - Dwell Right [s]');
ylabel('P (choose left item)');

