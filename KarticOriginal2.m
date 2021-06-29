
h = 100;
w =150;

N = 100 ;

r = abs(1-(h-1).*rand(N,1) + 1)/2;
c = abs(1-(w-1).*rand(N,1) + 1)/2;

figure(1) 
scatter(r(:,1), c(:,1), 'o') ;

% m = (r+s)/2 ;
% w = abs(r-s) ;
% 
% R = [r,r] + [ -r.*rand(N,1), zeros(N,1) ] ;
% S = [s,s] + [ (1-s).*rand(N,1), zeros(N,1) ] ;
% 
% figure(1) 
% scatter(R(:,1), R(:,2), 'o') ;
% hold on
% scatter(S(:,1), S(:,2), '*') ;
% hold off
% % axis([0,1,0,1]) ;
% A = abs(R(:,1)-S(:,1)) .* abs(R(:,2)-S(:,2)) ;
% figure(2) 
% hist(A)
% 
% figure(3) 
% clf; 
% l = [min([R(:,1) S(:,1)], [], 2) min([R(:,2) S(:,2)], [], 2) ] ;
% w = abs(R(:,1) - S(:,1)) ;
% h = abs(R(:,2) - S(:,2)) ;
% 
% 
% for i=1:size(l,1)
% %     r(i) = rectangle('position', [l(i,:), w(i), h(i)], 'edgecolor', 'none', 'facecolor', [.6 .8543 .24]) ;  
%    v = [R(i,1), R(i,2); R(i,1), S(i,2); S(i,1), S(i,2); S(i,1), R(i,2)] ;
%    size(v)
%     p = patch('vertices', v, ...
%          'faces', [1, 2, 3, 4], ...
%          'edgecolor', 'none',...
%          'FaceColor', [.5 .4422, .34], ...
%          'FaceAlpha', 2/N) ;
%    hold on;
% end
% hold off