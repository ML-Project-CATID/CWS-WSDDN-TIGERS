function inter_boxes = FindIntersections(listBoxes,box)
%Rita Pucci
%Given a list of boxes and a box [y1 x1 y2 x2] the function return all the
%boxes for listBoxes that intersect with the box.

box_reformat = [box(1,2),box(1,1),(box(1,4)-box(1,2)),(box(1,3)-box(1,1))];
inter_boxes = [];
for i=1:length(listBoxes)
    box_fL = [listBoxes(i,2),listBoxes(i,1),(listBoxes(i,4)-listBoxes(i,2)),(listBoxes(i,3)-listBoxes(i,1))];
    
    area = rectint(box_fL,box_reformat);
    if area > 0
        inter_boxes = cat(2,inter_boxes,i);
    end
end
end
