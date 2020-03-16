% Kommentar der als Help angezeigt wird!
%
function [x,z] = Coordinates(s,d,L_B,H_F,C_B,omega,EA,V_A)

% check for TD-Zone/Abfrage ob Leine aufliegt
if (d == 0) % TD-Zone/Leine liegt auf
    % x-Koordinaten/z-Koordinaten
    % Verschiedene Abschnitte des Seils: 
    % 1) ungestreckt am Boden (Kraft schon durch Reibung am Seeboden abgetragen)
    % 2) gestreckt am Boden
    % 3) Seil im Wasser
    if (s <= L_B-H_F/C_B/omega)
        x = s;
        z = 0;
    elseif (s <= L_B)
        x = s + ...
            C_B*omega/2/EA* ...
            (s^2-2*(L_B-H_F/C_B/omega)*s+(L_B-H_F/C_B/omega)*max(L_B-H_F/C_B/omega,0));
        z = 0;
    else
        x = L_B + ...
            H_F/omega*log(omega*(s-L_B)/H_F+sqrt(1+(omega*(s-L_B)/H_F)^2)) + ...
            H_F*s/EA + ...
            C_B*omega/2/EA*(-L_B^2+(L_B-H_F/C_B/omega)*max(L_B-H_F/C_B/omega,0));
        z= H_F/omega*(sqrt(1+(omega*(s-L_B)/H_F)^2)-1) + ...
            omega*(s-L_B)^2/2/EA;
    end %if

else % no TD-Zone/Leine liegt nicht auf
    % x-Koordinaten
    x = H_F/omega*(log((V_A+omega*s)/H_F+sqrt(1+((V_A+omega*s)/H_F)^2)) - ...
        log(V_A/H_F+sqrt(1+(V_A/H_F)^2))) + ...
        H_F*s/EA;
    % z-Koordinaten
    z = H_F/omega*(sqrt(1+((V_A+omega*s)/H_F)^2)-sqrt(1+(V_A/H_F)^2)) + ...
        1/EA*(V_A*s+omega*s^2/2);
    
end %if (d == 0)