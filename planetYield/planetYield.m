%  This version is not for evaluating various detectors but for evaluating
%  the yield with the nominal parameters

clc; clear; close all;

loadStyles;

% if ispc,  AnalysisFolder = 'D:\Analysis'; else  AnalysisFolder = '/proj/vesta/Analysis'; end
AnalysisFolder ='.';
DesignsFolder = '../CGdesigns';
utilsFolder   = '../CommonUtilities';
addpath(utilsFolder);

ip=0; placefigure(2,3,1);

% close all
loadUnits;

%--------------- get planets list ----------------

load RVplanets

%--------------- study parameters ----------------
pars = readParameters  % read from excel file of the same name the basic parameters
%----------------------------------------------------------------------------------
detCase = pars.detCase;
scenario = pars.scen;
planets = pars.planets;
emccdQE = pars.QE;
Ndet = length(detCase);
days_alloc = 100;


% Zodi brightness - assume local zodi = 22.1 mag /arcsec^2 in V band
% assume  skynoise = (local-zodi + exo-zodi) =  2 * localzodi
magZodi = 22.1;
nZodi   = 1 + 0;

useScenarios = [ 1 0 0 1 0 1 1 ]


% -----------------------------------------------------
minIntegTime = 0 * second;
maxIntegTime = 1000 * day;

for isce = 1: length(useScenarios);
    %     maxPlanets=0;
    itrace = 0;
