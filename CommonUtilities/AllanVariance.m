function output = AllanVariance ( InputData, tsample, Npts) 
%
%    output = AllanVariance ( InputData, tsample, Npts) 
%
% Compute the Allan Variance of InputData as a function of the
% integration (or delay) time:
%
%        Allan Variance = 1/2 * < Delta_Y ^2 >
%
% Where Delta_Y's are first differences [ y(i+1) - y(i) ] of consecutive
% means of InputData over each of the Npts integration/delay time tried
% (Note: since there is no gap between consecutive intervals, integration
% time is equal to the delay)
%
% B. Nemati -- 01-Oct-2009

minInteg = tsample ;
maxInteg = tsample * floor(length(InputData)/4) ;

% produce N points spread uniformly in log space between min and max

tinteg = 10.^(log10(minInteg) + (0:1:(Npts-1))/(Npts-1) * (log10(maxInteg)-log10(minInteg)));

% target and reference looks shall be of equal size

for k = 1 : Npts 
    % Note that makechops in 'TR' mode starts each T and the beginning of previous R!
    FDarray(k) = first_differences( InputData, tsample, tinteg(k), tinteg(k), 0);
    % This is strictly the definition of Allan Variance
    avar(k) = mean(FDarray(k).fdiff .^2) / 2; 
    tint(k) = FDarray(k).IntegTime;  
end

output.AllanVariance  = avar;
output.integTime      = tint;
return


function output = first_differences( data, t_sample, t_target, t_reference, t_slew)
%   output = first_differences( data, t_sample, t_target, t_reference, t_slew)
%
% Form first differences out of a data vector
%
% t_sample     = sample/integration time per data point
% t_target    = duration of target look
% t_reference = duration of reference look
% t_slew      = duration of slew between a target and a refernce 
%
% B. Nemati - 02-Oct-2009

t_slew = t_sample * round(t_slew/t_sample);
t_target = t_sample * round(t_target/t_sample);
t_reference = t_sample * round(t_reference/t_sample);

N_uniquePointsPerDiff = round((t_target + t_slew )/t_sample);

% the number of chops we can form from the data
Ndiffs = floor((length(data) - t_reference/t_sample) / N_uniquePointsPerDiff );
fdiff = zeros(1, Ndiffs);

for ifd = 1 : Ndiffs
    index = (ifd-1) * N_uniquePointsPerDiff ;
    
    Target      = mean(data(index+ 1                                   : index+                       round(t_target/t_sample)));
    Reference   = mean(data(index+ 1+ round((t_target+t_slew)/t_sample) : index+ round((t_target+t_slew+t_reference)/t_sample)));
    fdiff(ifd) = Reference - Target ;
end

% Create a time tag array for the fdiff difference array, centered on the
% middles of the fdiffs
time = (1:Ndiffs)*(t_target+t_slew) + t_reference - 0.5*(t_target+t_slew+t_reference) ;

output.fdiff = fdiff ;
output.time = time ;
output.IntegTime = t_target+t_reference ;

return




