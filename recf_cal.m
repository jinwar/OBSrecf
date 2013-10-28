function [recf_taxis recf] = recf_cal(timeaxis,dataZ,dataR,cut_win,gauss_para,waterlevel,timeshift)
%% function to use deconvolution method to calculate receiver function waveforms
%  Written by Ge Jin, jinwar@gmail.com, 2013-10-26

isfigure = 0;

if ~exist('cut_win','var')
	cut_win = [timeaxis(1) timeaxis(end)];
end
if ~exist('gauss_para','var')
	gauss_para = 1;
end
if ~exist('waterlevel','var')
	waterlevel = 0.05;
end
if ~exist('timeshift','var')
	timeshift = 5;
end

delta = timeaxis(2)-timeaxis(1);

% window the data
ind = find(timeaxis >= cut_win(1) & timeaxis <= cut_win(2));
win_Z = dataZ(ind);
win_R = dataR(ind);

% detrend and taper
win_Z = detrend(win_Z);
win_Z = taper(win_Z,5);
win_R = detrend(win_R);
win_R = taper(win_R,5);

recf_taxis = timeaxis(ind);
recf_taxis = recf_taxis - recf_taxis(1) - timeshift;

T = recf_taxis(end) - recf_taxis(1) + delta;
N = length(recf_taxis);
fN = 1/2/delta;
%[b,a] = butter(2,[bp_filter(1)/fN, bp_filter(2)/fN]);
if mod(N,2)
	faxis = [0:(N-1)/2,-(N-1)/2:-1]*(1/T);
else
	faxis = [0:N/2,-N/2+1:-1]*(1/T);
end
waxis = faxis*2*pi;

fft_Z = fft(win_Z);
fft_R = fft(win_R);

% apply water level
maxamp = max(abs(fft_Z));
ind = find(abs(fft_Z)<maxamp*waterlevel);
fft_Z(ind) = fft_Z(ind)./abs(fft_Z(ind)).*maxamp*waterlevel;

% Deconvoluation
fft_recf = fft_R./fft_Z;
% filter and timeshift
i = sqrt(-1);
fft_recf = fft_recf.*exp(-waxis(:).^2/4/gauss_para^2);
fft_recf = fft_recf.*exp(-i.*waxis(:).*timeshift);
recf = real(ifft(fft_recf));

if isfigure
	figure(69)
	clf
	subplot(3,1,1)
	ind = find(timeaxis >= cut_win(1) & timeaxis <= cut_win(2));
	plot(timeaxis(ind),win_Z);
	title('Z');
	subplot(3,1,2)
	plot(timeaxis(ind),win_R);
	title('R');
	subplot(3,1,3)
	plot(recf_taxis,recf);
	title('RECF');
end
