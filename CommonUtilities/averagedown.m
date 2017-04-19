function output = averagedown(data, nsub, time, flag_start)
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

if nargin < 2

    error('Need at least 2 arguments!');

end

[nrd, ncd] = size(data);
if (ncd == 1)
    data = data';
end

Npts = floor(length(data)/nsub); % The number of averages we will get
Nuse = nsub*Npts; % how many elements of the data will be used

if nargin == 2
    
    output = mean(reshape(data(1:Nuse),nsub,Npts)) ;
    if (ncd == 1) 
        output = output';
    end
    
else
    [nrt, nct] = size(time);
    if ( nrt ~= nrd || nct ~= ncd )
        error ('time vector has different dimensions than data') ;
    end
    if (nct == 1)
        time = time';
    end
    output.data = mean(reshape(data(1:Nuse),nsub,Npts)) ;
    timeAvg = mean(reshape(time(1:Nuse),nsub,Npts)) ;
    
    if nargin > 3 && flag_start == 1
        timeAvg = timeAvg + 0.5*(time(2)-time(1));
    end
    output.time = timeAvg ;

end

return
