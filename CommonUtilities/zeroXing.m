function [ indx_up, indx_dn] = zeroXing( y )
%find zero crossings

n = length(y);

t1=y(1:n-1);
t2=y(2:n);
tt=t1.*t2;

dt        = t2-t1;
indx_up   = find( (tt<0) & (dt>0) ) ;
indx_dn   = find( (tt<0) & (dt<0) ) ;

end

