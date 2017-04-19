function out = placefigure(varargin)
%       out = PLACEFIGURE(varargin)
%
% Initial call must be to define the positions for a grid of figures nrow x ncol
% spanning the entire screen:
%      > if called with two inputs nrow, ncol,
%           will setup for nrow x ncol figures
%
% In subsequent calls, with one input, ip, it creates a figure in the slot ip
%            counting from top left to bottom right in the grid of nrow x ncol slots
%
%   Example:
%
%      placefigure(3,4);   % initialize the persistent position array to 3x4 slots
%      placefigure(3,4,2); % alternative form: initialize to 3x4 slots on Monitor 2
%      ip = 0;            % position/slot number initialization
%      ...
%
%      ip=ip+1;placefigure(ip); % increment position number and make a new figure there
%      plot(sin(1:10))
%      ...
%
%      ip=ip+1;placefigure(ip); % etc.
%      plot(cos(1:10))
%      ...
%
% B. Nemati  22-Sep-2011

persistent poses nrow ncol

if ( (nargin == 2 && ~ischar(varargin{2})) || nargin == 3 )
	
	
	set(0,'Units','pixels');
	
	% 2 input arguments means the rows and cols of figures is being specified
	nrow = varargin{1};
	ncol = varargin{2};
	
	
	% Wondows reports monitor position in the following order:
	%   col(top,left) row(top left) col(bot,right) row(bot,right)
	% on such row of number is reported per existing monitor.
	% Windows measures from top left while Matlab measures from bottom left
	
	MonitorPositions = get(0,'MonitorPositions');  % All monitors
	
	% iMon is the selected monitor
	if nargin == 3
		iMon = varargin{3};
	else
		iMon = 1;   % if called with only (nrow,ncol), assume Monitor 1
	end
	
	menuheight=54;
	
	if 1
		
		TopFigureBorder = 30;
		FigureBorder = 8;
		
		poses = zeros(nrow*ncol, 4);
		
			
		% Try to compensate for the start menu, if not simply apply a margin
		try
			
			tempFigure = figure('Position',[MonitorPositions(iMon,1:2)+100 100 100]);
			
			drawnow; pause(0.01); % Wait for window to open
			
			warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');			
			tempFigureHandle = get(handle(gcf),'JavaFrame');
			warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
			
			set(tempFigureHandle,'Maximized',1); % Maximize window that contains the tempFigure
			
			drawnow; pause(0.01); % Wait for window to get maximized
			
			MaximizedWindowSize = get(tempFigure,'Position');
			MaximizedWindowSize(4) = MaximizedWindowSize(4) + menuheight + TopFigureBorder - FigureBorder; % Set monitor to size of maximized window (including borders)
			NewMonitorSize = MaximizedWindowSize;
						
			if NewMonitorSize == 100
				error('Incorrect monitor size detected. Not compensating for start menu.')
			end
			
			MonitorPositions(iMon,:) = NewMonitorSize;
			
		catch
					
			% The margin to apply to the monitor, [top right bottom right]
			ScreenMargin = [50 50 50 50];
			
			% Apply screen margin, effectively translate and shrink monitor
			MonitorPositions(:,1) = MonitorPositions(:,1) + ScreenMargin(4);
			MonitorPositions(:,2) = MonitorPositions(:,2) + ScreenMargin(3);
			MonitorPositions(:,3) = MonitorPositions(:,3) - ScreenMargin(2) - ScreenMargin(4);
			MonitorPositions(:,4) = MonitorPositions(:,4) - ScreenMargin(1) - ScreenMargin(3);
		end
			
		close(tempFigure)
		drawnow; pause(0.1);
		
		
		i = 1;
		for ir = nrow:-1:1
			for ic = 1:ncol
				poses(i,:) = [...
					MonitorPositions(iMon, 1) + (ic-1) * MonitorPositions(iMon, 3)/ncol + FigureBorder,...
					MonitorPositions(iMon, 2) + (ir-1) * MonitorPositions(iMon, 4)/nrow + FigureBorder,...
					MonitorPositions(iMon, 3)/ncol - 2*FigureBorder,...
					MonitorPositions(iMon, 4)/nrow - FigureBorder - TopFigureBorder - menuheight];
				i = i + 1;
			end
		end
		
	else
		
		if iMon == 1
			taskbarheight = 40;
			marginOnTop = 80;
		else
			taskbarheight = 0;
			marginOnTop = 0;
		end
		
		figureFullHeight = (MonitorPositions(iMon, 4)-MonitorPositions(iMon, 2)- (taskbarheight+marginOnTop))/nrow;
		figureMatlabHeight = figureFullHeight - menuheight - bdwidth - topbdheight;
		
		leftcorner1 = bdwidth + MonitorPositions(iMon, 1) ;
		bottcorner1 = (MonitorPositions(1,4)-MonitorPositions(iMon,4)) + bdwidth + taskbarheight+ ((nrow-1))*figureFullHeight;
		
		width1  = (MonitorPositions(iMon,3)-MonitorPositions(iMon,1))/ncol - 2*bdwidth;
		height1 = figureMatlabHeight;
		
		postopleft = [leftcorner1, bottcorner1, width1, height1];
		
		poses = [];
		for ir = 1:nrow
			for ic = 1:ncol
				if ic == 1
					position = postopleft + [ 0 -(ir-1)*(height1+bdwidth+topbdheight+menuheight) 0 0 ];
				else
					position = position + [(MonitorPositions(iMon,3)-MonitorPositions(iMon,1))/ncol 0 0 0];
				end
				poses = [poses; position];
			end
		end
		
	end
	out = poses;
	
	%     disp(['placefigure has intialized the grid of figure positions to ', ...
	%         num2str(nrow),' x ',num2str(ncol)])
	
elseif nargin == 1 || (nargin == 2  && ischar(varargin{2}))
	% a single input argument means a new figure is being requested at the next
	% available slot
	ip = varargin{1};
	if ( ip < 1 )
		error(['placefigure called with figure number (',num2str(ip),'): less than zero.']);
	end
	modp = mod(ip-1, nrow*ncol) + 1 ;
	if nargin ==2
		PH = figure('Position',poses(modp,:),'Name',varargin{2});
	else
		PH = figure('Position',poses(modp,:));
	end
	out = PH;
else
	error('placefigure should be called with only 1, 2, or 3 arguments')
end

return