%     ip=ip+1; placefigure(ip);
    traceLegend = [];

    
    %------------ get WFIRST basic parameters-------------
    
    % First put in the throughputs that are working angle independent 
    instr.thp.filter   = 0.9;
    instr.thp.pol      = 0.48;
    instr.thp.pupil    = 1.0;
    
    CGtype = scenario(isce).Coronagraph;
    switch CGtype
        case 'HLC', 
            instr.thp.refltran = 0.585;  
            CGfile = 'hlc-20160125_0.4mas_jitter_1.0mas_star_results.txt'; %latest HLC with 15pc BW
            CGtauPol = 0.5; % set to 0.5 if certain CGfile parameters aleady include polarizer 50% loss
        case 'SPC', 
            instr.thp.refltran = 0.545;  
            CGfile = 'spc_20140901-1_0.4mas_jitter_results.txt';
            CGtauPol = 1.0; % set to 0.5 if certain CGfile parameters aleady include polarizer 50% loss
    end
    CGdata = loadCGdata(CGfile,DesignsFolder);
    CGdata.core_thruput = CGdata.core_thruput * (CGtauPol/instr.thp.pol);
    CGdata.PSF_peak     = CGdata.PSF_peak     * (CGtauPol/instr.thp.pol);
    CGdata.occ_trans    = CGdata.occ_trans    * (CGtauPol/instr.thp.pol);
    CGintSamp = CGdata.rlamD(2)-CGdata.rlamD(1); % the intrinsic sampling in the data
    
 
    
    instr.D          = 2.4 * meter;
    instr.specResol  = 50;  % Spectral resolution is defined as R = lam / dlam
    instr.IFS_nLensl = 2; % no. of lenslets per lam/D in the IFS
    instr.obsc       = 0.34; % diameter of obscuration relative to primary
    instr.strutObsc  = 0.05;
    instr.colArea    = (pi/4) * instr.D^2 * (1 - instr.obsc^2) * (1 - instr.strutObsc);
    instr.imgNygWL   = 450 * nm ; % shortest wavelength of interest for Imaging
    instr.ifsNyqWL   = 660 * nm ; % shortest wavelength of interest for IFS

    minWA = CGdata.rlamD(1);
    maxWA = CGdata.rlamD(end);

    centerLambda = scenario(isce).centerWl;
    scenBW     = scenario(isce).BW;
    lam_D      = centerLambda / instr.D;
    
    star_Mag_Lambda     = mag_at_lambda(RVp.VMAG, RVp.SPEC, centerLambda)';
    starFlux            = photonFlux(centerLambda, scenBW * centerLambda, star_Mag_Lambda);
    
       
    
    % Planet contrast C = albedo * phi(alpha) * (r_p / SMA)^2;
    % phi(alpha) = (sin(alpha) + (pi-alpha)*cos(alpha)) / pi , where alpha = phase angle
    phi_90deg           = 1/pi;
    planetContrast      = RVp.ALBEDO * phi_90deg .* ( (RVp.RADIUS * earthRadius) ./ (RVp.SMA * AU)).^2;
    planetSeparation    = ((RVp.SMA * AU) ./ (RVp.DIST * parsec)) ; % planet separation (in rad) and working angle (in lambda/D)
    planetWorkingAngle  = planetSeparation / lam_D;
    
    idet = 0;
    for idt = 1: Ndet
        idet = idet + 1;
        
        % set instrument parameters for the case where the instrument has
        % this detector                
        
        % the effective focal length is set to Nyquist sample the shortest
        % wavelength of interest with this detector's pixel size
        instr.imgFocLen  = 2 * detCase(idet).pixelSize / (instr.imgNygWL/instr.D); 
        instr.imgSampling =     detCase(idet).pixelSize / (instr.imgFocLen * lam_D );
        
        % similary for the ifs side: sampling is set to meet requirements
        % at min IFS wavelength of interest (Nyquist sampling)
        instr.ifsFocLen   = 2 * detCase(idet).pixelSize / (instr.ifsNyqWL/instr.D); 
        instr.ifsSampling =     detCase(idet).pixelSize / (instr.ifsFocLen * lam_D );     
        
        % Focal plane types and their respective attributes
        if strcmp(scenario(isce).FPtype, 'Imaging')
            % 1 = Imaging Channel
            FPtypeName = 'Imager';
            mpix = (pi/4) / instr.imgSampling^2 ; % pixels within psf fwhm contour
            f_sr = 1;  % fraction of the PSF core light inside the designated signal region
        else
            % 2 = IFS Channel
            FPtypeName = 'IFS';
            Nspec = round(scenBW * instr.specResol); % No. of spectral elements within the current band
            % 2 'spatial' rows x (~2) 'spectral' cols 
            mpix  = instr.IFS_nLensl * 2 / instr.ifsSampling;  
            f_sr  = 1 / Nspec;  % fraction of the PSF core light inside the designated signal region
        end

        det.name        = char(detCase(idet).ShortName);
        det.readNoise   = detCase(idet).RNerms * detCase(idet).Gain;
        det.EMgain      = detCase(idet).Gain;
        det.ENF         = detCase(idet).ENF;
        det.CIC         = detCase(idet).CIC;
        det.QE          = interp1(detCase(idet).QElam, detCase(idet).QE /100, centerLambda);
        if EndOfLife
            det.darkCurrent = detCase(idet).IDK_EOL;
            MissionEpoch = 'EOL';
        else
            det.darkCurrent = detCase(idet).IDK_BOL;
            MissionEpoch = 'BOL';
        end
        det.frameRate   = 1/detCase(idet).frameTime;
           
        % Detector Noise
        readNoiseRate   = (det.readNoise / det.EMgain)^2 * mpix * det.frameRate ;
        darkCurrentRate = det.darkCurrent * mpix ;
        clkIndChgRate   = det.CIC         * mpix * det.frameRate ;
        
        [npl_orig, ~] = size(RVp);   % # of planets
        ipl = 0;         integTimeReq = [];        all_time = [];
        for iplo = 1:npl_orig        % for each planet candidate in RV list,
            if planetWorkingAngle(iplo) >= minWA && planetWorkingAngle(iplo) <= maxWA
                ind = find(CGdata.rlamD <= (planetWorkingAngle(iplo)), 1, 'last');  % index of last radial slice < planet's radius
                ipl = ipl + 1;
                
                % Compute the throughputs, keeping in mind that:
                %   planet  = psf pup occ ref fil pol
                %   zodi    = 1   pup occ ref fil pol
                %   speckle = 1    1   1  ref fil pol(or 1)
                %
                %   occ = fpm x lyot
                %   core = psf x pup x occ = psf x pup x fpm x lyot
                
                instr.thp.occulter = CGdata.occ_trans(ind);    % FPM x Lyot (non-POLX)
                instr.thp.core     = CGdata.core_thruput(ind); % instr.thp.pupil * instr.thp.occulter * instr.thp.PSF;
                instr.thp.PSF      = instr.thp.core / ( instr.thp.occulter * instr.thp.pupil ) ;
                
                % note that the planet thp has no tau_PSF because this is the per pixel thp
                % not the thp into the core. The PSF shape itself inherently contains that
                instr.thp.planet = instr.thp.PSF * instr.thp.pupil * instr.thp.occulter * instr.thp.refltran * instr.thp.filter * instr.thp.pol;
                instr.thp.zodi   =            1  * instr.thp.pupil * instr.thp.occulter * instr.thp.refltran * instr.thp.filter * instr.thp.pol;
                instr.thp.speck  =            1  *               1 *                  1 * instr.thp.refltran * instr.thp.filter * instr.thp.pol;

                ZodiFlux = nZodi * photonFlux(centerLambda, scenBW * centerLambda, magZodi) * CGdata.areasq_arcs(ind) * arcsec^2;
                
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
        disp([CGtype,' ',FPtypeName,' candidate planets: lam=',num2str(centerLambda*1e9),'nm, Det = ',det.name]);
        
        commandString = ['Ncandid(',num2str(isce),').', strrep(det.name,' ','_'),' = length(sortedCandidates_ind);'];
        eval(commandString);
        
        
        for ican = 1 : length(sortedCandidates_ind)
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
            
            disp(['cand. ',num2str(ican,'%02.0f'),...
                ', Pl. #',num2str(ior,'%03.0f'),...
                '  ',strpad(StarName,9,'post',' '), ...             
                '  Vmag=',num2str(Vmag,'%05.2f'),...
                '  C_pl=',num2str(planetContrast(ior),'%6.3e'),...
                '  Dist=',num2str(Dist,'%04.1f'),' pc'...
                '  T_int=',num2str(integTimeReq(sortedCandidates_ind(ican))/(3600),'%7.3f'),' hr']);
        end
             
        if ~isempty(integTimeReq(sortedCandidates_ind))
            itrace = itrace + 1;
            all_time{itrace} = integTimeReq(sortedCandidates_ind)/3600/24;
            traceLegend{itrace} = det.name; %#ok<*SAGROW>
            semilogy(cumsum(all_time{itrace}), ...
                'MarkerFaceColor',colorset1(itrace,:),'Marker',markerstyles{itrace},'MarkerSize',markersizes{itrace},...
                'LineStyle',linestyles{itrace},'linewidth',2, 'Color',colorset1(itrace,:)), hold on
            %         maxPlanets = max(maxPlanets, max(length(all_time{itrace})));
        end
    end % det type
    
    grid on
    legend(traceLegend,'location', 'Best','Interpreter', 'None')
    ylabel('Cumulative Time  (days)','fontsize',12)
    titlestr = [FPtypeName,'   (' , num2str(centerLambda/nm), 'nm,',num2str(scenBW*100),'%BW)    SNR = ',...
        num2str(SNR), '  ' CGtype  '  f_{pp} = ' num2str(instr.f_pp*100),'%  (',MissionEpoch,')'];
    title(titlestr ,'fontsize', 10)
    xlabel('Number of Candidates','fontsize',12)
    gridxy([],days_alloc,'Color',[.8 .9 .5],'Linestyle','-','Linewidth',3) ;
end


return

