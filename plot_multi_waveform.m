function plot_multi_waveform(fignum,axis_range,timeaxis,varargin)
	if nargin < 3
		disp(['Usage: plot_multi_waveform(fignum,axis_range, timeaxis, data1, name1, data2, name2 ....)']);
		return
	end
	N = length(varargin)/2;
	figure(fignum)
	clf
	hold on
	for i=1:N
		subplot(N,1,i)
		plot(timeaxis,(varargin{2*i-1}),'k');
		title(char(varargin{2*i}));
		if ~isempty(axis_range)
			xrange = axis_range(1,:);
			yrange = axis_range(2,:);
			if ~isnan(sum(xrange))
				xlim(xrange);
			end
			if ~isnan(sum(yrange))
				ylim(yrange);
			end
		end
	end
end
