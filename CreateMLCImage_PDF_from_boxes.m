function CreateMLCImage_PDF_from_boxes(var,thr)

opts.imdbPath = fullfile(vl_rootnn, 'data', var.imdbs, 'imdb-eb.mat');
opts.dets = fullfile(vl_rootnn, 'TestOutput/Dets', var.dets, 'TestDets.mat');
opts.classification = fullfile(vl_rootnn, 'TestOutput', var.classification, 'matlab.mat');
opts.imageCMSave = fullfile(vl_rootnn, 'TestOutput',var.output) 
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

images = imdb.images;
label = images.label;
classes = imdb.classes.name;
names = dets.dets.names;
boxesClass = classification.boxesClass;
labelPred = classification.predVec;

elem = length(names);

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


for nelem = 21:100

    name = names{1,nelem};
    idx = find(strcmp(images.name,name)); 
    boxes = dets.dets.boxes{1,nelem};
    scores = dets.dets.scores{1,nelem};
    listB = boxesClass{1,nelem};
    
    boxes_top = [];
    scores_top = [];
    
    for b= 1:length(listB)
        boxes_top = cat(1,boxes_top,boxes(cell2mat(listB(b,1)),:));
        scores_top = cat(2,scores_top,scores(:,cell2mat(listB(b,1))));
    end

    boxes = boxes_top;
    scores = scores_top;
    
    labelElem =label(:,idx);
    
    predLabel = cell2mat(labelPred(nelem));
    
    if position ==1
        f1 = figure('visible','off');
    end
    
    for cls = 1:numel(classes)-1
            if position == 1
                [ha pos] = tight_subplot(5,3,[.03 .03],[.1 .01],[.01 .01]);
            end
            
            axes(ha(position));
            position = position+1;    
            idxC = find(cell2mat(listB(:,2))==cls);             
            Mf=(max(scores(cls,idxC))-thr)/10;
            
            mean_CLS = sum(scores(cls,idxC))/length(idxC);
            
            im = fullfile('/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/data/India/Tiger/RandomSelectiveSearch',name);
            imshow(im); 
            if (predLabel(cls) == 1 && labelElem(cls) == 1), colorTitle = 'm';
            else
                if  (predLabel(cls) == 1), colorTitle  = 'b';
                else
                    if labelElem(cls) == 1, colorTitle = 'r';
                    else,colorTitle = 'k';
                    end
                end
            end  
            title([classes{cls},': mean value ',num2str(mean_CLS)],'Color', colorTitle, 'FontSize',5);
            
            % check if there are any boxes for this class
           
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
            
            SortSc = sort(scores(cls,idxC), 'descend' );
            SS = fliplr(SortSc(1,1:min(30,length(SortSc))));
            
      

            for iter=1:length(SS)
                idxSc = find(scores(cls,idxC)==SS(iter));
                for idx_sameSc=1:size(idxSc,1)
                    i = idxSc(idx_sameSc);
                    SS_v = [boxes(i,2), boxes(i,3); boxes(i,4), boxes(i,3); boxes(i,4), boxes(i,1); boxes(i,2), boxes(i,1)] ;
                    idxCLR=find(M>=min(scores(cls,i),1));
                    if isempty(idxCLR)
                        idxCLR = [11];
                    end
                    p = patch('vertices', SS_v, ...
                    'faces', [1, 2, 3, 4], ...
                    'edgecolor', custom_colormap(idxCLR(1),:),'LineWidth',1,'FaceColor', 'none');
                    axis off
                end
            end    
            colormap(custom_colormap) ; 
            caxis([0 thr+Mf*10]);
            c = colorbar();
            c.FontSize = 5;
% 
%             mkdir(fullfile(opts.imageCMSave,classes{cls}));
%             saveas(f1,fullfile(opts.imageCMSave,classes{cls},name));
            clearvars idxCLR SS_v idxSc
            pause(2);
    end
    if position == 16
        filename = ['test' num2str(nelem) '.pdf']
        set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')
        
        print(gcf,'-fillpage', '-dpdf', fullfile(opts.imageCMSave,filename));
        position = 1;
        %close(gcf);
    end
    clearvars boxes scores name idx listB
end

end
