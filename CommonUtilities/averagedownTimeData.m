function output = averagedownTimeData( time, data, nsub)
% output = averagedownTimeData( time, data, nsub)
% average down by nsub both the time array and the data matrix
% data and time dimensions must be consistent
%
% B. Nemati   26-Jan-2010

[nrt, nct] = size(time);
[nrd, ncd] = size(data);

if (nrt == 1)
    tisrow = true;
    Nt = nct;
    if ncd ~= nct
        error('data time dimension mismatch')
    end
    Nd = nrd;
elseif (nct == 1 )
    tisrow = false;
    Nt = nrt;
    if nrd ~= nrt
        error('data time dimension mismatch')
    end
    Nd = ncd;
else
    error('time array must be a row or a col vector')
end

if ~tisrow
    time = time';
    data = data';
end

b = ones(1,nsub)/nsub;

Npts = floor(Nt/nsub); % The number of averages we will get
Nuse = nsub*Npts; % how many elements of the data will be used

dsub = zeros(Nd, Npts);
for ir = 1 : Nd
    
    y = filter(b,1,data(ir,:));
    dsub(ir, :) = y(mod(1:Nt,nsub)==0);
    
end

tsub = mean(reshape(time(1:Nuse),nsub,Npts)) ;

if ~tisrow
    output.time = tsub';
    output.data = dsub';
else
    output.time = tsub;
    output.data = dsub;
end


return