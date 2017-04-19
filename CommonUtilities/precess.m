function y = precess (N, del, uvec )
% precess: give N unit vectors making angle _del_ in a cone about _uvec_  
% precess(N, del, uvec)

iu=[1;0;0];
y=zeros(3,1);
thet = pi/2 - atan(uvec(3)/sqrt(uvec(1)^2+uvec(2)^2));
phi  = atan(uvec(2)/uvec(1));

uvec_tr = rot_y(thet)*rot_z(-phi)*uvec;

for n = 1 : N
   duvec = rot_z(2*pi*n/N)*iu*tan(del);
   uu = uvec_tr+duvec;
   upert = uu / norm(uu) ;
   y=[y , (rot_z(phi)*rot_y(-thet)*upert) ];
end
y=y(:,2:end);
return