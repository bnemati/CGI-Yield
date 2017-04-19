function y = unitvec(a,b)
%UNITVEC Calculate a unit vector
%   UNITVEC(A,B) returns a unit vector. With one input argument, that
%   argument is assumed to be a vector, and the unit vector along A is
%   returned. With two arguments, the first is assumed to be theta and the
%   second to be phi in a spherical coordinate system, where theta
%   is the ounterclockwise angle in the xy plane measured from the
%   positive x axis and phi is the elevation angle from the xy plane.  

if(nargin==1)
  if (length(a) < 2 | all(size(a) > 1))
    error('With one argument, the first must be a vector.');
  end
  if norm(a) == 0
    y = a;
  else
    y = a/norm(a);
  end
elseif(nargin==2)
  y = [sin(b)*cos(a) sin(b)*sin(a) cos(b)]';
else
  error('No more than two arguments are allowed.');
end

return
