function output = TRTchops( data, tsample, t_target, t_reference, t_slew)
%   output = TRTchops( data, tsample, t_target, t_reference, t_slew)
%
% Form chop differences out of a data vector
% Assume the sequence:   Target - Slew - Reference - Slew - Target 
% Assume Target looks are shared between adjacent chops       
%
% tsample     = sample/integration time per data point
% t_target    = duration of target look
% t_reference = duration of reference look
% t_slew      = duration of slew between a target and a refernce 
%
% B. Nemati - 07-Sep-2009

if ( mod(t_target,tsample)~=0 || mod(t_reference,tsample)~=0 || mod(t_slew,tsample)~=0  ) 
    error('Target, reference and slew durations must all be multiples of tsample');
end

N_ptsChopUnique = round((t_target +t_slew +t_reference +t_slew)/tsample);


% the number of chops we can form from the data
Nchops = fix(length(data) / N_ptsChopUnique ) -1;
chop = zeros(1, Nchops);

for ichop = 1 : Nchops
    index = (ichop-1) * N_ptsChopUnique ;
            
    Target_before  = mean(data(index+ 1                                                 : index+                          round(t_target/tsample)));
    Reference      = mean(data(index+ 1+               round((t_target+t_slew)/tsample) : index+     round((t_target+t_slew+t_reference)/tsample)));
    Target_after   = mean(data(index+ 1+ round((t_target+2*t_slew+t_reference)/tsample) : index+ round((2*t_target+2*t_slew+t_reference)/tsample)));
    chop(ichop) = Reference - .5 * (Target_before + Target_after) ;
end

% Create a time tag array for the chop difference array, centered on the
% middles of the reference looks
time = (1:Nchops) * (t_target+t_slew+t_reference+t_slew) - (t_slew+.5*t_reference) ;
 
output.chop = chop ;
output.time = time ; 
output.perchopIntegTime = t_target+t_reference ;

return
