function y = mresample(M, nr, nc, interp_option)
%
% B. Nemati 25-Jan-2007

if (nargin < 4)
    interp_option = 'spline';
end


[mr, mc] = size(M);

if ( (mr/mc) ~= (nr/nc) )
    error('mresample error: the ration of rows to columns requested must match those in the input matrix');
end

deltax = 2/mc;
deltay = 2/mr;

xlo = -1;
xhi = +1;

ylo = -1;
yhi = +1;

% assume each element of the input matrix corresponds to the value at the center
% of the pixel associated with that element 
[x, y] = meshgrid(xlo+deltax/2:deltax:xhi-deltax/2, ylo+deltay/2:deltay:yhi-deltay/2) ;

deltax2 = 2/nc;
deltay2 = 2/nr;
[x2, y2] = meshgrid(xlo+deltax2/2:deltax2:xhi-deltax2/2, ylo+deltay2/2:deltay2:yhi-deltay2/2) ;

y =interp2(x,y,M,x2,y2, interp_option);
% disp(['        mresample called interp2 with option ', interp_option])
return

