function y = nPeaks(M_in, n, m)
% find the n highest peaks, assuming that the no other peak exists within 
% m pixels of each found peak 
% B. Nemati, 15-May-2012

[nr,nc] = size(M_in);

M = M_in;
minM = min(min(M));

for ip = 1:n

    maxM = max(max(M));
    [ir, ic] = find(M == maxM, 1, 'first');
    M(max(ir-m,1):min(ir+m,nr),max(ic-m,1):min(ic+m,nc)) = minM;
    peak(ip).value = maxM;
    peak(ip).row = ir;
    peak(ip).col = ic;
    
    
end

y = peak;

return
