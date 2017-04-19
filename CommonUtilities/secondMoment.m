function Output = secondMoment(InputMatrix, option)
%        Output = secondMoment(InputMatrix, option)
%
% Compute the second moment of the weights given by InputMatrix about
% either the center of the matrix (option=0) or the centroid of the weights
% (option =1). The latter is called the central moment.
% (In mechanics, the second moment corresponds to the moment of inertia.)  
% The input matrix is converted to double precision if it is not already so.
% The Output is a 2-element vector containing the col (x) and row (y) 
% second moments:
%                 Output = [smcol, smrow]
%
% B. Nemati -- 16-Nov-2009

if ~double(InputMatrix)
    InputMatrix = double(InputMatrix);
end
[nr, nc] = size(InputMatrix);
if (nr ~= nc || mod(nr,2) ~= 0) 
    error('InputMatrix must be square and even dimensioned')
end
if ~(option == 0 || option == 1) 
    error('secondMoment called with an invalid option value');
end

sumweights = sum(sum(InputMatrix));
if sumweights ~= 0
    
    % create a coordinate system based on the center of each pixel
    range_r = -(nr/2)+.5:1:+(nr/2)-.5;
    range_c = -(nc/2)+.5:1:+(nc/2)-.5;
    [colmids, rowmids] = meshgrid(range_c, range_r);
    
    if option == 1     % option 1 is the central moment
        % compute the centroid for option 1
        cr = sum(sum((InputMatrix .* rowmids))) / sum(sum(InputMatrix));
        cc = sum(sum((InputMatrix .* colmids))) / sum(sum(InputMatrix));
    else               % option==0 moment about the central cross hair
        cr = 0; cc = 0;
    end

    smrow = sum(sum((InputMatrix .* ((rowmids-cr).^2)))) / sumweights;
    smcol = sum(sum((InputMatrix .* ((colmids-cc).^2)))) / sumweights;
else
    error('Error: centroids sum weights = 0 ')
end

Output = [smcol, smrow];

% disp(['[smcol, smrow] = ', num2str(Output)]);

return
