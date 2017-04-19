% What is the mean planet contrast for a typical set of candidates?
% B. Nemati - 28-Apr-2016

clc; clear; close all;

loadStyles;

% if ispc,  AnalysisFolder = 'D:\Analysis'; else  AnalysisFolder = '/proj/vesta/Analysis'; end
AnalysisFolder ='.';
DesignsFolder = './CGdesigns';
utilsFolder = [AnalysisFolder,'/CommonUtilities'];
addpath(utilsFolder);

ip=0; placefigure(3,5,1);

% close all
loadUnits;

%--------------- get planets list ----------------
load RVplanets

%--------------- study parameters ----------------
detCase = TradeStudyParameters;
Ndet = length(detCase);

days_alloc = 30;

instr.f_pp = 0.1;

% Zodi brightness - assume local zodi = 22.1 mag /arcsec^2 in V band
% assume  skynoise = (local-zodi + exo-zodi) =  2 * localzodi
magZodi = 22.1;
nZodi   = 1 + 1;

waveCenters = [ 550,  660,  770,  890] * nm;
bandWidths  = [0.15, 0.18, 0.18, 0.18];

Scenario(1).wavelength = waveCenters(1);
Scenario(1).bandwidth  = bandWidths(1);
Scenario(1).FP_type = 1;
Scenario(1).CG_type = 'HLC';

Scenario(2).wavelength = waveCenters(2);
Scenario(2).bandwidth  = bandWidths(2);
Scenario(2).FP_type = 2;
Scenario(2).CG_type = 'SPC';

Scenario(3).wavelength = waveCenters(3);
Scenario(3).bandwidth  = bandWidths(3);
Scenario(3).FP_type = 2;
Scenario(3).CG_type = 'SPC';

% assume we are not going to be using the longest wavelenth
% Scenario(4).wavelength = waveCenters(4);
% Scenario(4).bandwidth  = bandWidths(4);
% Scenario(4).FP_type = 2;
% Scenario(4).CG_type = 'SPC';


Nscenario = 3;

