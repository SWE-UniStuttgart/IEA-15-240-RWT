function F = MooringTension(x, L, omega, EA, x_F, z_F)
% Bestimmt die am Fairlead angreifende Vertikal- (V_F) und 
% Horizontalkraft (H_F)
% V_F == x(1); H_F == x(2)
% L == total unstretched length; omega == weight in fluid per unit length
% EA == extensional stiffness; C_B == coefficient of seabed static friction
%
% Theorie siehe Jonkman PhD S.35ff
%
F = [x(2)/omega*( log(x(1)/x(2) + sqrt(1 + (x(1)/x(2))^2)) - log((x(1)-omega*L)/x(2) + sqrt(1 + ((x(1)-omega*L)/x(2))^2))) + x(2)*L/EA - x_F;
     x(2)/omega*(sqrt(1+(x(1)/x(2))^2) - sqrt(1+((x(1)-omega*L)/x(2))^2)) + 1/EA*(x(1)*L - omega*L^2/2) - z_F];