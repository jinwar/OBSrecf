function plot_3D_disp(recfs,evids,win)

pre_filter = [0.2 2];
figure(68)
clf
hold on

for i = 1:length(evids)
	ie = evids(i)
	dataZ = recfs(ie).dataZ;
	dataR = recfs(ie).dataR;
	dataT = recfs(ie).dataT;
	timeaxis = recfs(ie).data_taxis;
	delta  = timeaxis(2)-timeaxis(1);
	P_time = recfs(ie).P;

	% apply pre-filter
	fN = 1/2/delta;
	[b,a] = butter(2,[pre_filter(1)/fN, pre_filter(2)/fN]);
	dataZ = filter(b,a,dataZ);
	dataR = filter(b,a,dataR);
	dataT = filter(b,a,dataT);
	ab_win = win+P_time;
	ind = find(timeaxis > ab_win(1) & timeaxis < ab_win(2));
	plotZ = detrend(dataZ(ind));
	plotR = detrend(dataR(ind));
	plotT = detrend(dataT(ind));
	normamp = max(abs([plotZ(:);plotR(:);plotT(:)]));
	plotZ = plotZ/normamp;
	plotR = plotR/normamp;
	plotT = plotT/normamp;
	plot3(plotR,plotT,plotZ);
end
patch([0 0 0 0]',[1 1 -1 -1]',[1 -1 -1 1]','r','facealpha',0.2)
grid on
