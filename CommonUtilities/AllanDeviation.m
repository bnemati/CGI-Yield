function [Nsub, AllanDev] = AllanDeviation ( DataArray, minNgroups)
%  [Nsub, AllanDev] = AllanDeviation ( DataArray, minNgroups)
%
%  Compute the Allan Deviation of the DataArray, with minimum group size
%  minNgroups, each group yields an average. Diff of consecutive groups is
%  what the Allan Deviation is about:
%
%   d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 ...  dM
%   <-- mu1 --> <-- mu2 --><-- ... muN -->  
%   <------  Delta 1  ---->
%               <------- Delta 2 -------->            
%   <-----------  std dev   ------------->
% 
% B. Nemati - 12-Sep-2012

Ntotal = length(DataArray);

MaxAveraged = floor(Ntotal/(minNgroups+1));

AllanDev(1) = std(diff(DataArray))/sqrt(2);


for N_Averaged = 2 : MaxAveraged

    Ngroups = floor(Ntotal/N_Averaged);
    DataMatrix = reshape(DataArray(1:N_Averaged*Ngroups), N_Averaged, Ngroups);
    DataSubAverages = mean(DataMatrix);
    
    AllanDev(N_Averaged) = std(diff(DataSubAverages))/sqrt(2);
end

Nsub = (1:MaxAveraged) ;

return

