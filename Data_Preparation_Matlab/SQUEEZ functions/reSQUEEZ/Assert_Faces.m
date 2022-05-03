function [assert,wrong_faces] = Assert_Faces(face,vertices)

assert = 1;
wrong_faces = [];
for ii = 1:size(face,1)
    F = face(ii,:);
    p1 = vertices(F(1),:);
    p2 = vertices(F(2),:);
    p3 = vertices(F(3),:);
    
    diff12 = abs(p2-p1);
    diff13 = abs(p3-p1);
    diff23 = abs(p3-p2);
    
    
    assert12 = diff12 < 2;
    assert13 = diff13 < 2;
    assert23 = diff23 < 2;
    
    if (all(assert12) == 0) || (all(assert13) == 0) || (all(assert23) == 0)
        disp([num2str(ii),' fail'])
        assert = 0;
        wrong_faces = [wrong_faces ii];
    end
end