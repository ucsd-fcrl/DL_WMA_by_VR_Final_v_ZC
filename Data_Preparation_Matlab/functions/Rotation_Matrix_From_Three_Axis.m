function [R,M] = Rotation_Matrix_From_Three_Axis(rot_x,rot_y,rot_z,degree)
% this script sets the rotation matrix R and M given the rotation angle in
% three axes

if degree == 1
rot_x = rot_x / 180 * pi;
rot_y = rot_y / 180 * pi;
rot_z = rot_z / 180 * pi;
end

R_x = [1 0 0;0 cos(rot_x) -sin(rot_x);0 sin(rot_x) cos(rot_x)];
R_y = [cos(rot_y)  0 sin(rot_y); 0 1 0 ;-sin(rot_y) 0 cos(rot_y)];
R_z = [cos(rot_z) -sin(rot_z) 0;sin(rot_z) cos(rot_z) 0;0 0 1];

R = R_x * R_y * R_z;
M = [R(1,1) R(1,2) R(1,3) 0; R(2,1) R(2,2) R(2,3) 0; R(3,1) R(3,2) R(3,3) 0;0 0 0 1];