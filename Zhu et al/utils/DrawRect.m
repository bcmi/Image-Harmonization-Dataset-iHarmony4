function [im_out] = DrawRect(im,  roi, color, width)
% rect: y1, x1, y2, x2
color = uint8(color); 
if isempty(roi)
    roi = [1,1,size(im,1), size(im,2)];
end
y1 = roi(1); 
x1 = roi(2); 
y2 = roi(3); 
x2 = roi(4); 
im_out = im; 
im_out(y1:y1+width-1, x1:x2,:) = repmat(reshape(color, [1 1 3]), [width x2-x1+1]);  
im_out(y2-width+1:y2, x1:x2,:) = repmat(reshape(color, [1 1 3]), [width x2-x1+1]);  
im_out(y1:y2, x1:x1+width-1, :) = repmat(reshape(color, [1 1 3]), [y2-y1+1 width]); 
im_out(y1:y2, x2-width+1:x2, :) = repmat(reshape(color, [1 1 3]), [y2-y1+1 width]); 

end

