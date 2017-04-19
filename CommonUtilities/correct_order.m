function pixel = correct_order(pixel)
% Corrects for the ATC pixel readout order error in the SCDU real-time 
% system
%
% Usage:
%   corrected_pixels = correct_order(pixels)
%
% Inputs:
%   pixels - the pixel counts after being read from a .mat file, with the
%            readout order error
%
% Outputs:
%   corrected_pixels - the pixel counts after having the readout order
%                      corrected
%
%
%   Date         rev.    Author    Desc
%    2008-10-21   1.0     taw       Initial release
%    2009-02-20   2.0     taw       Correct XY to match pdvShow

% All we need, current, is to do a fliplr on the left arm.  We have to do
% this using a flipdim because we want it done for each time step.

% Do a fliplr in the left arm
pixel(:, :, 2, :) = flipdim(pixel(:, :, 2, :), 2);
%pixel(:, :, 2, :) = flipdim(pixel(:, :, 2, :), 1);

% Apply the transposition
pixel = double(permute(pixel, [2 1 3 4]));
