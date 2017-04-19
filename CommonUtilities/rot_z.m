function y = rot_z (alpha)
%  About z: + rotation is from x to y
y = [cos(alpha),-sin(alpha),0; sin(alpha),cos(alpha),0;  0,0,1];

return