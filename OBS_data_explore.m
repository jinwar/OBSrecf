%% scripts to test the method to clean up OBS receiver function by calculate the transform function between
%  tangental comp and radial comp
%  written by Ge Jin, jinwar@gmail.com
%  2013.10.25

clear

bp_filter = [0.1 5];

database = 'data';
event = '20100612';
%event = '20100804';
%event = '20100904';
stnm = 'E';

% Read in data
sacfile = dir(fullfile(database,event,['*.',stnm,'.BHZ.sac']));
sacBHZ = readsac(fullfile(database,event,sacfile.name));
sacfile = dir(fullfile(database,event,['*.',stnm,'.BHE.sac']));
sacBHE = readsac(fullfile(database,event,sacfile.name));
sacfile = dir(fullfile(database,event,['*.',stnm,'.BHN.sac']));
sacBHN = readsac(fullfile(database,event,sacfile.name));

% setup useful variables
npts = sacBHZ.NPTS;
delta = sacBHZ.DELTA;
timeaxis = sacBHZ.B:delta:delta*(npts-1)+sacBHZ.B;
dataZ = sacBHZ.DATA1;
dataN = sacBHN.DATA1;
dataE = sacBHE.DATA1;

% rotation
baz = sacBHZ.BAZ;
Raz = baz + 180;
Taz = Raz + 90;
dataR = dataN*cosd(Raz) + dataE*sind(Raz);
dataT = dataN*cosd(Taz) + dataE*sind(Taz);

% filter
fN = 1/2/delta;
[b,a] = butter(2,[bp_filter(1)/fN, bp_filter(2)/fN]);
f_dataZ = filter(b,a,dataZ);
f_dataR = filter(b,a,dataR);
f_dataT = filter(b,a,dataT);

% calculate transform function
%trans_cal_window = [0 500];
%N_win = round(100./delta);
%ind = find(timeaxis>=trans_cal_window(1)&timeaxis<=trans_cal_window(2));
%[Cxy_RT,F] = cpsd(dataR(ind),dataT(ind),N_win,N_win/2,N_win,1/delta);
%[Coh_RT,F] = mscohere(dataR(ind),dataT(ind),N_win,N_win/2,N_win,1/delta);
%[Cxy_RZ,F] = cpsd(dataR(ind),dataZ(ind),N_win,N_win/2,N_win,1/delta);
%[Coh_RZ,F] = mscohere(dataR(ind),dataZ(ind),N_win,N_win/2,N_win,1/delta);
%
%axis_range = [];
%plot_multi_waveform_semilogx(33,axis_range,F,Coh_RT,'RT',angle(Cxy_RT),'RT');
%plot_multi_waveform_semilogx(34,axis_range,F,Coh_RZ,'RZ',angle(Cxy_RZ),'RZ');

% plot
xrange = [490 600];
yrange = [-1e3 1e3];
yrange = [NaN NaN];
axis_range = [xrange;yrange];
%plot_multi_waveform(78,axis_range,timeaxis,dataZ,'Z',dataR,'R',dataT,'T');
plot_multi_waveform(79,axis_range,timeaxis,f_dataZ,'Z',f_dataR,'R',f_dataT,'T');
ind = find(timeaxis>=xrange(1)&timeaxis<=xrange(2));
peakazi = find_peak_azi(f_dataR(ind),f_dataT(ind),23)

[recf_taxis recf] = recf_cal(timeaxis,dataZ,dataR,[490 550],[0.1 2],0.05,5);
plot_multi_waveform(81,[-10 20;NaN NaN],recf_taxis,recf,'RECF');
