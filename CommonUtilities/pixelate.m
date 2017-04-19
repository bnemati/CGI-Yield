function y = pixelate(M, action, nrsub, ncsub)
%
%  y = pixelate(M, nsub, action)
%  
%  Sub-average or sub-total the input matrix M in (nsub x nsub) blocks,
%  depending on whether action = 'average' or 'sum'.
%
%  M must be a square matrix with no. of rows an integer multiple of nsub.
%
%  B. Nemati 25-Jan-2007 - 
%  B. Nemati updated 24-Dec-2015 for non square situations

if nargin < 4
    ncsub = nrsub;
end

[nr, nc] = size(M);
if ( mod(nr,nrsub) ~= 0)
    error('pixelate error: row pixelation factor must be a divisor of the input matrix dimension');
end
if ( mod(nc,ncsub) ~= 0)
    error('pixelate error: column pixelation factor must be a divisor of the input matrix dimension');
end
    
h = ones(nrsub,ncsub);

if strcmp(action, 'average')
    normalization = 1/sum(sum(h));
elseif strcmp(action, 'sum' )
    normalization = 1;
else
    error('pixelate error: <action> must be either ''sum'' or ''average''');
end

temp = filter2(h, M, 'valid') * normalization;
y = temp(1:nrsub:end, 1:ncsub:end);

return 