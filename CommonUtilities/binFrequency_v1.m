function output = binFrequency(time, data, nsub, nPeakRange)
%      output = binFrequency(time, data, nsub, nPeakRange)
%
%  Bin the input time and data arrays into segments of length nsub
%  for each bin, find the mean frequency by taking the fft, locationg the
%  peak in abs(FFT), and getting the weighted mean of a range of elements
%  within +/- nPeakRange of the peak
%  
%  Bijan Nemati - JPL - 29-Mar-2013


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
fSeg = n / ( nsub * Dt );

fmean=zeros(1, Npts);
for iseg = 1:Npts
    firstIndex = (iseg-1)*nsub+1;
    segment = data(firstIndex:firstIndex+nsub-1);
    fftSeg = fftshift(fft(detrend(segment)));
    fSegu = fSeg(nsub/2+1:end);
    fftSu = abs(fftSeg(nsub/2+1:end));
   
    peak = findpeak(fSegu, fftSu, nPeakRange);
    
    fmean(iseg) = peak.mean;
    
%     figure;plot(time(firstIndex:firstIndex+nsub-1),segment,'r.-');grid
%     
%     figure;plot(fSegu, abs(fftSu),'.-');grid
%     title(['segment ',num2str(iseg), '  peak = ', num2str(peak.mean)]);
%     keyboard
end
timeAvg = mean(reshape(time(1:Nuse),nsub,Npts)) ;

output.fmean = fmean;
output.time = timeAvg ;
% figure
% plot(output.time, output.fmean,'mo-'); grid
return

function peak = findpeak(f,F,nr)    
    N = length(f);
    ind = find(F==max(F));
    range = (max(ind-nr,1):min(ind+nr:N));
    peak.mean = sum(f(range).*F(range))/sum(F(range));
    peak.index = ind;
%     keyboard
return



