function CreateMLCImage_PDF_MImage(imdb, dets,output,thr)

opts.imdbPath = fullfile(vl_rootnn, 'data', imdb, 'imdb-eb.mat');
opts.dets = fullfile(vl_rootnn, 'TestOutput/Dets', dets, 'TestDets.mat');
opts.imageCMSave = fullfile(vl_rootnn, 'TestOutput',output) 
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


images = imdb.images;
label = images.label;
labelPred = cell2mat(dets.dets.labelPred);
names = dets.dets.names;
classes = imdb.classes.name;

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


for nelem = 1:elem

    name = names{1,nelem};
    boxes = dets.dets.boxes{1,nelem};
    scores = dets.dets.scores{1,nelem};

    idx = find(strcmp(images.name,name));
    
    labelElem = label(:,idx);

    predLabel = labelPred(:,nelem);
    
    if position ==1
        f1 = figure('visible','off');
    end
    
    for cls = 1:numel(classes)-1
            %idx = (scores(cls,:)>thr);%prctile(scores(cls,:),70));

           % if sum(idx)==0, continue;end

            Mf=(max(scores(cls,:))-thr)/10;
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
            SS = fliplr(SortSc(1,1:min(20,length(SortSc))));
            
            if predLabel(cls) == 1 && labelElem(cls) == 1
                colorTitle = 'm';
            else
                if predLabel(cls) == 1 && labelElem(cls)==-1
                    colorTitle  = 'b';
                else
                    if predLabel(cls) == -1 && labelElem(cls)==1
                        colorTitle = 'r';
                    else 
                        colorTitle = 'k';
                    end
                end
            end        
            
            if position == 1
                [ha pos] = tight_subplot(5,3,[.03 .02],[.1 .01],[.01 .01]);
            end
            
            axes(ha(position));
            position = position+1;            
            
            imshow(im);
            title([classes{cls},': max value ',num2str(0.05+Mf*10)],'Color', colorTitle, 'FontSize',5);
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
            caxis([0 0.05+Mf*10]);
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
    
end

end
