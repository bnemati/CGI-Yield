function output = allanVar ( chop, perchopIntegTime)
%  output = allanVar ( chop, perchopIntegTime)
% calculate allan variance of a chopped signal
% 
% B. Nemati - 07-Sep-2009


THIS FUNCTION IS OBSOLETE AND DOES NOT EXACTLY PRODUCE AN ALLAN VARIANCE


len_av = fix(length(chop)/2) ;

Allan_variance=zeros(1,len_av);
Allan_variance(1)=var(chop);

for nwin = 2:len_av;
    WinLength = fix(length(chop)/nwin);
    
    % Take the chops and create, columnwise, a matrix of chops nwin x WinL
    chopsMatrix = reshape(chop(1:nwin*WinLength),nwin,WinLength);

    ChopAverages = mean(chopsMatrix);
    
    Allan_variance(nwin) = var(ChopAverages);
end;

output.allanVar = Allan_variance ;
output.t_integ  = (1:len_av)*perchopIntegTime;


return

