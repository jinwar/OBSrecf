%% function try to clean up the receiver functions of OBSs
%	ge jin

clear;
stnm = 'AGAN';

pre_filter = [0.2 2];
gauss_para = 2;
waterlevel = 0.01;
timeshift = 5;
rel_cut_win = [-10 60];

load(['data/',stnm,'.mat']);


for ie = 1:length(recfs)
	disp(ie);
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
%	ind = find(timeaxis >= P_time & timeaxis <=P_time + 10);
%	peakazi(ie) = find_peak_azi(dataR,dataT,0);
%	odataR = dataR;
%	odataT = dataT;
%	dataR = odataR*cosd(peakazi)+odataT*sind(peakazi);
%	dataT = odataR*cosd(peakazi+90)+odataT*sind(peakazi+90);
	
%	plot_multi_waveform(33,[P_time-100 P_time+100;NaN NaN],timeaxis,dataZ,'Z',dataR,'R',dataT,'T');

	% Calculate transform function
	trans_cal_window = [0 P_time];
	N_win = round(50./delta);
	ind = find(timeaxis>=trans_cal_window(1)&timeaxis<=trans_cal_window(2));
%	[Coh_ZT,F] = mscohere(dataZ(ind),dataT(ind),N_win,N_win/2,N_win,1/delta);
%	[Coh_RT,F] = mscohere(dataR(ind),dataT(ind),N_win,N_win/2,N_win,1/delta);
	% Calculate cross-spectrum
%	[Cxy_ZT,F] = cpsd(dataZ(ind),dataT(ind),N_win,N_win/2,N_win,1/delta);
%	[Cxy_RT,F] = cpsd(dataR(ind),dataT(ind),N_win,N_win/2,N_win,1/delta);
	[Cxy_ZT,F] = cpsd(dataT(ind),dataZ(ind),N_win,N_win/2,N_win,1/delta);
	[Cxy_RT,F] = cpsd(dataT(ind),dataR(ind),N_win,N_win/2,N_win,1/delta);
	% Calculate auto-spectrum
	[Cxx_RR,F] = cpsd(dataR(ind),dataR(ind),N_win,N_win/2,N_win,1/delta);
	[Cxx_TT,F] = cpsd(dataT(ind),dataT(ind),N_win,N_win/2,N_win,1/delta);
	[Cxx_ZZ,F] = cpsd(dataZ(ind),dataZ(ind),N_win,N_win/2,N_win,1/delta);
	% Calculate coherence
	Coh_ZT = Cxy_ZT./(abs(Cxx_ZZ).*abs(Cxx_TT)).^0.5;
	Coh_RT = Cxy_RT./(abs(Cxx_RR).*abs(Cxx_TT)).^0.5;
%	plot_multi_waveform_semilogx(35,[],F,abs(Coh_ZT),'ZT',angle(Coh_ZT),'ZT',abs(Coh_RT),'RT',angle(Coh_RT),'RT');
	% Calculate transform function
	A_ZT = Coh_ZT.*sqrt(Cxx_ZZ./Cxx_TT);
	A_RT = Coh_RT.*sqrt(Cxx_RR./Cxx_TT);
	% fill in negetive freqyency
	A_ZT_fft = [A_ZT;flipud(conj(A_ZT(2:end-1)))];
	A_RT_fft = [A_RT;flipud(conj(A_RT(2:end-1)))];
	% convert to time domain
	A_ZT_t = ifft(A_ZT_fft);
	A_RT_t = ifft(A_RT_fft);

	% clean up components
	c_dataZ = dataZ - conv(dataT,A_ZT_t,'same');
	c_dataR = dataR - conv(dataT,A_RT_t,'same');
%	plot_multi_waveform(34,[P_time-100 P_time+100;NaN NaN],timeaxis,c_dataZ,'Z',c_dataR,'R',dataT,'T');
	
	% recalculate the receiver function
	cut_win = rel_cut_win + P_time;
	[recf_taxis recf] = recf_cal(timeaxis,c_dataZ,c_dataR,cut_win,gauss_para,waterlevel,timeshift);
	recfs(ie).crecf = recf(:);
end

% plot R receiver function 
for ie = 1:length(recfs)
	recfs(ie).plot_taxis = recfs(ie).recf_taxis;
	recfs(ie).plot_data = recfs(ie).recf;
end
plot_waveforms(33,recfs);
title([stnm,':R-Recf'])

% plot corrected R receiver function 
for ie = 1:length(recfs)
	recfs(ie).plot_taxis = recfs(ie).recf_taxis;
	recfs(ie).plot_data = recfs(ie).crecf;
end
plot_waveforms(35,recfs);
title([stnm,':Corrected R-Recf'])

