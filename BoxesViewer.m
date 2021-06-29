dataset = '/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/data/IndiaImdbs/';
DB_file = 'imdb-eb.mat';
% folder = 'IndTiger';
% folder = 'Extrema&SelectiveSearch';
% folder = 'Extrema&RandomSearch';
 folder = 'RandomInd';
% folder = 'RandomInd_2';
pause('on');
imdb = load(fullfile(dataset,folder, DB_file));

output = '/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/data/Areas';

SS_output = fullfile(output,folder,'View_Boxes');
mkdir(SS_output);
N = size(imdb.images.name,2);
position = 1;
for idx = 1:390
        
    SS_boxes = imdb.images.boxes{idx};
    filename = imdb.images.name{idx};
    
    if position == 1
        f1 = figure('visible', 'off'); 
        clf; 
    end
    if position == 1
        [ha pos] = tight_subplot(5,3,[.03 .02],[.1 .01],[.01 .01]);
    end
    
    axes(ha(position));

    position = position + 1;       
    
    im = imread (fullfile(imdb.imageDir,filename));
    imshow(im);
    title(filename,'FontSize',5);
    for i=1:size(SS_boxes,1)
       SS_v = [SS_boxes(i,2), SS_boxes(i,3); SS_boxes(i,4), SS_boxes(i,3); SS_boxes(i,4), SS_boxes(i,1); SS_boxes(i,2), SS_boxes(i,1)] ;
        p = patch('vertices', SS_v, ...
             'faces', [1, 2, 3, 4], ...
             'edgecolor',[.5 .622, .34],...
             'FaceColor', [.5 .622, .34], ...
             'FaceAlpha', 2.5/size(SS_boxes,1)) ;
       hold on;
       clearvars SS_v 
    end
    hold off
    if position == 16
        printname = ['test' num2str(idx) '.pdf']
        set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')
        
        print(gcf,'-fillpage', '-dpdf', fullfile(SS_output,printname));
        clearvars f1
        position = 1;
    end
    pause(2);
    clearvars SS_boxes 
end