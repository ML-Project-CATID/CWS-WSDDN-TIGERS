function boxes = ExtractRandomBoxes_Area(box)
% areas are drawn from uniform random generator
N = 1000;

% areas are drawn from uniform random generator
A = rand(N,1) ;

% If squares, then the width and height will be the sqrt of the area
t = sqrt(A) ;

% factorize A = w.*h  to get width w and height h 
% small value for dw leads to more squarish rectangles
% e.g. dw=0 gives perfect squares
dw = t/5 ; 
w = min(t-dw + 2*dw.*rand(N,1),1) ; 
h = min(A./w,1) ;

% WARNING: It is possible to get rectangles that are outside [0,1]x[0,1] 
% maybe we need to reject those.

% randomly displace rectangle with given width and height
p = rand(N,1).*(1-w) ;
q = rand(N,1).*(1-h) ;

R1 = [p q] ;
S1 = R1 + [w h] ;

R = R1.*box(1);
S = S1.*box(2);

a = abs(R(:,1)-S(:,1)) .* abs(R(:,2)-S(:,2)) ;

boxes = [max(floor(R(:,1)),1),max(floor(R(:,2)),1),max(floor(S(:,1)),1),max(floor(S(:,2)),1)];
boxes = BoxRemoveDuplicates(boxes);
