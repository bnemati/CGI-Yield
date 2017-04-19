function output = runningFrequency(time, data, nsub)
%  
%  output = averagedown(data, nsub )
%  output = averagedown(data, nsub, time )
%  output = averagedown(data, nsub, time, flag_start)
%
%  Average down the input 'data' according to the binning parameter 'nsub'  
%  
%  If a 'time' array is supplied, it will also be averaged down in the 
%  same way as 'data'.
%
%  'output' is an array for 2 input arguments, and a struct otherwise. 
% 
%  flag_start: if supplied, and set to 1, then  adjust the first row by 
%  half of the difference between its first two entries. This is in case 
%  the first row is a time index which represents the start of a time bin 
%  rather than the middle, or rather than an instantaneous sample time. 
%
%  Bijan Nemati - 07-Sep-2009


[nrd, ncd] = size(data);
if (ncd == 1)
    data = data';
end

Npts = floor(length(data)/nsub); % The number of freq pts we will get
Nuse = nsub*Npts; % how many elements of the data will be used

[nrt, nct] = size(time);
if ( nrt ~= nrd || nct ~= ncd )
    error ('time vector has different dimensions than data') ;
end
if (nct == 1)
    time = time';
end
Dt = time(2) - time(1);

% Frequency Array for each segment
n = -nsub/2:1:nsub/2;
n = n(1:end-1);
fSeg = n / ( nsub * 2 * Dt );
% posFreq = n(nsub

nPeakRange = 4; % no of elements on each side of peak used to locate mean

fmean=zeros(1, Npts);
for iseg = 1:Npts
    firstIndex = (iseg-1)*nsub+1;
    segment = data(firstIndex:firstIndex+nsub-1);
    fftSeg = fft(segment);
    fSegu = fSeg(nsub/2+1:end);
    fftSu = abs(fftSeg(nsub/2+1:end));
    
    peak = findpeak(fSegu, fftSu, nPeakRange);
    
    fmean(iseg) = peak.mean;
    
    figure;plot(time(firstIndex:firstIndex+nsub-1),segment,'r.-');grid
    figure;plot(fSegu, abs(fftSu),'.-');grid
    title(['segment ',num2str(iseg), '  peak = ', num2str(peak.mean)]);
%     keyboard
end

output.fmean = fmean;

timeAvg = mean(reshape(time(1:Nuse),nsub,Npts)) ;

% if nargin > 3 && flag_start == 1
%     timeAvg = timeAvg + 0.5*(time(2)-time(1));
% end
output.time = timeAvg ;
figure
plot(output.time, output.fmean,'mo-'); grid
return

function peak = findpeak(f,F,nr)    
    N = length(f);
    ind = find(F==max(F));
    range = (max(ind-nr,1):min(ind+nr:N));
    peak.mean = sum(f(range).*F(range))/sum(F(range));
    peak.index = ind;
return



