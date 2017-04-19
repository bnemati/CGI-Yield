function [krow,kcol,phi,amp,Idc] = spatialFringeEstFFT(I)
%
% This function estimates the wave number, phase and amplitude
% of spatial fringe using FFT.
%
% Input:
%
%   I	-- fringe intensity, dimension: Nrow X Ncol
%
% Output:
%   krow	-- spatial frequency, row component in unit (wave/pixel);
%   kcol	-- spatial frequency, col component in unit (wave/pixel);
%   phi	-- fringe phase at center of the the grid
%   amp	-- fringe signal amplitude
%   Idc -- fringe signal DC intensity
%
% History:
%
%   10/01/2010      -- initial version, Chengxing Zhai
%

[Nrow, Ncol] = size(I);
nSubsample = 8;
Nrow_fft = nSubsample*Nrow;
Ncol_fft = nSubsample*Ncol;

Idc = mean(mean(I));

yFFT = fft2(I - Idc , Nrow_fft, Ncol_fft);
[mV, mIdx] = max(reshape(abs(yFFT(1:Nrow_fft, 1:(Ncol_fft/2))), [],1));
krow = mod(mIdx-1,Nrow_fft);
kcol = floor((mIdx-1)/Nrow_fft);
phi = angle(yFFT(mIdx));
amp = abs(yFFT(mIdx))/Nrow/Ncol;

if krow > Nrow_fft/2
  krow = krow - Nrow_fft;
end

krow = krow/Nrow_fft; % normalization to (wave/pixel)
kcol = kcol/Ncol_fft; % normalization to (wave/pixel)
