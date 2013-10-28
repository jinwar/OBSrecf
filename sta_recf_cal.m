function sta_recf_cal(stnm)
%% function to calculate the all the receiver funtions of one station
%	written by Ge jin, jinwar@gmail.com, 2013-10-27

%stnm = 'AGAN'
pre_filter = [0.2 2];
gauss_para = 2;
waterlevel = 0.01;
timeshift = 5;
rel_cut_win = [-10 60];

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
	
	% Calculate receiver function
	[recf_taxis recf] = recf_cal(timeaxis,f_dataZ,f_dataR,cut_win,gauss_para,waterlevel,timeshift);

	% fill in data structure
	recfs(ie).data = recf(:);
	recfs(ie).taxis = recf_taxis(:);
	recfs(ie).evla = sacBHZ.EVLA;
	recfs(ie).evlo = sacBHZ.EVLO;
	recfs(ie).evdp = sacBHZ.EVDP;
	recfs(ie).stla = sacBHZ.STLA;
	recfs(ie).stlo = sacBHZ.STLO;
	recfs(ie).baz = baz;

end

plot_waveforms(33,recfs);

