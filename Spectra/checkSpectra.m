%% Description
% Process' J. Krist's star spectra and plots them
%% Clear
close all
clear
clc

addpath('../CommonUtilities');

ip=0; placefigure(2,2,1);
%% Color defs [RGB]
gray1=[.85 .87 .85];purple1=[.4 .1 .5];
red1=[1 0 0]; red2=[.7 .2 .2]; red3=[0.60,0.24,0.42];red4=[0.79,0.56,0.54];
green1=[.2 0.6 0]; green2=[.1 .4 .2]; green3=[.5 .5 .3];
blue1=[0 0.4 1]; blue2=[0 0.6 1];blue3=[0.41,0.49,0.63];
yellow1=[.95 0.8 0.13]; yellow2=[1 0.8 0.13]; yellow3=[.97, .90, .01];
colorset1 = [blue1;green1;red1;yellow1;blue2;green2;red2;yellow2;blue3;green3;red3;yellow3;purple1];
%% Units
meter = 1; kg = 1; second = 1; Watt = 1; Joule = 1; erg = 1e-7 * Joule;
ms = second *1e-3; us = ms * 1e-3; cm = 0.01 * meter;
um = 1e-6 * meter; nm = 1e-9 * meter;
in = 0.0254 * meter; Angstrom = 1e-10 * meter;
c_light = 3e8 * meter / second;
h_planck = 6.6266e-34 * kg  * meter^2 / second;

starTypes = {'a0v.dat', 'a5v.dat', 'f5v.dat', 'g0v.dat', 'g5v.dat', 'k0v.dat', 'k5v.dat', 'm0v.dat', 'm5v.dat'};



% first get normalized spectra


% Desired wavelength base parameters in Angstroms
lam1 = 2500;
lam2 = 10500;
dlam = 10;

waveBase = lam1:dlam:lam2;

spec.wavelength = waveBase * Angstrom;

nSpectra = length(starTypes);
ip=ip+1; placefigure(ip);
for ifile = 1:nSpectra
    filename = starTypes{ifile};
    % fileImport imports the data file and outputs two variables to be plotted
    [stWl, stFl] = fileImport(filename);
    stFlmks = stFl * erg / second / cm^2 / Angstrom ;   
    
    spec.(strtok(filename,'.')).flux = interp1(stWl, stFlmks, waveBase);

    ph = plot(spec.wavelength, spec.(strtok(filename,'.')).flux);
    set(ph,'LineWidth',1,'marker','o','DisplayName',filename);
    hold on
end
legend('location', 'best')
grid
hold off
ylabel('F_{\lambda},     W / m^2 / m')
xlabel('\lambda,    m')

% Import the filters and plot them
filters = {'V.dat', 'R.dat', 'I.dat'};
nSpectra = length(filters);

ip=ip+1; placefigure(ip);
for ifile = 1:nSpectra
    filename = filters{ifile};
    % fileImport imports the data file and outputs two variables to be plotted
    [filWl, filFl] = fileImport(filename);
    filter.(strtok(filename,'.')).wavelength   = filWl * Angstrom;
    filter.(strtok(filename,'.')).transmission =  filFl;

    ph = plot(filter.(strtok(filename,'.')).wavelength, filter.(strtok(filename,'.')).transmission);
    set(ph,'LineWidth',1,'marker','o','DisplayName',filename);
    hold on
end
legend('location', 'best')
grid
hold off
ylabel('Transmission')
xlabel('\lambda,    m')


% Check that the fluxes are normalized as vmag = 0

wsmin = filter.V.wavelength(1) ;
wsmax = filter.V.wavelength(end);
wsdel = 4 * nm;

wsbase = wsmin:wsdel:wsmax;

Vinterp = abs(interp1(filter.V.wavelength, filter.V.transmission, wsbase,'spline' ,'extrap'));


nSpectra = length(starTypes);
ip=ip+1; placefigure(ip);
for ifile = 1:nSpectra
    filename = starTypes{ifile};
    
    specInterp = interp1(spec.wavelength, spec.(strtok(filename,'.')).flux, wsbase);
    
    filteredSpec = specInterp .* Vinterp;
    ph = plot(wsbase, filteredSpec);
    set(ph,'LineWidth',1,'marker','o','DisplayName',[filename, ' \Sigma=',num2str(wsdel * sum(filteredSpec))]);
    hold on
end
legend('location', 'best')
grid
hold off
ylabel('F_{\lambda},     W / m^2 / m')
xlabel('\lambda,    m')



% check that the interpretation of the V filter is correct
% nominally people assume a box transmission of height 1 and width 89 nm
% centered around 550 nm

checkVbandWeightedMean_nm = sum(filter.V.wavelength .* filter.V.transmission)/sum(filter.V.transmission) / nm
checkVbandEffectiveWidth_nm = sum(filter.V.transmission)*(filter.V.wavelength(2)-filter.V.wavelength(1))/nm

% MM = [spec.wavelength' , spec.a0v.flux',spec.a5v.flux',spec.f5v.flux',spec.g0v.flux',spec.g5v.flux',spec.k0v.flux',spec.k5v.flux',spec.m0v.flux', spec.m5v.flux']

return




