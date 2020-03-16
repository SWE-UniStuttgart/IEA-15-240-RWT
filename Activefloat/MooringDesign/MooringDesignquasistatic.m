% Line Length
L = 614; %unstretched length [m]
LMassDen = 561.2520; %[kg/m]
EA = 2.3040e+09; %[N]
C_B = 0.6; %seabed static friction
SegmentDiameter = 0.16; %[m]
WaterDen=1025; %[m3/kg]
omega = (LMassDen-WaterDen*pi*SegmentDiameter^2/4)*9.80665; %massinwater [kg/m]        
% number of lines:
numberofLines = 3;

Segments=20;

fairleadpos = [-42.5,   0.0,    -15.0
            21.25,  -36.806,     -15.0
            21.25,  36.806,    -15.0];
%         scatter3(fairleadpos(:,1),fairleadpos(:,2),fairleadpos(:,3))
        % angle ga (Isys) of the lines (relating to y-axes):
fairleadang = [270,30,150]; ;
fairlead = [270,30,150]; % Winkel ga von y-Achse (Isys)

anchorpos = [-600.0,      0.0,        -200
             300,    -519.6152,   -200
             300,   519.6152,   -200];
        
         
         
         
%Intial excitation
markerpos = [10,0,0]; % x,y,z (in [m])
markerang = [0,0,0]; % al,be,ga (in °) Berechnungsabfolge: ga->be->al

for j=1:1:numberofLines
    % initial postion
    % leine j
    x_F(j) = sqrt(((markerpos(1)+fairleadpos(j,1))*...
        cos(markerang(2)*pi/180)*cos(markerang(3)*pi/180) - ...
        (markerpos(2)+fairleadpos(j,2))*sin(markerang(3)*pi/180) + ...
        (markerpos(3)+fairleadpos(j,3))*sin(markerang(2)*pi/180) - ...
        anchorpos(j,1))^2 + ...
        ((markerpos(2)+fairleadpos(j,2))*...
        cos(markerang(1)*pi/180)*cos(markerang(3)*pi/180) - ...
        (markerpos(3)+fairleadpos(j,3))*sin(markerang(1)*pi/180) + ...
        (markerpos(1)+fairleadpos(j,1))*sin(markerang(3)*pi/180) - ...
        anchorpos(j,2))^2);
    z_F(j) = abs( ...
        (markerpos(3)+fairleadpos(j,3))*...
        cos(markerang(1)*pi/180)*cos(markerang(2)*pi/180) + ...
        (markerpos(2)+fairleadpos(j,2))*sin(markerang(1)*pi/180) - ...
        (markerpos(1)+fairleadpos(j,1))*sin(markerang(2)*pi/180) - ...
        anchorpos(j,3) );
    % Calculation of the starting values/Berechnen der Anfangswerte
    % (Theorie: Jonkman PhD S.40)
    if (x_F(j) == 0)
        lambda = 1000000;
    elseif (sqrt(x_F(j)^2 + z_F(j)^2) >= L)
        lambda = 0.2;
    else
        lambda = sqrt(3*((L^2 - z_F(j)^2)/x_F(j)^2 - 1));
    end
    V_F0 = omega/2*(z_F(j)/tanh(lambda) + L);
    H_F0 = abs(omega*x_F(j)/2/lambda);
    
    % vector of starting values for iteration:
    K0 = [ V_F0; H_F0];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % call function with seabed interaction
    f = @(K)MooringTensionSeabed(K, L, omega, EA, x_F(j), z_F(j), C_B);
    options=optimset('Display','iter');   % Option to display output
    [K,fval,exitflag] = fsolve(f,K0,options);  % Call optimizer
    V_F = K(1);
    H_F = K(2);
    % L_B = the touch down length
    L_B = L - K(1)/omega;
    V_A = 0;
    H_A = max(H_F-C_B*omega*L_B,0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % check for existence of TD-Zone (Touchdown-Zone)
    if (L_B <= 0 || exitflag ~= 1)
        % Line doesnt lie on the ground
        d = 1;
        % Recalculate with no contact to the ground
        f = @(K)MooringTension(K, L, omega, EA, x_F(j), z_F(j));
        options=optimset('Display','iter');   % Option to display output
        [K,fval] = fsolve(f,K0,options);  % Call optimizer
        V_F = K(1);
        H_F = K(2);
        % Anchor forces
        H_A = H_F;
        V_A = V_F - omega*L;
        disp('line has no Touchdown-Zone/Leine liegt nicht auf.');
    else
        % Line has a touch down part
        d = 0;
    end
    % Show values
    AusgabeVF = ['V_F_Leine',num2str(j),' = ',num2str(V_F)];
    AusgabeHF = ['H_F_Leine',num2str(j),' = ',num2str(H_F)];
    disp(AusgabeVF);
    disp(AusgabeHF);
    for i=1:1:Segments
       % calc. of arc coordinates/Berechnen der Bogenkoordinate s
         s(i,j) = i*L/Segments;
         [x(i,j),z(i,j)] = Coordinates(s(i,j),d,L_B,H_F,C_B,omega,EA,V_A);
    end %for
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % for schleife über j Leinen
plot(x,z)
xlabel('x-Koordinate')
ylabel('z-Koordinate')
title('Leinenformen')
