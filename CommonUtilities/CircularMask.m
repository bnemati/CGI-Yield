function mask = CircularMask(Npix, Lside, Dmask, x0, y0, Dsec, ngray) 
%   mask = CircularMask(Npix, Lside, Dmask)
%   mask = CircularMask(Npix, Lside, Dmask, x0, y0)
%   mask = CircularMask(Npix, Lside, Dmask, x0, y0, Dsec)
%   mask = CircularMask(Npix, Lside, Dmask, x0, y0, Dsec, ngray)
%
% Generate a circularly symmetric mask a matrix that is Npix on a side
% The scale of the matrix is specified using Lside, which is the length 
% corresponding to Npix. 
% The outer diameter of the mask is specified using Dmask in length units. 
% Optional: x0, y0 specify offset from middle (defalut = (0,0)).
% Optional: Dsec specifies secondary hole diameter (default = 0).
% Optional: ngray specifies the number of gray levels allowed on the edges
%    ngray = 1 :  hard edges
%            n :  n^2 levels of gray allowed at the edges  (n=2:10 allowed)
%            
% B. Nemati JPL 16-Nov-2009

if nargin < 7
    ngray = 1;
else
    if ngray < 1 || ngray > 10
        error('ngray allowed range = 1:10');
    end
    ngray = round(ngray);
end

N = Npix * ngray ; 

delta = 2/N;

if nargin <  4, x0= 0; y0 = 0; end;

% assume each element of the input matrix corresponds to the value at the 
% center of the pixel associated with that element 
[x, y] = meshgrid(  (Lside/2) * (-1+delta/2:delta:1-delta/2) ); 

r = sqrt((x-x0).^2 + (y-y0).^2);

binarymask = zeros(N);

if nargin < 6
    binarymask( r <= (Dmask/2) ) = 1;
else
    binarymask( r>= (Dsec/2) & r <= (Dmask/2) ) = 1;
end

if ngray == 1
    mask = binarymask;
else
    mask = pixelate( binarymask, ngray, 'average');
end

return

function y = pixelate(M, nsub, action)
%
%  y = pixelate(M, nsub, action)
%  
%  Sub-averages or sub-totals the input matrix M in (nsub x nsub) blocks,
%  depending on whether action = 'average' or 'sum'.
%
%  M must be a square matrix with no. of rows an integer multiple of nsub.
%
%  B. Nemati 25-Jan-2007

[nr, nc] = size(M);
if (nr ~= nc )
    error('pixelate error: input matrix must be square');
end
if ( mod(nr,nsub) ~= 0)
    error('pixelate error: pixelation factor must be a divisor of the input matrix dimension');
end
    
h = ones(nsub);

if strcmp(action, 'average')
    normalization = 1/sum(sum(h));
elseif strcmp(action, 'sum' )
    normalization = 1;
else
    error('pixelate error: <action> must be either ''sum'' or ''average''');
end

temp = filter2(h, M, 'valid') * normalization;
y = temp(1:nsub:end, 1:nsub:end);

return 