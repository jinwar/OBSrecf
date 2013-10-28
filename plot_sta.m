%function plot_sta(stnm,comp)
%% function to plot all the event waveforms of a single station
%  function plot_sta(stnm,comp)

clear;
stnm = 'AGAN'; comp = 'BHZ';
files = dir(['./data/',stnm,'/*.Rrec.sac']);

eventnum = length(files);

for ie = 1:eventnum
	filename = fullfile('data',stnm,strrep(files(ie).name,'Rrec',comp));
	sac= readsac(filename);
	% setup useful variables
	npts = sac.NPTS;
	delta = sac.DELTA;
	datastr(ie).taxis = sac.B:delta:delta*(npts-1)+sac.B;
	datastr(ie).data = sac.DATA1(:);
	datastr(ie).filename = filename;
	datastr(ie).otime = datenum(sac.NZYEAR,1,1,sac.NZHOUR,sac.NZMIN,sac.NZSEC) + sac.NZJDAY - 1;
	
	sac= readsac([filename,'.o']);
	otime = datenum(sac.NZYEAR,1,1,sac.NZHOUR,sac.NZMIN,sac.NZSEC) + sac.NZJDAY - 1;
	datastr(ie).marker = sac.T1 + (otime - datastr(ie).otime)*24*3600;
	if isempty(datastr(ie).marker)
		disp(filename)
	end
end

plot_waveforms(33,datastr);
