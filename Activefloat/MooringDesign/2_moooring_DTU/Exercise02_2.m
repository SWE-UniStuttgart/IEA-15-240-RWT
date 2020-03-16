
clc; clear all; close all;

%% variable
dSurge = -10:1:10;
dHeave = -5:1:5;
dPitch = -5:1:5;
dYaw = -10:1:10;

%% Dsp in Surge

Fmoor_dSurge = zeros(3, length(dSurge));
Mmoor_dSurge = zeros(3, length(dSurge));

for iSurge = 1:length(dSurge)
    x1 = [dSurge(iSurge), 0, 0, 0, 0, 0];
    [Fmoor_dSurge(:,iSurge), Mmoor_dSurge(:,iSurge)] = MooringSystemForceCalc(x1);
end

figure('name','DspSurge')
subplot(1,3,1)
plot(dSurge,Fmoor_dSurge(1,:));
xlabel('SurgeDsp [m]'); ylabel('fSurge [N]')
subplot(1,3,2)
plot(dSurge,Fmoor_dSurge(3,:));
xlabel('SurgeDsp [m]'); ylabel('fHeave [N]')
subplot(1,3,3)
plot(dSurge,Mmoor_dSurge(2,:));
xlabel('SurgeDsp [m]'); ylabel('mPitch [Nm]')


%% Dsp in heave

Fmoor_dHeave = zeros(3, length(dHeave));
Mmoor_dHeave = zeros(3, length(dHeave));

for iHeave = 1:length(dHeave)
    x1 = [0, 0, dHeave(iHeave), 0, 0, 0];
    [Fmoor_dHeave(:,iHeave), Mmoor_dHeave(:,iHeave)] = MooringSystemForceCalc(x1);
end

figure('name','DspHeave')
plot(dHeave,Fmoor_dHeave(1,:));hold on;
plot(dHeave,Fmoor_dHeave(3,:));
plot(dHeave,Mmoor_dHeave(2,:));
legend('fSurge','fHeave','mPitch')
xlabel('HeaveDsp [m]'); ylabel('force [N], moment [kNm]')
ylim([-8e6 1e5])


%% Dsp in pitch

Fmoor_dPitch = zeros(3, length(dPitch));
Mmoor_dPitch = zeros(3, length(dPitch));

for iPitch = 1:length(dPitch)
    x1 = [0, 0, 0, 0, deg2rad(dPitch(iPitch)), 0];
    [Fmoor_dPitch(:,iPitch), Mmoor_dPitch(:,iPitch)] = MooringSystemForceCalc(x1);
end

figure('name','DspPitch')
plot(dPitch,Fmoor_dPitch(1,:));hold on;
plot(dPitch,Fmoor_dPitch(3,:));
plot(dPitch,Mmoor_dPitch(2,:));
legend('fSurge','fHeave','mPitch')
xlabel('PitchDsp [deg]'); ylabel('force [N], moment [kNm]')
% ylim([-8e6 1e5])


%% Dsp in yaw

Fmoor_dYaw = zeros(3, length(dYaw));
Mmoor_dYaw = zeros(3, length(dYaw));

for iYaw = 1:length(dYaw)
    x1 = [0, 0, 0, 0, 0, deg2rad(dYaw(iYaw))];
    [Fmoor_dYaw(:,iYaw), Mmoor_dYaw(:,iYaw)] = MooringSystemForceCalc(x1);
end

figure('name','DspYaw')
plot(dYaw,Fmoor_dYaw(1,:));hold on;
plot(dYaw,Fmoor_dYaw(3,:));
plot(dYaw,Mmoor_dYaw(2,:));
legend('fSurge','fHeave','mPitch')
xlabel('YawDsp [deg]'); ylabel('force [N], moment [kNm]')