% -----------------------------------------------------
% the trade study spreadsheet specifies QE at three wavelengths`
QEWavelens = [550 750 950] * nm;
minIntegTime = 0 * second;
maxIntegTime = 1000 * day;


%     maxPlanets=0;
itrace = 0;
ip=ip+1; placefigure(ip);
traceLegend = [];


%------------ get WFIRST basic parameters-------------

% First put in the throughputs that are working angle independent
instr.thp.refltran = (0.985^23)*0.91^2; % = JK numbers incl DM's
instr.thp.filter   = 0.9;
instr.thp.pol      = 0.5;
instr.thp.pupil    = 1.0;

idet = 1;
isce = 1;
CGtype = Scenario(isce).CG_type;
switch CGtype
    case 'HLC', CGfile = 'hlc_runpolx3_0.4mas_jitter_results.txt'; %latest HLC with 15pc BW
    case 'PIAA',CGfile = 'piaacmc_20150322_0.4mas_jitter_results.txt';
    case 'SPC', CGfile = 'spc_20140901-1_0.4mas_jitter_results.txt';
end

% ================= CORONAGRAPH DATA =====================================
CGdata = loadCGdata(CGfile,DesignsFolder);
if ( strcmp(CGtype,'HLC') && ~isempty(strfind(upper(CGdata.CGdesign),'POLX')) || strcmp(CGtype,'PIAA') )
    specklePol = 1;  % polarization has been preapplied for the speckles so don't apply again
else
    specklePol = instr.thp.pol; % polarization throughput hit has not been applied so apply it
end


instr.D          = 2.4 * meter;
instr.specResol  = 70;  % Spectral resolution is defined as R = lam / dlam
instr.IFS_nLensl = 9; % no. of lenslets per lam/D in the IFS
instr.obsc       = 0.34; % diameter of obscuration relative to primary
instr.strutObsc  = 0.05;
instr.colArea    = (pi/4) * instr.D^2 * (1 - instr.obsc^2) * (1 - instr.strutObsc);
instr.minImgWL   = waveCenters(1) * (1-bandWidths(1)/2) ; % shortest wavelength of interest for Imaging
instr.minIFSWL   = waveCenters(2) * (1-bandWidths(2)/2) ; % shortest wavelength of interest for IFS
instr.maxIFSWL   = waveCenters(3) * (1+bandWidths(3)/2) ; % longest wavelength seen by IFS (ASSUMING 2 BANDS)
instr.minSamp    = 0.5; % desired sampling at minimum wavelength


minWA = CGdata.rlamD(1);
maxWA = CGdata.rlamD(end);

scenLambda = Scenario(isce).wavelength;
scenBW     = Scenario(isce).bandwidth;
lam_D      = scenLambda / instr.D;

star_Mag_Lambda     = mag_at_lambda(RVp.VMAG, RVp.SPEC, scenLambda)';
starFlux            = photonFlux(scenLambda, scenBW * scenLambda, star_Mag_Lambda);

% Planet contrast C = albedo * phi(alpha) * (r_p / SMA)^2;
% phi(alpha) = (sin(alpha) + (pi-alpha)*cos(alpha)) / pi , where alpha = phase angle
phi_90deg           = 1/pi;
planetContrast      = RVp.ALBEDO * phi_90deg .* ( (RVp.RADIUS * earthRadius) ./ (RVp.SMA * AU)).^2;
planetSeparation    = ((RVp.SMA * AU) ./ (RVp.DIST * parsec)) ; % planet separation (in rad) and working angle (in lambda/D)
planetWorkingAngle  = planetSeparation / lam_D;



% set instrument parameters for the case where the instrument has
% this detector

% the effective focal length is set to Nyquist sample the shortest
% wavelength of interest with this detector's pixel size
instr.imgFocLen   = detCase(idet).pixelSize / (0.5 * (instr.minImgWL/instr.D));
instr.imgSampling = detCase(idet).pixelSize / (instr.imgFocLen * lam_D );

% similary for the ifs side: sampling is set to meet requirements
% at min IFS wavelength of interest
instr.ifsFocLen   = detCase(idet).pixelSize / (0.5 * (instr.minIFSWL/instr.D));
instr.ifsSampling = detCase(idet).pixelSize / (instr.ifsFocLen * lam_D );

% Focal plane types and their respective attributes
if Scenario(isce).FP_type == 1
    % 1 = Imaging Channel
    FPtypeName = 'Imager';
    SNR  = 5;
    mpix = (pi/4) * instr.imgSampling^2 ; % pixels within psf fwhm contour
    f_sr = 1;  % fraction of the PSF core light inside the designated signal region
else
    % 2 = IFS Channel
    FPtypeName = 'IFS';
    SNR  = 5; % 10
    specElem = scenLambda/instr.specResol ; % width of a single spectral element in the IFS
    Nspec = round(scenBW * scenLambda / specElem);
    mpix  = instr.IFS_nLensl * 2 * instr.ifsSampling;  %(2 rows to capture the full spectrum) x (cols for sampling of each spectral element)
    f_sr  = 1 / Nspec;  % fraction of the PSF core light inside the designated signal region
end

idet = 1

det.name        = char(detCase(idet).ShortName);
det.readNoise   = detCase(idet).RNerms * detCase(idet).Gain;
det.EMgain      = detCase(idet).Gain;
det.ENF         = detCase(idet).ENF;
det.CIC         = detCase(idet).CICepixtransfer;
det.QE          = interp1(QEWavelens, [detCase(idet).QE550, detCase(idet).QE750, detCase(idet).QE950]/100, scenLambda);
det.darkCurrent = detCase(idet).IDKepixsec;
det.frameRate   = 1 / (100 *second);

% Detector Noise
readNoiseRate   = (det.readNoise / det.EMgain)^2 * mpix * det.frameRate ;
darkCurrentRate = det.darkCurrent * mpix ;
clkIndChgRate   = det.CIC         * mpix * det.frameRate ;

[npl_orig, ~] = size(RVp);   % # of planets
ipl = 0;         integTimeReq = [];        all_time = [];
for iplo = 1: npl_orig        % for each planet candidate in RV list,
    if planetWorkingAngle(iplo) >= minWA && planetWorkingAngle(iplo) <= maxWA
        ind = find(CGdata.rlamD <= (planetWorkingAngle(iplo)), 1, 'last');  % index of last radial slice < planet's radius
        ipl = ipl + 1;
        
        % Compute the throughputs, keeping in mind that:
        %   planet  = psf pup occ ref fil pol
        %   zodi    = 1   pup occ ref fil pol
        %   speckle = 1    1   1  ref fil pol(or 1)
        %   occ  = fpm x lyot
        %   core = psf x pup x occ = psf x pup x fpm x lyot
        
        instr.thp.occulter = CGdata.occ_trans(ind);    % FPM x Lyot (non-POLX)
        instr.thp.core     = CGdata.core_thruput(ind); % instr.thp.pupil * instr.thp.occulter * instr.thp.PSF;
        instr.thp.PSF      = instr.thp.core / ( instr.thp.occulter * instr.thp.pupil ) ;
        
        % note that the planet thp has no tau_PSF because this is the per pixel thp
        % not the thp into the core. The PSF shape itself inherently contains that
        instr.thp.planet = instr.thp.PSF * instr.thp.pupil * instr.thp.occulter * instr.thp.refltran * instr.thp.filter * instr.thp.pol;
        instr.thp.zodi   =            1  * instr.thp.pupil * instr.thp.occulter * instr.thp.refltran * instr.thp.filter * instr.thp.pol;
        instr.thp.speck  =            1  *               1 *                  1 * instr.thp.refltran * instr.thp.filter * specklePol   ;
        
        ZodiFlux = nZodi * photonFlux(scenLambda, scenBW * scenLambda, magZodi) * CGdata.areasq_arcs(ind) * arcsec^2;
        
        speckleFluxRatio = CGdata.contrast(ind) * CGdata.PSF_peak(ind) * mpix ;
        
        % Rate from planet is calculated for the region within the psf core (~FWHM)
        planetRate(ipl)  = f_sr * starFlux(iplo) * planetContrast(iplo)* instr.colArea * instr.thp.planet * det.QE;
        speckleRate(ipl) = f_sr * starFlux(iplo) * speckleFluxRatio    * instr.colArea * instr.thp.speck  * det.QE;
        zodiRate(ipl)    = f_sr * ZodiFlux                             * instr.colArea * instr.thp.zodi   * det.QE;
        
        totElecRate(ipl) = det.ENF^2 * (planetRate(ipl) + speckleRate(ipl) +  zodiRate(ipl)) + ...
                           det.ENF^2 * (darkCurrentRate + clkIndChgRate)   +  readNoiseRate;
        
        integTimeReq(ipl) = (SNR^2 * totElecRate(ipl)) / (planetRate(ipl)^2 - (SNR * instr.f_pp *speckleRate(ipl))^2) ;
        
        % Add metadata for this and every planet that is detectable
        photon_flux(ipl)    = planetContrast(iplo)* starFlux(iplo);
        CG_contrast(ipl)    = CGdata.contrast(ind);
        CG_coreArea_as2(ipl)= CGdata.areasq_arcs(ind);
        origindex(ipl)      = iplo;
    end
end
% Identify the planets that give a solution for realistic integration time
IndexRealCandidates = find( integTimeReq>minIntegTime & integTimeReq<maxIntegTime );

tmp = sortrows([IndexRealCandidates', (integTimeReq(IndexRealCandidates))'], 2);
sortedCandidates_ind = tmp(:,1)';

disp ' '
disp([CGtype,' candidate planets: lam=',num2str(scenLambda*1e9),'nm, Det = ',det.name]);

commandString = ['Ncandid(',num2str(isce),').', strrep(det.name,' ','_'),' = length(sortedCandidates_ind);'];
eval(commandString);


NsortCand = length(sortedCandidates_ind);
for ican = 1 : NsortCand
    ican;
    ior = origindex(sortedCandidates_ind(ican));
    Vmag = RVp.VMAG(ior);
    Dist = RVp.DIST(ior);
    plRadius = RVp.RADIUS(ior);
    StarName = RVp.NAME{ior};
    RAhost = RVp.RADEG(ior);
    DEChost = RVp.DECDEG(ior);
    
    candInfo(ican).StarSpec = RVp.SPEC{ior};
    candInfo(ican).Vmag = RVp.VMAG(ior);
    candInfo(ican).Dist = RVp.DIST(ior);
    candInfo(ican).plRadius = RVp.RADIUS(ior);
    candInfo(ican).StarName = RVp.NAME{ior};
    candInfo(ican).timeReq_day = integTimeReq(sortedCandidates_ind(ican))/24/60/60;
    candInfo(ican).timeReq_sec = integTimeReq(sortedCandidates_ind(ican));
    
    candInfo(ican).planet_workingAngle = planetWorkingAngle(ior);
    candInfo(ican).planet_contrast = planetContrast(ior);
    candInfo(ican).starFlux = starFlux(origindex(sortedCandidates_ind(ican)));
    candInfo(ican).planet_Rate  = planetRate(sortedCandidates_ind(ican));
    candInfo(ican).speckle_Rate = speckleRate(sortedCandidates_ind(ican));
    candInfo(ican).planet_photonFlux = photon_flux(sortedCandidates_ind(ican));
    
    candInfo(ican).CG_coreArea_as2 = CG_coreArea_as2(sortedCandidates_ind(ican));
    candInfo(ican).CG_contrast = CG_contrast(sortedCandidates_ind(ican));
    candInfo(ican).zodi_Rate   = zodiRate(sortedCandidates_ind(ican));
    candInfo(ican).totElecRate = totElecRate(sortedCandidates_ind(ican));
    
    disp(['candidate #',num2str(ican,'%03.0f'),...
        ':  planet #',num2str(ior,'%03.0f'),...
        '  ',StarName, ...
        '  RA(deg)=',num2str(RAhost), ...
        '  DEC(deg)=',num2str(DEChost), ...
        '  C_planet=',num2str(planetContrast(ior),'%6.3e'),...
        '  Vmag=',num2str(Vmag,'%05.2f'),...
        '  Dist=',num2str(Dist,'%06.3f'),'pc'...
        '  T_integ=',num2str(integTimeReq(sortedCandidates_ind(ican))/(24*3600),'%5.3f'),' days']);
end

if ~isempty(integTimeReq(sortedCandidates_ind))
    itrace = itrace + 1;
    all_time{itrace} = integTimeReq(sortedCandidates_ind)/3600/24;
    traceLegend{itrace} = det.name; %#ok<*SAGROW>
    semilogy(cumsum(all_time{itrace}), ...
        'MarkerFaceColor',colorset1(itrace,:),'Marker',markerstyles{itrace},'MarkerSize',markersizes{itrace},...
        'LineStyle',linestyles{itrace},'linewidth',2, 'Color',colorset1(itrace,:)), hold on
end
 

grid on
legend(traceLegend,'location', 'Best','Interpreter', 'None')
ylabel('Cumulative Time  (days)','fontsize',12)
titlestr = [FPtypeName,'   (' , num2str(scenLambda/nm), 'nm,',num2str(scenBW*100),'%BW)    SNR = ',...
    num2str(SNR), '  ' CGtype  '  f_{pp} = ' num2str(instr.f_pp*100),'%'];
title(titlestr ,'fontsize', 10)
xlabel('Number of Candidates','fontsize',12)
gridxy([],30,'Color',[.8 .9 .5],'Linestyle','-','Linewidth',3) ;

Cpl_can = cat(1,candInfo.planet_contrast);

ip=ip+1; placefigure(ip)
hist (Cpl_can*1e9, 30)
xlabel('planet contrast, x 10^9')
title(['Mean contrast among ',num2str(NsortCand),' candidates = ',...
    num2str(mean(Cpl_can),'%7.2e')], 'FontSize',10);

return

