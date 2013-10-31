function sta_recf_cal_Q(stnm,Vp,VpVs);
%% function to calculate the all the receiver funtions of one station
%	written by Ge jin, jinwar@gmail.com, 2013-10-27

%clear
%stnm = 'E'
pre_filter = [0.2 2];
gauss_para = 2;
waterlevel = 0.01;
timeshift = 5;
rel_cut_win = [-5 60];
Vp_water = 1.5;
Vs = Vp./VpVs;

files = dir(['./data/',stnm,'/*.Rrec.sac']);

eventnum = length(files);

for ie = 1:eventnum
	% read in the data
	filename = fullfile('data',stnm,strrep(files(ie).name,'Rrec','BHZ'));
	disp(filename);
	sacBHZ = readsac(filename);
	sac = readsac([filename,'.o']);
	filename(end-4) = 'E';
	sacBHE = readsac(filename);
	filename(end-4) = 'N';
	sacBHN = readsac(filename);

	% setup useful variables
	npts = sacBHZ.NPTS;
	delta = sacBHZ.DELTA;
	timeaxis = sacBHZ.B:delta:delta*(npts-1)+sacBHZ.B;
	dataZ = sacBHZ.DATA1;
	dataN = sacBHN.DATA1;
	dataE = sacBHE.DATA1;
	baz = sacBHZ.BAZ;
	Raz = baz + 180;
	Taz = Raz + 90;
	dataR = dataN*cosd(Raz) + dataE*sind(Raz);
	dataT = dataN*cosd(Taz) + dataE*sind(Taz);
	recfs(ie).otime = datenum(sacBHZ.NZYEAR,1,1,sacBHZ.NZHOUR,sacBHZ.NZMIN,sacBHZ.NZSEC) + sacBHZ.NZJDAY - 1;
	otime = datenum(sac.NZYEAR,1,1,sac.NZHOUR,sac.NZMIN,sac.NZSEC) + sac.NZJDAY - 1;
	marker = sac.T1 + (otime - recfs(ie).otime)*24*3600;
	cut_win = rel_cut_win + marker;
	
	% apply pre-filter
	fN = 1/2/delta;
	[b,a] = butter(2,[pre_filter(1)/fN, pre_filter(2)/fN]);
	f_dataZ = filter(b,a,dataZ);
	f_dataR = filter(b,a,dataR);
	f_dataT = filter(b,a,dataT);

	% calculate the ray parameter
	epidist = distance(sacBHZ.EVLA,sacBHZ.EVLO,sacBHZ.STLA,sacBHZ.STLO);
	P_info = tauptime('mod','prem','depth',sacBHZ.EVDP,'ph','P','deg',epidist);

	% calculate the transform matrix (Rondenay, 2009)
	rayp = P_info(1).rayparameter./(deg2km(1));
	trans_mat = zeros(3,3);
	trans_mat(1,1) = (Vs^2*rayp^2-0.5)./Vp./sqrt(1/Vp^2-rayp^2);
	trans_mat(2,2) = (0.5-Vs^2*rayp^2)./Vs./sqrt(1/Vs^2-rayp^2);
	trans_mat(1,2) = rayp*Vs^2/Vp;
	trans_mat(2,1) = rayp*Vs;
	trans_mat(3,3) = 0.5;
	datamat = [-f_dataZ(:),f_dataR(:),f_dataT(:)]';
	datamat = trans_mat*datamat;
	f_dataP = datamat(1,:)';
	f_dataSV = datamat(2,:)';
	f_dataT = datamat(3,:)';
	

	% Calculate receiver function
	[recf_taxis recf_R] = recf_cal(timeaxis,f_dataZ,f_dataR,cut_win,gauss_para,waterlevel,timeshift);
	[recf_taxis recf_SV] = recf_cal(timeaxis,f_dataP,f_dataSV,cut_win,gauss_para,waterlevel,timeshift);
	[recf_taxis recf_T] = recf_cal(timeaxis,f_dataP,f_dataT,cut_win,gauss_para,waterlevel,timeshift);

	% fill in data structure
	recfs(ie).recf_taxis = recf_taxis(:);
	recfs(ie).recf_R = recf_R(:);
	recfs(ie).recf_SV = recf_SV(:);
	recfs(ie).recf_T = recf_T(:);
	recfs(ie).evla = sacBHZ.EVLA;
	recfs(ie).evlo = sacBHZ.EVLO;
	recfs(ie).evdp = sacBHZ.EVDP;
	recfs(ie).stla = sacBHZ.STLA;
	recfs(ie).stlo = sacBHZ.STLO;
	recfs(ie).baz = baz;
	recfs(ie).dataZ = dataZ;
	recfs(ie).dataR = dataR;
	recfs(ie).dataT = dataT;
	recfs(ie).data_taxis = timeaxis;
	recfs(ie).cut_win = cut_win;
	recfs(ie).P = marker;
	recfs(ie).marker = 3;

end

recfs = sort_recfs(recfs);

% plot R receiver function 
for ie = 1:length(recfs)
	recfs(ie).plot_taxis = recfs(ie).recf_taxis;
	recfs(ie).plot_data = recfs(ie).recf_R;
end
plot_waveforms(34,recfs);
title([stnm,': R-Recf'])
set(gcf,'position',[ 0    50   600   800]);

% plot SV receiver function 
for ie = 1:length(recfs)
	recfs(ie).plot_taxis = recfs(ie).recf_taxis;
	recfs(ie).plot_data = recfs(ie).recf_SV;
end
plot_waveforms(45,recfs);
title([stnm,': SV-Recf'])
set(gcf,'position',[ 600    50   600   800]);

% plot T receiver function 
for ie = 1:length(recfs)
	recfs(ie).plot_taxis = recfs(ie).recf_taxis;
	recfs(ie).plot_data = recfs(ie).recf_T;
end
plot_waveforms(36,recfs);
title([stnm,':T Recf'])
set(gcf,'position',[ 1200    50   600   800]);

%save(['data/',stnm,'_Q.mat'],'recfs');

