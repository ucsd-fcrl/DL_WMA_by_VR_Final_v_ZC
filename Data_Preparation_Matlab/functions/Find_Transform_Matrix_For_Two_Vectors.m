function [rot,R,M] = Find_Transform_Matrix_For_Two_Vectors(v1,v2)
% this function finds the transformation matrix that can transform v1 to
% v2.

rot = vrrotvec(v1,v2);
R = vrrotvec2mat(rot);
M = [R(1,1) R(1,2) R(1,3) 0 ;R(2,1) R(2,2) R(2,3) 0;R(3,1) R(3,2) R(3,3) 0;0 0 0 1];


            