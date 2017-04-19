function [f,P] = psdavg(n,t,h)
% psdavg(n,t,h) chop the input into n even pieces and get avg psd
% Psdavg_Oct08 
% B. Nemati  used this in ISAL starting 13-Feb-2013


if (sum(size(t)-size(h))~=0)
   error('psdavg-F- input dimensions do not agree.');
end
if (min(size(t))~=1) 
   error('psdavg-F- inputs must be vectors');
end
[~, j]=size(t);
rowvec=1;
if (j==1)
   rowvec=0;
   h=h';
   t=t';
end


% now average the time-domain data and change the time array
% accordingly

h_orig = h-mean(h);
t_orig = t;
len_orig = length(h_orig);
len_seg = floor(len_orig / n);

Pmat = [];
for k = 1:n
    first_element = ((k-1)*len_seg) + 1;
    last_element = first_element + len_seg - 1;
    range = first_element : last_element ;
    t = t_orig(range);
    h = h_orig(range);
    %     [f,P]=psdf(t,detrend(h));
    [f,P]=psdf(t,h);
    Pmat = [Pmat;P];
end

P = mean(Pmat);

if (rowvec==0)
   f=f';
   P=P';
end

return

disp('three');
disp('calling rebin for h');
h = (1./n)*rebin(n,h);
disp('calling rebin for t');
t = (1./n)*rebin(n,t);

[f,P]=psdf(t,h);
