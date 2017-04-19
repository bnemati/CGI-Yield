function y = rotator(u1,u2)
% Find the rotation matrix that turns unit vector u1 into unit vector u2
% This routine works consistently only with rot_x, rot_y, rot_z, 
% and the implied angle definitions therein.

% The cross product gives the axis for the rotation
v = cross(u1,u2);
% The dot product gives the amount of rotation
ang = acos(dot(u1,u2)) ;

% Approach:
% 1) Find T such that 
%    T v  = ku      where ku = unit vector along z
%    now consider u1 and u2 transformed the same way:   
%    T u1 = u1_t ;  T u2 = u2_t  
% 2) In this new coordinate system, find R such that:
%    R u1_t = u2_t  
%    now express this equation in terms of the original system
%    R T u1 = T u2 
% 3) The recipe for the rotator in the original system:
%   ~T R T u1 = u2 

% part 1 : transfer into an easy cood sys: where v = ku
thet = pi/2 - atan(v(3)/sqrt(v(1)^2+v(2)^2));
phi  = atan(v(2)/v(1));
% T is the transformation we seek: T*v = ku
% note that rot_y reduces the theta angle
T    = rot_y(thet)*rot_z(-phi);

% part 2: now find the transformation that rotates 
% about ku by angle ang : this is simply rot_z
R = rot_z(ang);

% part 3: the rotator is now given by:
y = T'*R*T;

return