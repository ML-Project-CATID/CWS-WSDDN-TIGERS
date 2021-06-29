function boxes = ExtractRandomBoxes_Diagonal(box)

h = box(1);
w = box(2);
alpha = atan(h/w);

N = 1000 ;

c1 = 0.5*((w-1).*rand(N,1) + 1);
c2 =w/2+0.5*((w-1).*rand(N,1) + 1);
r1 = c1*tan(alpha);
r2 = c2*tan(alpha);

R = [c1,c2] + [ -c1.*rand(N,1), (-c2).*zeros(N,1) ] ;
S = [r1,r2] + [ (1-r1).*rand(N,1), (1-r2).*zeros(N,1) ] ;

A = abs(R(:,2)-R(:,1)) .* abs(S(:,2)-S(:,1));
idx = find(A<10000);
R(idx,:) = [];
S(idx,:) = [];
boxes = [floor(S(:,1)) floor(R(:,1)) floor(S(:,2)) floor(R(:,2))];
boxes = BoxRemoveDuplicates(boxes);
