function afta = setup_AFTA()

meter = 1; nm = 1e-9; km = 1e3*meter; AU = 149597870700 * meter;
deg = pi/180; arcsec = deg/3600; parsec = AU / arcsec;
earthRadius = 6371 * km;

%==========================================================================
% Basic afta parameters

afta.D          = 2.4 * meter;
afta.specResol  = 70;  % Spectral resolution is defined as R = lam / dlam
afta.IFS_nLensl = 9; % no. of lenslets per lam/D in the IFS
afta.obsc       = 0.34; % diameter of obscuration relative to primary
afta.strutObsc  = 0.05;
afta.colArea    = 3.6698 * meter^2; %(pi/4) * afta.D^2 * (1 - afta.obsc^2) * (1 - afta.strutObsc);
% afta.lambda     = 550 * nm;
% afta.bandwidth  = 0.1;
% afta.lam_D      = afta.lambda / afta.D;
% afta.PSFcorArea = 2.0109e-03 * arcsec^2;

afta.thp.refltran = (0.985^23)*0.91^2; % = JK numbers incl DM's
afta.thp.filter   = 0.6;
afta.thp.polarizer= 0.5;

% afta.thp.pupil    = 1.0;
% afta.thp.occulter = 0.27; % FPM x Lyot
% afta.thp.PSF    = 0.105;
% afta.thp.core   = afta.thp.pupil * afta.thp.occulter * afta.thp.PSF;
% 
% % NOTE: {* afta.thp.polarizer}  NEEDED IF NOT HLC-POLX OR PIAACMC - SEE BELOW!
% afta.thp.speck  = afta.thp.refltran * afta.thp.filter; 
% 
% afta.thp.zodi   = afta.thp.pupil * afta.thp.occulter * afta.thp.speck;
% afta.thp.planet = afta.thp.PSF * afta.thp.pupil * afta.thp.occulter * afta.thp.speck;
% afta.thp.plFlux = afta.thp.pupil * afta.thp.occulter * afta.thp.speck; % this to be used for the planet PSF flux map
% 
% %---------------------------------------------------
% afta.CG.meanContrast = 7e-10; % per pixel,  2014 HLC table, 0.4 mas jitter, contrast0.4, at 5.4 lam/D
% afta.CG.psfPeak = 5.5e-3;  % peak pixel, 2014 HLC contrast table, 5.4 lam/D, John Krist - Note that this is attenuated by the polarizer
% afta.CG.sampling = 0.3;   % pix/(lam/D) in the John Krist tables
% afta.CG.Cmpix = (pi/4)*(1/afta.CG.sampling)^2; % pixels per PSF core in the original table
% %---------------------------------------------------

end
% ===========================================================================================================================
% APPENDIX:  Understanding the contrast tables from John Krist:
% ===========================================================================================================================
% 
% The HLC polx and PIACMC tables include the attenuation (throughput loss)
% due to the polarizer for I, core_thruput, PSF_peak, and occ_trans 
%  
% so, to calculate the mean speckle level, the throughput 
%  
%  
% Below are excerpts from two contrast table files for the HLC design
% ---------------------------------------------------------------------------------------------------------------------------
%      r(lam/D)     r(arcsec)        I           contrast       core_thruput      PSF_peak      area(sq_arcsec)  occ_trans
% ---------------------------------------------------------------------------------------------------------------------------
% .............  hlc_20140623-139_0.4mas_jitter_results.txt  ................................................................
%       3.00000     0.143602   1.1689422e-11   3.8758899e-09     0.022367177    0.0030159324    0.0020705070      0.39442343
%       3.30000     0.157962   6.6227517e-12   1.5575568e-09     0.030859951    0.0042520129    0.0020109240      0.39442343
%       5.40000     0.258484   4.5271587e-12   7.9960251e-10     0.041660457    0.0056617615    0.0020556112      0.39442343
%  
% .............  hlc_20140623-139_0.4mas_jitter_results_polx.txt  ...........................................................
%       3.00000     0.143602   1.6973625e-12   1.1255972e-09     0.011183589    0.0015079662    0.0020705070      0.19721172
%       3.30000     0.157962   1.5311561e-12   7.2020295e-10     0.015429976    0.0021260064    0.0020109240      0.19721172
%       5.40000     0.258484   1.1051182e-12   3.9037963e-10     0.020830229    0.0028308807    0.0020556112      0.19721172
% ...........................................................................................................................
%  
% Reductions due to reflections, CCD QE are omitted. Coronagraph mask throughputs
% are included.  Polarizer reduction is included as noted below.
%  
% > I = mean speckle intensity at r, normalized to flux incident on primary
% > contrast = I(r) / PSF_peak(r)
% > core_thruput = fraction of light incident on primary that makes it into the FWHM region of a field PSF centered at r
% > PSF_peak = fraction of light in peak pixel of field PSF centered at r normalized to flux incident on primary
% > area = area of the FWHM region of the field PSF centered at r
% > occ_trans = occulter * lyot stop transmission at r
%  
% > Pixel sizes (for I, PSF_peak):  hlc, piaacmc = 0.3 lam/D, spc = 0.2 lam/D
%  
% > Reduction by 0.5 due to polarizer included in HLC polx and piaacmc values for: I, core_thruput, PSF_peak, and occ_trans 
% ...........................................................................................................................
% % 







