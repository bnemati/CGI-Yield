%-------------------------------------------------------------------------
% Units 
% All quantities are converted and held in SI units, and angles in radians

global meter second kg Coulomb Ohm Farad Kelvin Joule Watt ...
    AU km cm mm um nm inch ...
    usec ...
    deg mrad urad arcsec mas uas ...
    day ...
    Hz kHz mW uW radian Ampere mA uA ...
    earthRadius parsec lightyear h_planck c_light

     
meter = 1; second = 1; kg = 1; AU = 149597870700 * meter;
Coulomb = 1; Ohm = 1; Farad = 1; Kelvin = 1; Joule = 1; Watt = 1; 
radian = 1; 
km = 1000 * meter; cm = .01 * meter; mm = .001* meter; inch = 2.54*cm;
um = 1e-6*meter; nm = 1e-9*meter;
mW = 1e-3*Watt; uW = 1e-6*Watt; nW = 1e-9*Watt;
Ampere = 1 * Coulomb/second; mA = 1e-3 * Ampere;  uA = 1e-6 * Ampere; 

Hz = 1/second; kHz = 1e3 * Hz;
deg = (pi / 180) * radian ; mrad = 0.001 * radian; urad = 0.001 * mrad;
arcsec = deg / 3600; mas = arcsec / 1000; uas = mas / 1000;

day = 24 * 3600 * second;
usec = 1e-6*second;

earthRadius = 6371000 * meter;
parsec = AU / arcsec;
lightyear = 9.4607e15 * meter;