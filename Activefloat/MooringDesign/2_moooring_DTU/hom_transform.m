function [T]=hom_transform(rot,trans)
%% function [T]=movingframe(angles,position)
% angles is a 1x3 vector containing roll, pitch and yaw angles in degrees
% position is 1x3 vector of moving frame relative to reference frame

% NOTE: this is not using Euler angles, but applying the roll,pitch and yaw
% rotations about the x, y and z axes respectively, and applying a
% translation. The theory may be found at:
% http://planning.cs.uiuc.edu/node104.html, Planning Algorithms by S.M.
% LaValle, CUP.
% Rotations are applied in the following order: roll about x-axis(D), pitch
% about y-axis(C) and yaw about z-axis(B). After this the translation is
% applied. This results in a 4x4 matrix:
%  __                                   __
% |Rotmatrix Rotmatrix Rotmatrix Transvect|
% |Rotmatrix Rotmatrix Rotmatrix Transvect|
% |Rotmatrix Rotmatrix Rotmatrix Transvect|
% |    0         0         0        1     |
% '--                                   --'
% ****Input(s)****
% rot      3 element vector containing the roll, pitch and yaw angles [radians]
% trans    3 element vector the translation vector in the fixed frame
%
% ****Output(s)****
% T           4x4 homogeneous transformation matrix (see above)
%
% Written by Michael Borg (m.borg@cranfield.ac.uk)
% Copyright & IP reserved. Not to be used without the express permission of
% the author.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%computing cosines and sines to speed up function

%cosine and sine values of alpha (yaw)
ca=cos(rot(3));sa=sin(rot(3));
%cosine and sine values of beta (pitch)
cb=cos(rot(2));sb=sin(rot(2));
%cosine and sine values of gamma (roll)
cg=cos(rot(1));sg=sin(rot(1));

%Rotation matrix about x-axis:
D=[1 0 0;0 cg -sg;0 sg cg];
%Rotation matrix about y-axis:
C=[cb 0 sb;0 1 0;-sb 0 cb];
%Rotation matrix about z-axis:
B=[ca -sa 0;sa ca 0;0 0 1];

%Homogeneous transformation matrix (see:
%http://planning.cs.uiuc.edu/node104.html)
T(1:3,1:3)=B*C*D;
T(1,4)=trans(1);
T(2,4)=trans(2);
T(3,4)=trans(3);
T(4,:)=[0 0 0 1];