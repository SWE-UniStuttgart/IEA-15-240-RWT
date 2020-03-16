%% Script that calculates the global forces in 6DOF from mooring system for an arbitrary platform displacement
function [Fmoor, Mmoor] = MooringSystemForceCalc(x1,w,L,nlines,rf,ra)

% Michael Borg (borg@dtu.dk)
% clear all;clc;

% w = 516.59*9.81 ;                                                               %Weight of mooring line in water [N/m]
% L = 610.0;                                                                      %Mooring line length [m]
% nlines=3;                                                                       %Number of mooring lines
% 
% rf=[-54.48                      0  8.7;                                         %Fairlead coordinates in each row [x y z]. Size = [nlines x 3]
%     54.48*cosd(60) -54.48*sind(60) 8.7;
%     54.48*cosd(60)  54.48*sind(60) 8.7];
% 
% ra=[-600.0 0 -180;                                                              %Anchor coordinates in each row [x y z]. Size = [nlines x 3]
%     600.0*cosd(60) -600.0*sind(60) -180;
%     600.0*cosd(60)  600.0*sind(60) -180];
% 
% 
w = 698.094;                                                                    %Weight of mooring line in water [N/m]
L = 902.20;                                                                     %Mooring line length [m]
nlines=3;                                                                       %Number of mooring lines

rf=[-44                      0 9.5;                                            %Fairlead coordinates in each row [x y z]. Size = [nlines x 3]
     5.2*cosd(60) -5.2*sind(60) 9.5;
     5.2*cosd(60)  5.2*sind(60) 9.5];

ra=[-853.87                         0 -320;                                     %Anchor coordinates in each row [x y z]. Size = [nlines x 3]
     853.87*cosd(60) -853.87*sind(60) -320;
     853.87*cosd(60)  853.87*sind(60) -320];


% x1=[0.5 0 0 0 0 0];       

[T]=hom_transform(x1(4:6),x1(1:3));
    for c2=1:nlines
        tmp1=T*[rf(c2, :) 1]';                                                   %Transform fairlead coordinates to displaced position
        rf_i(c2,1:3)=tmp1(1:3);                                                 %Store displaced coordinates
        h_i(c2)=abs(rf_i(c2,3)-ra(c2,3));                                       %Calculate new vertical distance between anchor and fairlead
        X_i(c2)=sqrt((rf_i(c2,2)-ra(c2,2))^2+(rf_i(c2,1)-ra(c2,1))^2);          %Calculate new horizontal distance between anchor and fairlead
        [Fx(c2),Fz(c2),~]=inelastic_catenary_line(h_i(c2),X_i(c2),L,w);         %Call catenary solver to obtain fairlead forces at displaced position
        uz_i(c2,1:3)=[Fx(c2) 0 -Fz(c2)]/sqrt(Fx(c2)^2+Fz(c2)^2);                 %Find unit direction vector of fairlead force in caternary line plane
        u_i(c2,1:2)=(ra(c2,1:2)-rf_i(c2,1:2))/norm(ra(c2,1:2)-rf_i(c2,1:2));    %Find unit direction vector in horizontal plane of catenary line 
        theta_i(c2)=atan2d(u_i(c2,2),u_i(c2,1));                                %Find angle of catenary line from global x axis (oriented such that theta=0deg in downwind direction)
        ca=cosd(theta_i(c2));sa=sind(theta_i(c2));
        ut_i(c2,1:3)=[([ca -sa;sa ca]*uz_i(c2,1:2)')' uz_i(c2,3)];              %Rotate x,y coordinates of fairlead force unit vector
        F_i(c2)=sqrt(Fx(c2)^2+Fz(c2)^2);                                        %Calculate fairlead force magnitude
        FVec_i(c2,1:3)=F_i(c2)*ut_i(c2,1:3);                                    %Calculate fairlead force vector
        MVec_i(c2,1:3)=cross(rf_i(c2,1:3),FVec_i(c2,1:3));
    end
Fmoor(1:3)=sum(FVec_i,1);                                                       %Sum up total mooring forces
Mmoor(1:3)=sum(MVec_i,1);                                                       %Sum up total mooring moments

end