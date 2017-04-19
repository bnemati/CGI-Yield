function out = newfigure(varargin)
%       out = newfigure(varargin)
%
% Initial call must be to define the positions for a grid of figures nrow x ncol 
% spanning the entire screen:
%      > if called with no inputs, 
%           will automatically set up for appoximately 300 x 300 pix figures
%      > if called with two inputs nrow, ncol,
%           will setup for nrow x ncol figures 
%
% In subsequent calls, with one input, ip, it creates a figure in the slot ip
%            counting from top left to bottom right in the grid of nrow x ncol slots
%
%   example:
%   
%      newfigure(3,4);   % initialize the persistent position array to 3x4 slots
%      ip = 0;           % position/slot number initialization
%      ...
%
%      ip=ip+1;newfigure(ip); % increment position number and make a new figure there
%      plot(sin(1:10))
%      ...
%
%      ip=ip+1;newfigure(ip); % etc.
%      plot(cos(1:10))
%      ...
%
% B. Nemati  21-Sep-2007 -- last update: 06-Oct-2009

persistent poses nrow ncol

if (nargin == 0 || (nargin == 2 && ~ischar(varargin{2})) )
    
    bdwidth=5;
    topbdwidth=70;
    menuheight=80;
    taskbarheight = 40; % a guess
    
    set(0,'Units','pixels');
    scnsize = get(0,'ScreenSize');
    
    if ( nargin == 0 )
        scolrow = round( scnsize /350 );
        nrow = scolrow(4);
        ncol = scolrow(3);
    elseif (nargin ==2 )
        % 2 input arguments means the rows and cols of figures is being specified
        nrow = varargin{1};
        ncol = varargin{2};
    end

    leftcorner1 = bdwidth ;
    bottcorner1 = bdwidth + taskbarheight + (scnsize(4)-taskbarheight)*(nrow-1)/nrow;

    width1  = scnsize(3)/ncol -2*bdwidth;
    height1 = (scnsize(4)-taskbarheight)/nrow -(topbdwidth + 1*bdwidth);

    postopleft = [leftcorner1, bottcorner1, width1, height1];

    poses = [];
    for ir = 1:nrow
        for ic = 1:ncol
            if ic == 1
                position = postopleft + [ 0 -(ir-1)*(height1+menuheight) 0 0 ];
            else
                position = position + [scnsize(3)/ncol 0 0 0];
            end
            poses = [poses; position];
        end
    end

    out = poses;
    disp(['newfigure has intialized the grid of figure positions to ', ...
        num2str(nrow),' x ',num2str(ncol)])

elseif nargin == 1 || (nargin == 2  && ischar(varargin{2}))
    % a single input argument means a new figure is being requested at the next
    % available slot
    ip = varargin{1};
    if ( ip < 1 )
        error(['newfigure called with figure number (',num2str(ip),'): less than zero.']);
    end
    modp = mod(ip-1, nrow*ncol) + 1 ;
    if nargin ==2
        PH = figure('Position',poses(modp,:),'Name',varargin{2});
    else
        PH = figure('Position',poses(modp,:));
    end
    out = PH;
else
    error('newfigure should be called with only 0, 1 or 2 arguments')
end

return
