function WFE = GenWFE_Zern ( varargin  )
%  WFE = GenWFE_Zern ( Pupil, Amplitude, nZernOrd )
%  WFE = GenWFE_Zern ( Pupil, Amplitude, ZernOrder, ZernFreq )
%
%  Generate a wavefront error across input pupil using Zernikes
%   Inputs:
%       Pupil : The pupil with no padding. Its dimension sets scale for Zernike disc.
%       Amplitude : peak to peak amplitude
%  If called with 3 arguments, will create a mixture of Zernikes up to order nZernOrd
%  If called with 4 arguments, will create the Zernike function (ZernOrder, ZernFreq)
% See comments at the end for definitions of Zernike ORder and Frequency
%
% B. Nemati, JPL, 21-Sep-2007

Pupil     = varargin{1} ;
Amplitude = varargin{2} ;
nD = length(Pupil);

if nargin == 3
    nZernOrd = varargin{3};

    % Zernike order and frequency
    Zord=0;
    for Zind=1:nZernOrd
        Zord=[Zord ones(1,Zind+1)*Zind];
    end

    Zfrq=0;
    for Zind=1:nZernOrd
        Zfrq=[Zfrq -Zind:2:Zind];
    end

    N_Zern = length(Zord);

    Zamp = 2*rand(1,N_Zern) - 1 ;
    err = zeros(nD);
    for iz = 2 : N_Zern
        ZernOrder = Zord(iz) ;
        ZernFreq  = Zfrq(iz) ;
        CZ = CircleZernike(nD, 1.0, ZernOrder, ZernFreq);
        err = err +  ( Zamp(iz) * CZ.Phase ) ;
    end

elseif nargin == 4
    ZernOrder = varargin{3};
    ZernFreq  = varargin{4};

    CZ = CircleZernike(nD, 1.0, ZernOrder, ZernFreq);
    err = CZ.Phase;

else
    error('should be called with either 3 or 4 arguments')
end

WFE = Amplitude * ( err /(max(max(err))-min(min(err))) );

% make the portion within the pupil to be zero mean

WFE = WFE .* Pupil;

WFEmean = 0 ;
if ~isempty(nonzeros(WFE))
    WFEmean = mean(nonzeros(WFE));
end
WFE = WFE - WFEmean;

WFE = WFE .* Pupil;

return
% ZernOrder, ZernFreq as defined in CircleZernike
% In the table below n = ZernOrder, and  m = ZernFreq
%
%       n    m    Zernike function           Normalization
%       --------------------------------------------------
%       0    0    1                                 1
%       1    1    r * cos(theta)                    2
%       1   -1    r * sin(theta)                    2
%       2   -2    r^2 * cos(2*theta)             sqrt(6)
%       2    0    (2*r^2 - 1)                    sqrt(3)
%       2    2    r^2 * sin(2*theta)             sqrt(6)
%       3   -3    r^3 * cos(3*theta)             sqrt(8)
%       3   -1    (3*r^3 - 2*r) * cos(theta)     sqrt(8)
%       3    1    (3*r^3 - 2*r) * sin(theta)     sqrt(8)
%       3    3    r^3 * sin(3*theta)             sqrt(8)
%       4   -4    r^4 * cos(4*theta)             sqrt(10)
%       4   -2    (4*r^4 - 3*r^2) * cos(2*theta) sqrt(10)
%       4    0    6*r^4 - 6*r^2 + 1              sqrt(5)
%       4    2    (4*r^4 - 3*r^2) * cos(2*theta) sqrt(10)
%       4    4    r^4 * sin(4*theta)             sqrt(10)
%       --------------------------------------------------
% 
% Zernike order and frequency
% Zord  = [0  1  1  2  2  2  3  3  3  3  4  4  4  4  4];
% Zfrq  = [0 -1  1 -2  0  2 -3 -1  1  3 -4 -2  0  2  4];
%

