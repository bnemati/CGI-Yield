% --------------------------------------------------------------------------
% [result] = image_shift (image, dx, dy)    - Shift image using FFT method
% --------------------------------------------------------------------------
%
%  Shift an image by the specified dx and dy offsets. These offsets may be 
%  non-integer as the shift is implemented by introducing a Fourier domain 
%  tilt term.
% 
%     NOTE: For the case where dx and dy are vectors, the result will
%           be a shift-and-add over the set of specified shifts. This is
%           useful for simulating jitter effects or motion blur.
%
% $Date: 2008-05-29 18:07:02 -0700 (Thu, 29 May 2008) $
% $Revision: 84 $
% --------------------------------------------------------------------------
% Joseph J. Green,  Jet Propulsion Laboratory
% --------------------------------------------------------------------------


function [result] = image_shift (image, dx, dy, c_flag)

     if nargin < 4
       c_flag = 0;
     end

     if (dx==0) & (dy==0)
       result = image;
       return;
     end

     if isempty(dx) | isempty(dy)
       result = image;
       return;
     end

     [m n] = size(image);

     N = length(dx);

     xc = floor(n/2)+1;
     yc = floor(m/2)+1;

     [X Y] = meshgrid (1:n,1:m);

     X = X - xc;
     Y = Y - yc;

     %I = fftshift(fft2(image));
     I = fft2(image);

     T = 0*I;

     for k=1:N
 
        px = -2*pi*(X)/n * dx(k);
        py = -2*pi*(Y)/m * dy(k);

        T = T + exp(i * (px + py));

     end

     %I = I .* T;
     I = I .* fftshift(T);

     %result = real(ifft2(fftshift(I)));
     if c_flag ==0
        result = real(ifft2(I));
     else
        result = ifft2(I);
     end

return

        
