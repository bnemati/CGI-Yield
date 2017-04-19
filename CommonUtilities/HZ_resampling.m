function [ V_rsmpl, seg_tt] = resampling_isal(time, dfdt,  V, fc, delay, rmvPnt)

%  input:
%   time:  time 
%   dfdt:  chirp rate from freq monitor
%   V:     recever or freq monitor siginal to be resampled
%   fc:    carrier frequency
%   delay: delay
%   rmvPnt: # of data points to be excluded in resampling, +/1 from zero-crossing point of chirp rate (or freq peak/Valley)
%
%  output: 
%   V_rsmpl: resampled signal
%   seg_tt:  time index for each segment/ramp
% 
%  Hanying Zhou,  2013/10/10

if nargin < 6, rmvPnt =0; end

%[indx_tdf_up, indx_tdf_dn] = zeroXing(dfdt);
%z_loc       = sortrows([indx_tdf_up indx_tdf_dn]')', length(z_loc)

t_int       = time(2)-time(1);
z_num       = round(time(end)/0.1);               %  +/-1, chirp cycle ~0.2s, 
disp(['   ===> Check if # of zeroCrossing of chirp rate = ' num2str(z_num) '?']),  pause(5)  
z           = nZeros(dfdt, z_num, 0.01/t_int);   %dfdt 0-xing; 
z_loc       = sortrows([ z.col ]')';
dz_loc      = diff( z_loc);

cycle       = round(2*mean(dz_loc(1:end-1)));
dfdt_sq     = square(-2*pi/cycle*(-z_loc(1)+(1:length(time))))*1.e12; %
zsq_loc     = find(diff(dfdt_sq)~=0);           %dfdt_sq 0-xing

V_rsmpl     = zeros(1,length(time));
t_tru       = zeros(1,length(time));
t_err       = zeros(1,length(time));  
dfreq_err   = zeros(1,length(time)); 
seg_tt_len  = zsq_loc(2)-zsq_loc(1);
tstep       = t_int*0.1;

mag         = 1.e4;  % interpolation doesn't work well for small numbers- pump up by mag 

for i= 1:length(zsq_loc)-1 , i

    tt            = zsq_loc(i)+rmvPnt:zsq_loc(i+1)-rmvPnt;  % 
    dfdt_ideal(i) = sum(dfdt(tt))/(zsq_loc(i+1)-zsq_loc(i)-rmvPnt*2);

    dfreq_err(tt) = dfdt(tt)-dfdt_ideal(i);  
    
    for jj =1:1             % 1 - monitor signal; 2 - receiver signal

        %if jj ==1, delay =fm_dlay; fc =fHet_fmon; else delay = rcvr_dlay; fc =frcvr; end
        
        ferrt(tt)   = cumsum(dfreq_err(tt)*delay*t_int); 
        t_err(tt)   = ferrt(tt)./(fc+dfdt_ideal(i)*delay );     % timing error  
        t_tru(tt)   = time(tt)+t_err(tt);
  
        aa =find(t_tru(tt)<time(tt(1))); 
        bb =find(t_tru(tt)>time(tt(end)));   %bring timing w/n - or else causing discontinuity
        [length(aa) length(bb) max(t_tru(tt)-time(tt(end)))  min(t_tru(tt)-time(tt(1)))],  
        t_tru(aa+tt(1)-1) = time(tt(1));  
        t_tru(bb+tt(1)-1) = time(tt(end)); 

        idx = find(diff(t_tru(tt))<=0); length(idx);
        
        while ~isempty(idx),     %t_tru need to be strict monotonic for interp1  
              t_tru(idx+tt(1)) = t_tru(idx+tt(1))+ tstep; 
              idx    = find(diff(t_tru(tt))<=0);   %length(idx);
        end  
        %if jj==1 t_tru_fm(tt) = t_tru(tt); else t_tru_rcvr(tt) = t_tru(tt); end          
    end
    
   %Vfm_rsmpl(tt) = interp1(t_tru_fm(tt)*mag, Vfm(tt),time(tt)*mag,'linear');
   %V_rsmpl(tt)   = interp1(t_tru_rcvr(tt)*mag, Vrcvr(tt),time(tt)*mag,'linear'); 
   V_rsmpl(tt)   = interp1(t_tru(tt)*mag, V(tt),time(tt)*mag,'linear'); 

   seg_tt{i} = tt;  
   seg_tt_len = min(length(tt),seg_tt_len);
  
end

for kk=1:length(seg_tt) 
    aa =seg_tt{kk};
    seg_tt{kk}=aa(1:seg_tt_len); 
end

%Vfm_rsmpl(find(isnan(Vfm_rsmpl)==1))=0; 
V_rsmpl(find(isnan(V_rsmpl)==1))=0; 

end

