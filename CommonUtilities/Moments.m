function Output = Moments(InputMatrix, option)
%        Output = Moments(InputMatrix, option)
%
% Compute the first and seond moments. 
% First moment is centroids and is always rel. to central crosshairs.
% The second moment of the weights given by InputMatrix are calculated about
% either the center of the matrix (option=0) or the centroid of the weights
% (option =1). The latter is called the central moment.
% (In mechanics, the second moment corresponds to the moment of inertia.)  
% The input matrix is converted to double precision if it is not already so.
% The Output is a struct containing the col (x) and row (y) 0, 1, 2nd
% moments
%
% B. Nemati -- 18-Mar-2010

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

sumWeights = sum(sum(InputMatrix));
if sumWeights ~= 0
    
    % create a coordinate system based on the center of each pixel
    range_r = -(nr/2)+.5:1:+(nr/2)-.5;
    range_c = -(nc/2)+.5:1:+(nc/2)-.5;
    [colmids, rowmids] = meshgrid(range_c, range_r);
    
    centroidr = sum(sum((InputMatrix .* rowmids))) / sum(sum(InputMatrix));
    centroidc = sum(sum((InputMatrix .* colmids))) / sum(sum(InputMatrix));
        
    if option == 1     % option 1 is the central moment
        % compute the centroid for option 1
        cr = centroidr;
        cc = centroidc;
    else               % option==0 moment about the central cross hair
        cr = 0; cc = 0;
    end

    smrow = sum(sum((InputMatrix .* ((rowmids-cr).^2)))) / sumWeights;
    smcol = sum(sum((InputMatrix .* ((colmids-cc).^2)))) / sumWeights;
else
    error('Error: centroids sum weights = 0 ')
end

Output.sumWeights = sumWeights;
Output.rowCentroid = centroidr;
Output.colCentroid = centroidc;
Output.rowSecondMom = smrow;
Output.colSecondMom = smcol;

return
