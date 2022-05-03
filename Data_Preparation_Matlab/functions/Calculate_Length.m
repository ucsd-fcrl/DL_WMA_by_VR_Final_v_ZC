function [ans] = Calculate_Length(p1,p2)

ans = sqrt(sum((p1- p2).^2));