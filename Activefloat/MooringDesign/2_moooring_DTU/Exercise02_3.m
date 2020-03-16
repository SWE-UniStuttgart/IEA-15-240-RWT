% clear all; close all;

% initialize
Fmoor_l = zeros(3, 6);
Mmoor_l = zeros(3, 6);
Fmoor_r = zeros(3, 6);
Mmoor_r = zeros(3, 6);
cMoor = zeros(6);

w = 698.094;                                                                    %Weight of mooring line in water [N/m]
L = 902.20;                                                                     %Mooring line length [m]
nlines=3;                                                                       %Number of mooring lines

rf=[-5.2                      0 -70;                                            %Fairlead coordinates in each row [x y z]. Size = [nlines x 3]
     5.2*cosd(60) -5.2*sind(60) -70;
     5.2*cosd(60)  5.2*sind(60) -70];

ra=[-853.87                         0 -320;                                     %Anchor coordinates in each row [x y z]. Size = [nlines x 3]
     853.87*cosd(60) -853.87*sind(60) -320;
     853.87*cosd(60)  853.87*sind(60) -320];


x1=[0.5 0 0 0 0 0];   

% linearize in each DOF
for iDOF = 1:6 
    
    x1_l = zeros(1,6);
    x1_r = zeros(1,6);
    if iDOF <=3
    x1_r(iDOF)=0.05; % set translational dX to 0.1 [m]
    x1_l(iDOF)=-0.05; % set translational dX to -0.1 [m]
    else
    x1_r(iDOF)=0.1/180*pi;%deg2rad(0.1);  % set rotational dX positive 0.1 [deg]
    x1_l(iDOF)=-0.1/180*pi;  % set rotational dX negative -0.1 [deg]
    end

    [Fmoor_r(:,iDOF), Mmoor_r(:,iDOF)] = MooringSystemForceCalc(x1_r,w,L,nlines,rf,ra);
    [Fmoor_l(:,iDOF), Mmoor_l(:,iDOF)] = MooringSystemForceCalc(x1_l,w,L,nlines,rf,ra);

    cMoor(1:3, iDOF)=-(Fmoor_r(:,iDOF)-Fmoor_l(:,iDOF))/(x1_r(iDOF)-x1_l(iDOF));
    cMoor(4:6, iDOF)=-(Mmoor_r(:,iDOF)-Mmoor_l(:,iDOF))/(x1_r(iDOF)-x1_l(iDOF));
%         disp('--------------x----------------')
% 
%     disp(num2str(x1_r)); 
%         disp(num2str(x1_l));    
%     disp('--------------cMoor----------------')
% 
%     disp(num2str(Fmoor_r(:,iDOF)));
%     disp(num2str(Fmoor_l(:,iDOF)));
%     disp('-----------------------------------------------------------------------')

    
end


