function mag = mag_at_lambda(Vmag, specType, lambda)
% return the magnitude at the specified lambda, for given star spectral type & Vmag
%  mag =mag_at_lambda([candInfo.Vmag]',{candInfo.StarSpec}',0.75e-6)
%
% inputs:
%   specType = cell array containing star's spectral type (e.g.,'K2V','F7V')
%   lambda   = desired astronomical spectral lambda; in SI unit
%

debug = false;  %  true; %

type_str = ['O', 'B',  'A', 'F', 'G', 'K', 'M'];

% calibration colors from http://en.wikipedia.org/wiki/Color_index:

%  lambda    'O'       'B'       'A'         'F'         'G'         'K'     'M'
mmag = [...
    0.44,	-1.19, 	  -1.08,    -0.02,      0.03,       0.06,       0.45,   1.22;       %U-B
    0.55,	-0.33,    -0.30,    -0.02,      0.30,       0.58,       0.81,   1.40;       %B-V
    0.70,	-0.15,    -0.13,     0.02,      0.30,       0.50,       0.64,   1.28;       %V-R
    0.90,	-0.32,    -0.29,    -0.02,      0.17,       0.31,       0.42,   0.91;       %R-I
    1.05,	-0.32,    -0.29,    -0.02,      0.17,       0.31,       0.42,   0.91; ];    %I-Z


lamBase = mmag(:,1);

numStars = size(specType);
m2um = 1e6;
m2nm = 1e9;
lam = lambda*m2um;

if lam < min(lamBase) || lam > max(lamBase)
    error(['mag_at_lambda: input lambda = ',num2str(lambda),' is out of valid range']);
end

for index = 1:numStars                  % For each of the cells in StarsCells...
    
    Star = specType{index};              % get the specifications for the star
    StarType = Star(1);                  % extract the first character
    col = strfind(type_str,StarType)+1;
    StarSubtype = Star(2);               % and the following number
    if length(Star) >= 3
        if Star(3)=='.'
            StarSubtype = Star(2:end);
        end
    end
    
    dmag = interp1(lamBase, mmag(:,col), lam);
    
 
    if  lam  == 0.55 
        mag(index) = Vmag(index);
    elseif lam <  0.55    
        mag(index) =Vmag(index)- dmag;
    elseif lam <= 0.70  && lam > 0.55
        mag(index) =Vmag(index)- dmag;
    elseif lam <= 0.90  && lam > 0.70
        mag(index) =Vmag(index)- (mmag(3,col)+dmag);
    elseif lam <= 1.05 && lam > 0.90
        mag(index) =Vmag(index)- (mmag(3,col)+mmag(4,col)+dmag);
    end
    %ApparentMagnitude(index) = Magnitude(index) - MagCorrection;
    if debug
        dmag,  mmag(:,col)
        formatSpec = 'Star type=%s; StarSubtype=%5s; Vmag=%5.2f; mag@%3.0fnm = %4.2f\n' ;
        fprintf(formatSpec,StarType,StarSubtype,Vmag(index),lambda*m2nm, mag(index));
        pause
    end
end

