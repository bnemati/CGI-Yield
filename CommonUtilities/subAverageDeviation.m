function [Nsub, subAvgDev] = subAverageDeviation ( DataArray, DevOption, Ngmin)
%  [Nsub, subAvgDev ] = subAverageDeviation ( DataArray, DevOption )
%  
% Starting from the input DataArray, for successively increasing sets of 
% data, compute either the rms (DevOption=0) or the standard 
% deviation (DevOption=1) of the ensemble of sub averaged data. The maximum
% integration time is chosen to allow three samples. 
% To get the Allan Deviation, chose DevOption=2 and divide by sqrt(2)).
%
% Method:  Form groups of increasing numbers of data to be averaged, then
% average them, and find the rms of the averages:
%
%   d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 ...  dM
%   <-- mu1 --> <-- mu2 --><-- ... muN -->    
%   <----------- rms or std ------------->
% 
% B. Nemati - 21-Dec-2009

Ntotal = length(DataArray);

if nargin == 2
    MaxAveraged = floor(Ntotal/3);
else
    MaxAveraged = floor(Ntotal/Ngmin);
end

if DevOption == 0 
    doRMS = true;
else
    doRMS = false;
end

if doRMS
    subAvgDev(1) = sqrt(mean(DataArray.^2));
else
    subAvgDev(1) = std(DataArray);
end

for N_Averaged = 2 : MaxAveraged

    Ngroups = floor(Ntotal/N_Averaged);
    DataMatrix = reshape(DataArray(1:N_Averaged*Ngroups), N_Averaged, Ngroups);
    DataSubAverages = mean(DataMatrix);
    
    if doRMS
        subAvgDev(N_Averaged) = sqrt(mean(DataSubAverages.^2));
    else
        subAvgDev(N_Averaged) = std(DataSubAverages);
    end
end

Nsub = (1:MaxAveraged) ;

return

