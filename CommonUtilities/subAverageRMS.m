function [subAvgRMS, IntegTime] = subAverageRMS ( DataArray, DataSampleTime )
%  [subAvgRMS, IntegTime] = subAvgRMS ( DataArray, DataSampleTime )
%  
% Starting from the input DataArray, for each of a specified number of
% integration times compute the rms of the ensemble of sub averaged data.
% Note that this not the Allan Deviation because 1. It is an rms and not a
% variance, and 2) It is differential (no division by sqrt(2)).
%
% Method:  Form groups of increasing numbers of chops to be averaged, then
% average them, and find the rms of the averages:
%
%   d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 ...  dM
%   <-- mu1 --> <-- mu2 --><-- ... muN -->    
%   <--------------- rms ---------------->
% 
% B. Nemati - 02-Oct-2009

Ntotal = length(DataArray);

MaxAveraged = floor(Ntotal/3);

subAvgRMS(1) = sqrt(mean(DataArray.^2));

for N_Averaged = 2 : MaxAveraged

    Ngroups = floor(Ntotal/N_Averaged);
    DataMatrix = reshape(DataArray(1:N_Averaged*Ngroups), N_Averaged, Ngroups);
    DataSubAverages = mean(DataMatrix);
    subAvgRMS(N_Averaged) = sqrt(mean(DataSubAverages.^2));
    
end

IntegTime = (1:MaxAveraged) * DataSampleTime ;

return

