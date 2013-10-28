function outdata = taper(indata,width)
%% function to apply taper at each side of the data
%  taper width is in percent in each side
%  written by Ge Jin, jinwar@gmail.com

if ~exist('width','var')
	width = 3;
end

N = length(indata);
taperwidth = round(N*width/100);
if taperwidth < 3
	taperwidth = 3;
end

hanning_win = hanning(2*taperwidth);

flat_hanning_win = ones(length(indata),1);

flat_hanning_win(1:taperwidth) = hanning_win(1:taperwidth);
flat_hanning_win(N-taperwidth+1:N) = hanning_win(taperwidth+1:end);

outdata = indata.*flat_hanning_win;

end
