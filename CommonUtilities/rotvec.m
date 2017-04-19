function new = rotvec(old, ax, ang)
%ROTVEC Vector Rotation
%   B = ROTVEC(A, AXIS, ANGLE) returns the vector A rotated about
%   the AXIS vector by ANGLE radians.

ax = ax(:)/norm(ax);
old = old(:);
w = 2*ax * tan(ang/2);

new = old + (cross(w,(old + cross(.5*w, old)))) / (1+w'*w/4);

return