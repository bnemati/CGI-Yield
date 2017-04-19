function Output = centroids(InputMatrix, indOption)
% Output = centroids(InputMatrix, indOption)
%
% Simple centroids for an (even x even) matrix of weights
% The Output is a 2-element vector containing the col (x) and row (y) 
% centroids:
%                 Output = [ccol, crow]
%
% indOption == 0 : origin is at the upper left corner of pixel (1,1)
% indOption == 1 : origin is at the central cross hairs of the matrix
% B. Nemati - 01-Dec-2009

[nr, nc] = size(InputMatrix);

if (mod(nr,2)~=0 || mod(nc,2)~=0)
    error ('Input matrix dimensions not even.')
end

if indOption == 1
    range_r = -(nr/2)+.5:1:+(nr/2)-.5; % correct for even npix!
    range_c = -(nc/2)+.5:1:+(nc/2)-.5;
    [colmids, rowmids] = meshgrid(range_c, range_r);
else % go from 1 to n assigning each element to the mid point 
    range_r = 0.5:1:nr-.5; 
    range_c = 0.5:1:nc-.5;
    [colmids, rowmids] = meshgrid(range_c, range_r);
end

sumweights = sum(sum(InputMatrix));
if sumweights ~= 0
    crow = sum(sum((InputMatrix .* rowmids))) / sum(sum(InputMatrix));
    ccol = sum(sum((InputMatrix .* colmids))) / sum(sum(InputMatrix));
else
    disp('Warning: centroids sum weights = 0 -> computing moments instead.')
    crow = sum(sum((InputMatrix .* rowmids))) ;
    ccol = sum(sum((InputMatrix .* colmids))) ;
end

Output = [ ccol, crow ];

return
