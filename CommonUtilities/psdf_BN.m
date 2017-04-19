function [f,P] = psdf (t,h)
%    [f,P] = psdf (t,h)
% P is the one-sided PSD corresponding to the real, time domain data h.
% f is the associated frequency array
% The normalization is such that (f(2)-f(1))* sum(P) gives the mean squared
% power. 
%
%
% B. Nemati  (08-Mar-2000) comments updated 13-Feb-2013

if (sum(size(t)-size(h))~=0)
   error('psdf-F- input dimensions do not agree.');
end
if (min(size(t))~=1) 
   error('psdf-F- inputs must be vectors');
end
[i j]=size(t);
rowvec=1;
if (j==1)
   rowvec=0;
   h=h';
   t=t';
end
   
N=length(h);
if ( length(t)~=N)
   error(' The ordinate array t must be same length as function array h!');
end
if (rem(N,2)~=0)
   disp('psdf-W- Odd array length: truncating last element to make even');
   h=h(1:N-1);
   t=t(1:N-1);
	N=N-1;   
end

% Sampling time sets the frequency scale: Nyquist freq = 1/(2*T)
T=t(2)-t(1) ;

H=fft(h);

H=[(1/sqrt(2))*H(1), H(2:N/2), (1/sqrt(2))*H(N/2+1)];

P = 2*(H.*conj(H));

% Make an array of half the length and scale by bandwidth 

f = (1/T) * (0:1/N:1/2);   % 13-Feb-2013 factored out 1/T
P = P/((N^2)*(f(2)-f(1)));


if (rowvec==0)
   f=f';
   P=P';
end


return
% The FFT places the coefficients for the different frequencies in 
% the following pattern:
%   1       zero freq (DC)
%  2:N/2    pos. freqs (ascending freq)
%  N/2+1    both + and - Nyquist freq (coeffs. are equal)
%  N/2+2:N  neg. freqs. (ascending freq)
% The one-sided PSD will have  N/2+1 terms 
%
%-----------------------------------------------------------------------
% The following is a little script that tests this function against 
% Parseval's theorem
%
% close all 
% clear 
% clc
% newfigure(3,4);
% ip=0;
% 
% N = 16
% t = 10*(0:N-1)/N;
% h = cumsum(randn(1,N));
% h = cumsum(h);
% % h = h - mean(h);
% 
% ip=ip+1;newfigure(ip);
% plot(t,h);
% grid;
% 
% [f,P] = psdf(t,h);
% 
% ip=ip+1;newfigure(ip);
% loglog(f,P)
% grid
% 
% df = f(2)-f(1)
% dt = t(2)-t(1)
% 
% MeanSquaredPower_timeDomain = sum(h.^2) / N
%  
% MeanSquaredPower_FreqDomain =  df* sum(P)
% 
% MeanSquaredPower_FreqDomain / MeanSquaredPower_timeDomain
