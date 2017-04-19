function y = MFT(pupilField, bandWidth, NpixOut)
%    image = MFT(PupilField, bandWidth, NpixOut)
%
% Matrix Fourier Transform, after the algorithm of Soummer et al. 
% See:
% Soummer et al., 'Fast Computation of Lyot Style Coronagraph Propagation', (2007) 
% astro-ph,  arXiv:0711.0368
%
% Inputs:
%   PupilField: 
%   Input electric field (without padding) within an N x N array (N even)
%   such that the center of the aperture is at row = col = N/2 + 1
%    - For a simple 'top hat' this means circle of diameter N-1 pixels 
%        centered on (N/2 + 1, N/2 + 1)
%
%   bandWidth:
%   Desired scaling of the output in units of lambda/D
%   
%   Npix:
%   Desired width of the output in pixels (ie: Npu for pupil plane
%   after reverse MFT (iMFT))
%
% B. Nemati 06-Nov-2007

NA = length(pupilField);
U = (( ( 0:(NpixOut-1) ) - NpixOut/2 ) * bandWidth / NpixOut)';
V = U;

X = (( ( 0:(NA-1) ) - NA/2 ) / NA)' ;
Y = X; 

M1 = exp(i*2*pi*U*X');

M2 = exp(i*2*pi*Y*V');

y = ( bandWidth / (NA*NpixOut) ) * M1 * pupilField * M2;
return

