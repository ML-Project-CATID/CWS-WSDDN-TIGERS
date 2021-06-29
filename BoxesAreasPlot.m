function BoxesAreasPlot(scores,boxes,name,categories,classLabel,dataset)
output ='/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/data/Areas/IndTigerSmart';
mkdir(output);
colors = [0,255,255;255,0,255;0,0,255;255,255,0];
legend = makeLegend(colors);
display(name);
matrice = zeros(768,1024,3, 'uint8');
class = [0 0 0 0];
scores = cell2mat(scores);
boxs = cell2mat(boxes);

for i=1:length(boxs)
    
    a = scores(:,i);
    b = boxs(i,:);

    maxA = find(a==max(a));
    if a(1:maxA) > class(1:maxA)
        class(1:maxA) = a(1:maxA);
    end
    x1=b(1);
    x2=b(3);
    y1=b(2);
    y2=b(4);
    for x=x1:x2
        for y=y1:y2
            matrice(x,y,:) =  colors(maxA,:);
            
        end
    end

end

nameChr =name{1};
im = imread(fullfile(dataset,nameChr));
f1 = figure('visible', 'off');
subplot(2,2,1);image(im);title(nameChr,'FontSize', 10);
axis image
axis off
nameMatrix = sprintf('%s(%.4f,%.4f,%.4f,%.4f)',categories{(classLabel)}, ...
class(1,1),class(1,2),class(1,3),class(1,4));
subplot(2,2,3);image(matrice);title(nameMatrix,'FontSize', 10);
axis image
axis off
subplot(2,2,4);image(legend);title('Ind1 Ind2 Ind3 UnCl','FontSize', 10);
axis image
axis off
saveas(f1,fullfile(output,nameChr));
pause(5);
end
% for i = 1:length(names)
% name = names(i);
% dataset = '/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/data/India/Tiger/Smart';
% box = boxes(i);
% scor = score(i);
% plotAreas(scor,box,name,categories,dataset);
% end

function legend = makeLegend(colors)
legend = zeros(10,100,3, 'uint8');
for x=1:10
    for y=1:100
        if y <25
            m =1;
        else if y<50
                m=2;
            else if y <75
                    m=3;
                else 
                    m=4;
                end
            end
        end

        legend(x,y,:) =  colors(m,:);
    end
end

end
