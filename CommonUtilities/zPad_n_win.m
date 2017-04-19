function [tt,ss] = cr_zPad_n_win(t, s, padN, win, sln, sll)

% zero padding & windowing 2d-doppler signal in cross range

if nargin < 4 win = 0; end
if nargin < 3 padN =1; end

sz  = size(s);
if ( length(t) ~=sz(1))
   error(' t must be have same size of h in dimeansion 1 !');
end

if         win == 1, 
        s = s.*repmat(taylorwin(sz(2),sln,sll)',sz(1),1); 
    elseif win == 2, 
        %h = h.*window(@tukeywin,length(h),0.5)';
        s = s.*repmat(hamming(sz(2))', sz(1),1);
    elseif win == 3 
        s = s.*repmat(kaiser(sz(2),pi)', sz(1),1);
    elseif win == 4
        s = s.*repmat(chebwin(sz(2),60)', sz(1),1);     
end

tt  = repmat(t', 1, padN);
ss  = zeros(padN*sz(1),sz(2));
ss(1:sz(1),1:sz(2))= s;

