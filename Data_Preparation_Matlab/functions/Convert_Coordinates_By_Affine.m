function [ans] = convert_coordinates(target_affine,initial_affine,v)
if length(v) == 2
    vv = [v';0;1];
else
    vv = [v';1];
end
ans = inv(target_affine) * initial_affine * vv;
ans = ans(1:3)';