function yy = plotmean (y, x, xlo, xhi, nbins)

binwidth = (xhi-xlo)/nbins;

for ibin = 1:nbins
    xl = xlo + (ibin-1)*binwidth;
    xh = xl  + binwidth;
    
    
    ind = find(x >= xl & x < xh ) ;
    
    theseys  = y(ind);
    theirmean = mean(theseys);
    
    y_upper = theseys(theseys>theirmean);
    y_lower = theseys(theseys<theirmean);
    
    U_errorMean(ibin) = sqrt(mean( (y_upper.^2)) / length(theseys)) ;       
    L_errorMean(ibin) = sqrt(mean( (y_lower.^2)) / length(theseys));  
    
    xout(ibin) = mean(x(ind)) ; 
    yout(ibin) = theirmean ;

    
end


errorbar(xout, yout, L_errorMean, U_errorMean);

yy=0;

return
