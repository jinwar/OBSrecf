function peakazi = find_peak_azi(data1,data2,isfigure)
%% function to find the direction with maximum amplitude 
%  data2 has to be in the direction of data1 with 90 degree rotation clockwise
%  written by Ge Jin, jinwar@gmail.com, 10/2013

N = length(data1);
for theta = 1:180
	dataR = data1*cosd(theta) + data2*sind(theta);
	rmsR(theta) = sqrt(sum(dataR.^2)./N);
end

[peakamp peakazi] = max(rmsR);
dataR = data1*cosd(peakazi) + data2*sind(peakazi);

if isfigure
	figure(isfigure)
	clf
	plot(rmsR)
	plot_multi_waveform(isfigure+1,[],[1:N],data1,'1',data2,'2',dataR,'maxamp comp');
end

