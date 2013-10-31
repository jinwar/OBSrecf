function plot_waveforms(fignum,datastr)
%% function to plot multi-waveforms in the same plot.
%  data should be column signed 

isglobalnorm = 0;
isfill = 1;
amp = 1;
xrange = [0 1000];
xrange = [-5 20];

if isglobalnorm
	maxamp = 0;
	for ie = 1:length(datastr)
		maxamp = max(max(datastr(ie).plot_data(:)),maxamp);
	end
	for ie = 1:length(datastr)
		datastr(ie).normdata = datastr(ie).plot_data(:)./maxamp;
	end
else
	for ie=1:length(datastr)
		maxamp = max(datastr(ie).plot_data(:));
		datastr(ie).normdata = datastr(ie).plot_data(:)./maxamp;
	end
end

figure(fignum)
clf
hold on;
for ie=1:length(datastr)
	plot(datastr(ie).plot_taxis(:),datastr(ie).normdata(:)*amp + ie,'k');
	if isfill
		temp = datastr(ie).normdata(:);
		temp(find(temp<0)) = 0;
		area(datastr(ie).plot_taxis(:),temp*amp + ie,ie,'facecolor','k');
	end
	if isfield(datastr,'marker') && ~isempty(datastr(ie).marker);
		plot(datastr(ie).marker.*[1,1],[-0.5 0.5]*amp + ie,'r','linewidth',1);
	end
end
ylim([0 length(datastr)+1]);
plot([0 0],[0 length(datastr)+1],'r','linewidth',2);
if ~isempty(xrange)
	xlim(xrange);
end
