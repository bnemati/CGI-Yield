function output = makechops( data, t_sample, t_target, t_reference, t_slew, choptype)
%   output = makechops( data, t_sample, t_target, t_reference, t_slew)
%
% Form chop differences out of a data vector
    
%
% t_sample     = sample/integration time per data point
% t_target    = duration of target look
% t_reference = duration of reference look
% t_slew      = duration of slew between a target and a refernce 
% choptype    = 'TR'  : Target - slew - Reference
%               'TRT' : Target - Slew - Reference - Slew - Target 
%  If 'TR', the start of each chop's reference look is used as the start
%  of the next chop's target look. If 'TRT', target looks are 
%  shared between adjacent chops   

%
% B. Nemati - 07-Sep-2009

% if ( rem(t_target+(2*eps),t_sample)~=0 || rem(t_reference+(2*eps),t_sample)~=0 || rem(t_slew+(2*eps),t_sample)~=0  ) 
%     error('Target, reference and slew durations must all be multiples of t_sample');
% end

t_slew = t_sample * round(t_slew/t_sample);
t_target = t_sample * round(t_target/t_sample);
t_reference = t_sample * round(t_reference/t_sample);


switch choptype
    case 'TRT'
        N_uniquePointsPerChop = round((t_target +t_slew +t_reference +t_slew)/t_sample);
        
        % the number of chops we can form from the data
        Nchops = floor((length(data) - t_target/t_sample) / N_uniquePointsPerChop );
        
        chop = zeros(1, Nchops);
        
        for ichop = 1 : Nchops
            index = (ichop-1) * N_uniquePointsPerChop ;
            
            Target_before  = mean(data(index+ 1                                                 : index+                           round(t_target/t_sample)));
            Reference      = mean(data(index+ 1+               round((t_target+t_slew)/t_sample) : index+     round((t_target+t_slew+t_reference)/t_sample)));
            Target_after   = mean(data(index+ 1+ round((t_target+2*t_slew+t_reference)/t_sample) : index+ round((2*t_target+2*t_slew+t_reference)/t_sample)));
            chop(ichop) = Reference - .5 * (Target_before + Target_after) ;
        end
        
        % Create a time tag array for the chop difference array, centered on the
        % middles of the reference looks
        time = (1:Nchops) * (t_target+t_slew+t_reference+t_slew) - (t_slew+.5*t_reference) ;
        
        output.chop = chop ;
        output.time = time ;
        output.perchopIntegTime = t_target+t_reference ;
    case 'TR'      
        N_uniquePointsPerChop = round((t_target + t_slew )/t_sample);
        
        % the number of chops we can form from the data
        Nchops = floor((length(data) - t_reference/t_sample) / N_uniquePointsPerChop );
        chop = zeros(1, Nchops);
        
        for ichop = 1 : Nchops
            index = (ichop-1) * N_uniquePointsPerChop ;
            
            Target      = mean(data(index+ 1                                   : index+                       round(t_target/t_sample)));
            Reference   = mean(data(index+ 1+ round((t_target+t_slew)/t_sample) : index+ round((t_target+t_slew+t_reference)/t_sample)));
            chop(ichop) = Reference - Target ;
        end
        
        % Create a time tag array for the chop difference array, centered on the
        % middles of the chops
        time = (1:Nchops)*(t_target+t_slew) + t_reference - 0.5*(t_target+t_slew+t_reference) ;
        
        output.chop = chop ;
        output.time = time ;
        output.perchopIntegTime = t_target+t_reference ;
    otherwise
        error(['choptype = ',choptype,' is not supported!']);
end


return
