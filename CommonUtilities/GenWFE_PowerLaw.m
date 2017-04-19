function WFE = GenWFE_PowerLaw ( Pupil,  powerlaw, SDev  )
%  WFE = GenWFE_PowerLaw ( Pupil,  powerlaw )
%  WFE = GenWFE_PowerLaw ( Pupil,  powerlaw, SDev  )
%
%  Generate a wavefront error across input pupil according to a power law
%  spatial frequency spectrum. The power law is applied to the PSD.
%
%  If called with 2 arguments, the output is normalized to unity peak to
%  peak, with zero mean. 
%  If called with 3 argument, the output will have a standard deviation
%  over the Pupil of SDev. Mean will still be zero. 
%   Inputs:
%       Pupil : The pupil with no padding. Its dimension sets scale for Zernike disc.
%       powerlaw: The power law to be applied to the power (amplitude^2).
%       SDev (optional) : Specified standard deviation of the output over
%       the pupil. 
%
% B. Nemati, JPL, 13-Jan-2010

N0 = length(Pupil);
if mod(N0,2) == 0
    N1 = N0;
    isodd = 0;
else
    N1 = N0+1;
    isodd = 1;
end

range = (2/(N1-1)) * ((1:N1) - ((N1+1)/2));
[ x, y] = meshgrid(range);
[th,ro] = cart2pol(x,y);

OPSDAmp = ro.^(powerlaw/2);
OPSDPhs = 2*pi * rand(N1);

C = OPSDAmp .* exp(i*OPSDPhs);
CFT = fftshift(fft2(ifftshift(C)));
modelPhase = real(CFT);

if isodd
    modelPhase = modelPhase(1:N0,1:N0)
end
insidePupil = find(Pupil);
modelPhase = modelPhase - mean(modelPhase(insidePupil));
modelPhase = modelPhase / (max(max(modelPhase(insidePupil)))-min(min(modelPhase(insidePupil))));

if nargin == 3
    std_asis = std(modelPhase(Pupil==1));
    modelPhase = modelPhase * SDev/std_asis;
end

WFE = Pupil .* modelPhase;

return


