function CreateMLCImage_PDF_from_array(var,thr)

%PDF
row = 5;
columns = 13;
max_pos = row*columns+1;
 
opts.imdbPath = fullfile(vl_rootnn,'data/IndiaImdbs', var.imdb, 'imdb-eb.mat');
opts.dets = fullfile( vl_rootnn,'TestOutput/Dets', var.dets, 'TestDets.mat');
opts.classification = fullfile( vl_rootnn,'TestOutput', var.classification, 'matlab.mat');
opts.imageCMSave = fullfile( vl_rootnn,'TestOutput',var.output) 
mkdir(opts.imageCMSave);
pause('on');
 
fprintf('loading imdb...');
if exist(opts.imdbPath,'file')==2
  imdb = load(opts.imdbPath) ;
  display(opts.imdbPath);
else
    display('The dataset does not exist');
    exit
end
fprintf('loading dets...');
if exist(opts.dets,'file')==2
  dets = load(opts.dets) ;
  display(opts.dets);
else
    display('The dataset does not exist');
    exit
end
fprintf('loading classification...');
if exist(opts.classification,'file')==2
  classification = load(opts.classification) ;
  display(opts.classification);
else
    display('The dataset does not exist');
    exit
end

MC = classification.missClassified;
images = imdb.images;
label = images.label;
pathImages = imdb.imageDir;
classes = imdb.classes.name;
names = dets.dets.names;
boxesClass = classification.boxesClass;
labelPred = classification.predVec;
elem = length(MC);

custom_colormap = [
0 0 1;
0 .2 1;
0 .4 1;
0 .6 1;
0 .8 1;
0 1 1;
.2 1 1;
.4 1 1;
.6 1 1;
.8 1 1;
.8 .8 .8;
]; 
position = 1;


for nelem = 1:elem

    name = MC{nelem,2};
    idx = find(strcmp(names,name));
    
    boxes = dets.dets.boxes{1,idx};
    scores = dets.dets.scores{1,idx};
    listB = boxesClass{1,find(strcmp(dets.dets.names,name))};
    
    boxes_top = [];
    scores_top = [];
    
    for b= 1:length(listB)
        boxes_top = cat(1,boxes_top,boxes(cell2mat(listB(b,1)),:));

        scores_top = cat(2,scores_top,scores(:,cell2mat(listB(b,1))));
    end

    boxes = boxes_top;
    scores = scores_top;
    
    labelElem = MC{nelem,3};
    
    predLabel = MC{nelem,4};
    
    if position ==1
        f1 = figure('visible','off');
    end
    
    for cls = 1:numel(classes)
         axes( 'Position', [0, 0.95, 1, 0.05] ) ;
         text( 0.5, 0, 'Predicted Class', 'FontSize', 10', 'FontWeight', 'Bold', ...
              'HorizontalAlignment','Center', 'VerticalAlignment', 'Bottom','Color', 'Red' ) ;
         text( 0, 0, 'GroundTruth Class', 'FontSize', 10', 'FontWeight', 'Bold', ...
              'HorizontalAlignment','Left', 'VerticalAlignment', 'Bottom','Color', 'Blue' ) ;
         
          axis off
            if position == 1
                [ha pos] = tight_subplot(row,columns,[.03 .03],[.01 .1],[.01 .01]);
            end
            axes(ha(position));
            position = position+1;    
            idxC = find(cell2mat(listB(:,2))==cls); 

            Mf=(max(scores(cls,:))-thr)/10;
            if isnan(Mf), Mf=0;end
            mean_CLS = sum(scores(cls,idxC))/length(idxC);
            if isnan(mean_CLS), mean_CLS = 0;end
            
            im = fullfile(pathImages,name);
            imshow(im); 
            if  (predLabel == cls)
                colorTitle  = 'r';
                title([erase(name,["00000",".jpg"])],'Color', colorTitle, 'FontSize',6);
            else
                if labelElem == cls, colorTitle = 'b';
                title([erase(name,["00000",".jpg"])],'Color', colorTitle, 'FontSize',6);
                end
            end
            %classes{cls},': mean:',num2str(mean_CLS),' max:',num2str(Mf)

            if isempty(idxC), continue, end

            
            M =[0;
            thr+Mf;
            thr+Mf*2;
            thr+Mf*3;
            thr+Mf*4;
            thr+Mf*5;
            thr+Mf*6;
            thr+Mf*7;
            thr+Mf*8;
            thr+Mf*9;
            thr+Mf*11];
            im = fullfile('/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/data/India/Tiger/RandomSelectiveSearch',name);

            SortSc = sort(scores(cls,:), 'descend' );
            SS = fliplr(SortSc(1,1:min(30,length(SortSc))));
                       
            for iter=1:length(SS)
                idxSc = find(scores(cls,:)==SS(iter));
                for idx_sameSc=1:size(idxSc,1)
                    i = idxSc(idx_sameSc);
                    SS_v = [boxes(i,2), boxes(i,3); boxes(i,4), boxes(i,3); boxes(i,4), boxes(i,1); boxes(i,2), boxes(i,1)] ;
                    idxCLR=find(M>=min(scores(cls,i),1));
                    
                    p = patch('vertices', SS_v, ...
                    'faces', [1, 2, 3, 4], ...
                    'edgecolor', custom_colormap(idxCLR(1),:),'LineWidth',1,'FaceColor', 'none');
                    axis off
                end
            end    
            colormap(custom_colormap) ; 
            caxis([0 thr+Mf*10]);
            c = colorbar();
            a =  c.Position; %gets the positon and size of the color bar
            set(c,'Position',[a(1)+0.01 a(2)-0.02 0.01 0.05]);
            c.FontSize = 5;
% 
%             mkdir(fullfile(opts.imageCMSave,classes{cls}));
%             saveas(f1,fullfile(opts.imageCMSave,classes{cls},name));
            clearvars idxCLR SS_v idxSc
            pause(2);
    end

  
    if position == max_pos
        filename = ['test' num2str(nelem) '.pdf']
        
        drawnow ;
        h=gcf;
        set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')
        set(h,'PaperOrientation','landscape');
        set(h,'PaperPosition', [1 1 28 19]);
        print(gcf,'-fillpage', fullfile(opts.imageCMSave,filename), '-dpdf');
        position = 1;
        close(gcf);
    end
    clearvars boxes scores name idx listB    
end

end
