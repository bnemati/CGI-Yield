function y = rot_y (alpha)
% About y: + rotation is from x to z
y = [cos(alpha),0,-sin(alpha); 0,1,0; sin(alpha), 0, cos(alpha)];

return