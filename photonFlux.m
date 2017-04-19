function y = photonFlux(centerLambda, dLambda, Magnitude)
% y = Flux(CenterLambda, dLambda, Magnitude)
% compute the photon flux given the center wavelength (centerLambda), the
% wavelength band (dLambda) and the apparent magnitude (Magnitude)
% inputs and outputs are all in SI/MKS units
% in particular, input wavelenths are in meters and the output photon flux
% is in photons / second / meter^2

meter = 1; kg=1; second = 1;
h_planck    = 6.62606896e-34 * meter^2 * kg / second;
c_light     = 299792458 * meter / second;
um = 1e-6 * meter;

ma = [...
        0.36,	-7.361510743;
        0.44,	-7.142667504;
        0.55,	-7.406713933;
        0.70,	-7.754487332;
        0.80,	-7.917214630;
        0.90,	-8.080921908;
        1.05,	-8.242603971;
        1.26,	-8.468521083;
        1.64,	-8.928117993;
        2.18,	-9.408935393;
        3.40,	-10.13667714;
        5.00,	-10.67366414;
        10.2	-11.91009489;
        21.0,	-13.16749109];

a = interp1(ma(:,1), ma(:,2), centerLambda/um);

y = (10.^(a-0.4*Magnitude) / (h_planck * c_light / centerLambda)) * (dLambda/um);

return
end

