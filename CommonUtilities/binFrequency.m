function output = binFrequency(time, data, nsub)
%      output = binFrequency(time, data, nsub)
%
%  Bin the input time and data arrays into segments of length nsub
%  for each bin, find the mean frequency by taking the fft, locationg the
%  peak in abs(FFT), and getting the weighted mean of a range of elements
%  within +/- nPeakRange of the peak
%  
%  Bijan Nemati - JPL - 29-Mar-2013

% ensure that we are working with a row vector
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

% Dimensionality of each segment that is fft'd :
% we want to ensure enough spectral resolution in the data
% we also want to ensure that the peak has at least 4 points
% spectral resolution is given by df = 1 / (N . dt)
% df_desired = 10e3; % Hz
% achieve this by zero-padding (to even number) if necessary 
% Npad = max(4*ceil(1/(df_desired*Dt)), 8*nsub);
Npad =  8*nsub;

% Frequency Array for each segment
n = -Npad/2:1:Npad/2;
n = n(1:end-1);
fSeg = n / ( Npad * Dt );

fmean=zeros(1, Npts);
for iseg = 1:Npts
    firstIndex = (iseg-1)*nsub+1;
    segment = data(firstIndex:firstIndex+nsub-1);
    seg_zpad_detr = pad(detrend(segment),1,Npad);
    fftSeg = fftshift(fft(seg_zpad_detr));
    fSegu = fSeg(Npad/2+1:end);
    fftSu = abs(fftSeg(Npad/2+1:end));
   
    fmean(iseg) = findpeak(fSegu, fftSu);
   
    
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

function peakf = findpeak(f,F)
% keybaord
range = find(F>=0.8*max(F));

% % Method 1  1.0
% peakf = sum(f(range).*F(range))/sum(F(range));


% Method 2   1.23X
fmid = mean(f(range));
fp = f(range)- fmid;
fp2 = fp.^2;
M = [fp2',fp',ones(length(range),1)];
P = pinv(M)*F(range)';
peakf = fmid - P(2)/(2*P(1));

% % Method 3   2.59X
% fmid = mean(f(range));
% p = polyfit(f(range)- fmid,F(range),2);
% peakf = fmid - p(2)/p(1)/2;

return



