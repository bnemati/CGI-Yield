function new = rotframe(old,x1,y1,z1)
%ROTFRAME Coordinate System Transformation
%   B = ROTFRAME(A, i, j, k) returns the vector A in the coordinate system
%   given by the unit vectors [i, j, k].


tmp = old;
old = old(:);
i_hat = unitvec(x1(:));
j_hat = unitvec(y1(:));
k_hat = unitvec(z1(:));

if norm(cross(i_hat, j_hat) - k_hat) > 1e-3
  warning(sprintf(['The vectors\n\t[' ...
		   num2str(i_hat') '], [' num2str(j_hat') '], and [' num2str(k_hat') ']\n' ...
		   'do not constitute a right-handed coordinate system']));
end

% assume i_prime, j_prime, k_prime are in reference system
i_prime = [1 0 0]';
j_prime = [0 1 0]';
k_prime = [0 0 1]';

new(1) = old(1) * dot(i_prime, i_hat) + ...
	 old(2) * dot(i_prime, j_hat) + ...
	 old(3) * dot(i_prime, k_hat);
new(2) = old(1) * dot(j_prime, i_hat) + ...
	 old(2) * dot(j_prime, j_hat) + ...
	 old(3) * dot(j_prime, k_hat);
new(3) = old(1) * dot(k_prime, i_hat) + ...
	 old(2) * dot(k_prime, j_hat) + ...
	 old(3) * dot(k_prime, k_hat);

new = reshape(new, size(tmp));

return