% calculate fwhm of 1d  signal in linear or db unit
% of highest peak
%
% Hanying Zhou, modified 10/31/2013



function [width] = fwhm_1d(f,isdB)

if nargin <2 isdB =0;end

upN =4;
f = interp(f,upN,4,0.25);

[tmp f_pk_loc] = max(f);

if ~isdB
    f= f-0.5*max(f);
else
    f =f+3; % -3dB
end
%figure(888), clf,plot(f), grid on

[ind_up, ind_dn] = zeroXing(f);
[tmp idxp] = min(abs(ind_up-f_pk_loc));  % indx closest to the highest peak
[tmp idxn] = min(abs(ind_dn-f_pk_loc));

width= (ind_dn(idxn)-ind_up(idxp))/upN;

%[pk pk_loc]=max(f),


return
