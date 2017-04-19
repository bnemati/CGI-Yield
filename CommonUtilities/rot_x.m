function y = rot_x (alpha)
% About x: + rotation is from y to z

y = [1,0,0; 0,cos(alpha),-sin(alpha); 0,sin(alpha),cos(alpha)];
return