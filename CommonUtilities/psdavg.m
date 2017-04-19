function [f,P, H] = psdavg(n,t,h,ZpadN,win, sln,sll)
% psdavg(n,t,h) chop the input into n even pieces and get avg psd
% Psdavg_Oct08 
% B. Nemati  used this in ISAL starting 13-Feb-2013
% H. Zhou, add window and zero-pad options, Oct. 2013
% ZpadN:    factor of zero padding 
% win:      0 - no window
%           1 - taylor
%           2 - Hamming
%           3 - Kaiser
%           4 - Chebychev
%

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


if nargin <4, ZpadN = 1;end
if nargin <5, win =0; sln =0;sll=0; end


% now average the time-domain data and change the time array
% accordingly

h_orig = h-mean(h);
t_orig = t;
len_orig = length(h_orig);
len_seg = floor(len_orig / n);

Pmat = []; 
for k = 1:n, 
    first_element = ((k-1)*len_seg) + 1;
    last_element = first_element + len_seg - 1;
    range = first_element : last_element ;
    t = t_orig(range);
    h = h_orig(range); 
    
    if win ==1, 
        h = h.*taylorwin(length(h),sln,sll)'; 
    elseif win==2, 
        %h = h.*window(@tukeywin,length(h),0.5)';
        h = h.*hamming(length(h))';
    elseif win == 3
        h = h.*kaiser(length(h),pi)';
    elseif win == 4
        h = h.*chebwin(length(h),60)';     
    end
    
    if ZpadN>1 
    t = repmat(t, 1, ZpadN);
    hh = zeros(1,ZpadN*length(h));
    hh(1:length(h))= h;
    h = hh;
    end

    %     [f,P]=psdf(t,detrend(h));
    [f,P, H]=psdf(t,h); 
    Pmat = [Pmat;P];
end

if n>1 P = mean(Pmat); end

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
