% addpath(genpath('..\DTU_SummerSchool'))

% close all; clear all
function [rAnchor, L_moor, fMoor0, mMoor0, cMoor0]  = solveStaticMooring(dCol, dPtfm)

%% variable
% dCol  = 0.09;             % diameter of columns [m]
% dPtfm = 0.5;              % distance of columns [m]

rFairlead = dPtfm+dCol;   % radius of fairleads [m]

%% parameter
g = 9.81;                 % gravitational acceleration
w = 0.008*g;              % Weight of mooring line in water [N/m]
nlines=3;                 % Number of mooring lines
depth = 0.63;             % water depth [m]
zAnchor = -depth;         % vertical achor attachment
zFairlead = 0.0;          % vertical Fairlead attachment
F_wind    = 0.098;        % thrust force at rated wind

%% configuration of moorings 
rAnchor = (zFairlead-zAnchor)*3;                      % radius of anchor
Lmin = sqrt((rAnchor-rFairlead)^2+(zFairlead-zAnchor)^2);
Lmax = (rAnchor-rFairlead)+(zFairlead-zAnchor);
L0 = (Lmin+0.1*(Lmax-Lmin)):0.01:(Lmax-0.5*(Lmax-Lmin));  % need to played around, too lang or too short

for iL = 1:length(L0)
    
    L = L0(iL);
    %calc anchor & fairleads position
    
    rf=[ rFairlead                      0        zFairlead;           % Fairlead coordinates in each row [x y z]. Size = [nlines x 3]
        -rFairlead*cosd(60) -rFairlead*sind(60) zFairlead;
        -rFairlead*cosd(60)  rFairlead*sind(60) zFairlead];
    
    ra=[ rAnchor                          0        -depth;            % Anchor coordinates in each row [x y z]. Size = [nlines x 3]
        -rAnchor*cosd(60)  -rAnchor*sind(60)      -depth;
        -rAnchor*cosd(60)   rAnchor*sind(60)      -depth];
    
    %% calculate mooring forces
    dspSurge = 0:0.001:0.08; % displacement in surge
    for iSurge = 1:length(dspSurge)
        x1 = [dspSurge(iSurge), 0, 0, 0, 0, 0];
        [Fmoor(:,iSurge,iL), Mmoor(:,iSurge,iL)] = MooringSystemForceCalc(x1,w,L,nlines,rf,ra);
    end
    
    %% plot
    if iL<10
        figure(1)
        subplot(3,3,iL)
        plot(dspSurge*200,-Fmoor(1,:,iL),[0 dspSurge(end)*200],[F_wind F_wind]);hold on;
        xlabel('xSurge [m/200]'); ylabel('Force H [N]');title(['line length',num2str(L)]);% xSurge is ploted in full scaled
        
        figure(2)
        subplot(3,3,iL)
        plot(dspSurge*200,-Fmoor(3,:,iL));hold on;
        xlabel('xsurge [m/200]'); ylabel('Force V [N]');title(['line length',num2str(L)]);
    end

         try % calc surge displacement at rated wind speed, if solver starts to return NaN, assume dspSurgeRated increases linear
            dspSurgeRated(iL) = interp1(-Fmoor(1,:,iL),dspSurge,F_wind,'linear','extrap');
         catch
            dspSurgeRated(iL)= dspSurgeRated(iL-1)*2-dspSurgeRated(iL-2);
         end
    
end

%% select mooring line length & calc force, stifness
L_moor = interp1(dspSurgeRated, L0, 15/200,'linear','extrap');
figure(3)
plot(L0, dspSurgeRated*200); xlabel('mooring line length [m]'); ylabel('surge displacement at rated wind speed [m/200]')

% calc mooring force at surge 0
[fMoor0,  mMoor0] = MooringSystemForceCalc([0,0,0,0,0,0],w,L_moor,nlines,rf,ra);

% calc stiffness at surge 0
cMoor = zeros(6);
[fMoor0l_surge,  mMoor0l_surge] = MooringSystemForceCalc([-0.1/200,0,0,0,0,0],w,L_moor,nlines,rf,ra);
[fMoor0r_surge,  mMoor0r_surge] = MooringSystemForceCalc([0.1/200,0,0,0,0,0],w,L_moor,nlines,rf,ra);
cMoor0(1:3,1) = (fMoor0l_surge-fMoor0r_surge)/(0.2/200); cMoor0(4:6,1) = (mMoor0l_surge-mMoor0r_surge)/(0.2/200);

[fMoor0l_heave,  mMoor0l_heave] = MooringSystemForceCalc([0,0,-0.1/200,0,0,0],w,L_moor,nlines,rf,ra);
[fMoor0r_heave,  mMoor0r_heave] = MooringSystemForceCalc([0,0,0.1/200,0,0,0],w,L_moor,nlines,rf,ra);
cMoor0(1:3,3) = (fMoor0l_heave-fMoor0r_heave)/(0.2/200); cMoor0(4:6,3) = (mMoor0l_heave-mMoor0r_heave)/(0.2/200);

[fMoor0l_pitch,  mMoor0l_pitch] = MooringSystemForceCalc([0,0,0,0,-deg2rad(0.1),0],w,L_moor,nlines,rf,ra);
[fMoor0r_pitch,  mMoor0r_pitch] = MooringSystemForceCalc([0,0,0,0,deg2rad(0.1),0],w,L_moor,nlines,rf,ra);
cMoor0(1:3,5) = (fMoor0l_pitch-fMoor0r_pitch)/(0.2/200); cMoor0(4:6,5) = (mMoor0l_pitch-mMoor0r_pitch)/(0.2/200);

end

% %% solve single line
%
% h = zFairlead-zAnchor; % vertical diatance
% X0 = rAnchor-rFairlead; %  horizontal diatance
%
% L0 = 1.6:0.02:1.8; % line length
% % variable
% dX = -0.05:0.005:0.09; % horizontal displacement
%
% Fx = zeros(length(dX),1);
% Fz = zeros(length(dX),1);
%
%
% for iL = 1:length(L0)
%     L = L0(iL);
%     %Call catenary solver to obtain fairlead forces at displaced position
%     for idX = 1:length(dX)
%         [Fx(idX,iL),Fz(idX),~]=inelastic_catenary_line(h,X0+dX(idX),L,w);
%     end
%
%     % plot
%     plot(X0+dX',Fx(:,iL)); xlabel('Horizontal Disp [m]'); ylabel('Singel line horizontal force [N]'); hold on;
%
% end


