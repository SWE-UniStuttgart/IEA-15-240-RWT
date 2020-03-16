clear all;

% parameter 
g = 9.81;  % gravitational acc
h = 188.7; % vertical diatance
X0 = 600-54.48; %  horizontal diatance
L = 610; % line length
w = 516.59 * g; % line weight per meter in water 

% variable
dX = -20:1:20; % horizontal displacement

Fx = zeros(length(dX),1);
Fz = zeros(length(dX),1);

%Call catenary solver to obtain fairlead forces at displaced position
for idX = 1:length(dX) 
[Fx(idX),Fz(idX),ls]=inelastic_catenary_line(h,X0+dX(idX),L,w);        
end

% plot
plot(X0+dX',Fx); xlabel('Horizontal Disp [m]'); ylabel('Singel line horizontal force [N]')