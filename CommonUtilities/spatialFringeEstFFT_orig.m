function [kx,ky,phi,amp,Idc] = spatialFringeEstFFT(I)
%
% This function estimates the wave number, phase and amplitude
% of spatial fringe using FFT.
%
% Input:
%
%   I	-- fringe intensity, dimension: Nx X Ny
%
% Output:
%   kx	-- spatial frequency, x component in unit (wave/pixel);
%   ky	-- spatial frequency, y component in unit (wave/pixel);
%   phi	-- fringe phase at center of the the grid
%   amp	-- fringe signal amplitude
%   Idc -- fringe signal DC intensity
%
% History:
%
%   10/01/2010      -- initial version, Chengxing Zhai
%

[Nx, Ny] = size(I);
nSubsample = 8;
Nx_fft = nSubsample*Nx;
Ny_fft = nSubsample*Ny;

Idc = mean(mean(I));

yFFT = fft2(I - Idc , Nx_fft, Ny_fft);
[mV, mIdx] = max(reshape(abs(yFFT(1:Nx_fft, 1:(Ny_fft/2))), [],1));
kx = mod(mIdx-1,Nx_fft);
ky = floor((mIdx-1)/Nx_fft);
phi = angle(yFFT(mIdx));
amp = abs(yFFT(mIdx))/Nx/Ny;

if kx > Nx_fft/2
  kx = kx - Nx_fft;
end

kx = kx/Nx_fft; % normalization to (wave/pixel)
ky = ky/Ny_fft; % normalization to (wave/pixel)
