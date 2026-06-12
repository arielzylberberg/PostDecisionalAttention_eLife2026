function p = plot_gaze_kernel(att,t,RT,winner)


%%

[datamp,timeslocked] = eventlockedmatc(att,t,RT,[1000,500]/1000);

%%


t_ignore_before_resp = 0.5; % ms to ignore before the RT in the stim aligned plot

e = att;
e = motionenergy.remove_post_decision_samples(e, t, RT-t_ignore_before_resp);
e = 2*(e-0.5);
e(winner==1,:) = -1*e(winner==1,:);
% e = nanmean(e);
% [~,e] = curva_media(e,out.group,[],0); % group -> suj

da = 2*(datamp' - 0.5);
da(winner==1,:) = -1*da(winner==1,:);
% da = nanmean(da);



%% now plot
p = publish_plot(1,2);
set(gcf,'Position',[323  327  722  288]);
p.shrink(1:2,1,0.8);
p.displace_ax(1:2,0.1,2);

p.next();

tind = t<0.8;
[errorPatch(1),dataLine(1)] = niceBars2(t(tind), nanmean(e(:,tind)), 1.96 * stderror(e(:,tind)));

p.next();
tind = timeslocked>-2 & timeslocked<=0;
[errorPatch(2),dataLine(2)] = niceBars2(timeslocked(tind), nanmean(da(:,tind)), 1.96 * stderror(da(:,tind)));


set(dataLine,'linewidth',1);
set(errorPatch,'faceColor',0.5*[1,1,1]);
% set(h,'LineWidth',2,'color','r','LineStyle','-');

same_ylim(p.h_ax);
same_xscale(p.h_ax);
set(p.h_ax(2),'ycolor','none');

p.current_ax(1);
xlabel('Time from stimulus onset [s]');
ylabel('Gaze bias to chosen item');

p.current_ax(2);
xlabel('Time from RT [s]');

p.format('FontSize',14);