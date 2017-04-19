function flux = bandFlux( Mag, Band )
% Fluxes based on
% Photon Rates per spectral band (from book by P. Lena and Joint Astro. Ctr.)

meter = 1; kg=1; second = 1;
h_planck    = 6.62606896e-34 * meter^2 * kg / second;
c_light     = 299792458 * meter / second;
um = 1e-6 * meter;

F.band = Band;
F.Mag  = Mag;

switch Band
    case 'U'
        F.lambda = 0.36 * um;
        F.dlam = 0.068 * um;
        F.E0 = 4.35e-8;

    case 'V'
        F.lambda = 0.55 * um;
        F.dlam = 0.089 * um;
        F.E0 = 3.92e-8;
        
    case 'R'
        F.lambda = 0.70 * um;
        F.dlam   = 0.22 * um;
        F.E0     = 1.76e-8;
    otherwise
        error 'unsupported band';
end

flux = F.E0 * (F.lambda / (h_planck*c_light))*10.^(-Mag/2.5) * (F.dlam/um);

return


    
%  Photon Rates per spectral band (from book by P. Lena and Joint Astro. Ctr.)   
% U	0.36	0.068	4.35E-08
% B	0.44	0.098	7.20E-08
% V	0.55	0.089	3.92E-08
% R	0.70	0.220	1.76E-08
% VIS	0.80	0.200	1.21E-08
% I	0.90	0.240	8.30E-09
% Y	1.05	0.200	5.72E-09
% J	1.26	0.260	3.40E-09
% H	1.64	0.330	1.18E-09
% K	2.18	0.440	3.90E-10
% L	3.40	0.550	7.30E-11
% M	5.00	0.300	2.12E-11
% N	10.20	5.000	1.23E-12
% Q	21.00	8.000	6.80E-14



end

