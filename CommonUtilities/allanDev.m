function [sigma_vec, deltaT_vec] =  allanDev(y, dt, scaleFactor)

Ny = length(y);

N = floor(log(Ny/4)/log(scaleFactor));
nVec = floor(scaleFactor.^(0:N));

if nVec(end) < floor(Ny/4)
  nVec = [nVec, floor(Ny/4)];
end

nVec = [nVec, floor(Ny/3), floor(Ny/2)];

idx = find(diff(nVec));
nVec = [nVec(idx), nVec(idx(end)+1)];
deltaT_vec = nVec*dt;
sigma_vec = zeros(size(nVec));

for ii = 1:length(nVec)
  nSeg = floor(length(y)/nVec(ii));
  sigma_vec(ii) = sqrt(1/2*mean(diff(mean(reshape(y(1:(nSeg*nVec(ii))), nVec(ii), nSeg),1), [], 2).^2));
end

