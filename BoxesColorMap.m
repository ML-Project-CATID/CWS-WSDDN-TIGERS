function BoxesColorMap(imdb, dets,output,thr)

opts.imdbPath = fullfile(vl_rootnn, 'data', imdb, 'imdb-eb.mat');
opts.dets = fullfile(vl_rootnn, 'TestOutput', dets, 'TestDets.mat');
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

classes = imdb.classes.name;

fprintf('loading dets...');
if exist(opts.dets,'file')==2
  dets = load(opts.dets) ;
  display(opts.dets);
else
    display('The dataset does not exist');
    exit
end
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
elem = length(dets.dets.names{1,1});


for nelem = 1:elem
    names = dets.dets.names{1,1}{1,nelem}
    boxes = dets.dets.boxes{1,1}{1,nelem};
    scores = dets.dets.scores{1,1}{1,nelem};

    for cls = 1:numel(classes)
            idx = (scores(cls,:)>thr);%prctile(scores(cls,:),70));

            if sum(idx)==0, continue;end

            Mf=(max(scores(cls,:))-thr)/10;
            M =[0;
            0.05+Mf;
            0.05+Mf*2;
            0.05+Mf*3;
            0.05+Mf*4;
            0.05+Mf*5;
            0.05+Mf*6;
            0.05+Mf*7;
            0.05+Mf*8;
            0.05+Mf*9;
            0.05+Mf*11];
            im = fullfile('/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/data/India/Tiger/RandomSelectiveSearch',names);

            SortSc = sort(scores(cls,find(idx==1)), 'descend' );
            SS = fliplr(SortSc(1,1:min(20,length(SortSc))));

            f1 = figure('visible','off');
            clf;
            imshow(im);
            title([classes{cls},': max value ',num2str(0.05+Mf*10)]);
            for iter=1:length(SS)
                idxSc = find(scores(cls,:)==SS(iter));
                for idx_sameSc=1:size(idxSc,1)
                    i = idxSc(idx_sameSc);
                    SS_v = [boxes(i,2), boxes(i,3); boxes(i,4), boxes(i,3); boxes(i,4), boxes(i,1); boxes(i,2), boxes(i,1)] ;
                    idxCLR=find(M>=min(scores(cls,i),1));
                    
                    p = patch('vertices', SS_v, ...
                    'faces', [1, 2, 3, 4], ...
                    'edgecolor', custom_colormap(idxCLR(1),:),'LineWidth',2,'FaceColor', 'none');
                    hold on;
                end
                hold off
            end
            hold on      
            colormap(custom_colormap) ; 
            colorbar('Ticks',[]);

            mkdir(fullfile(opts.imageCMSave,cls));
            saveas(f1,fullfile(opts.imageCMSave,classes{cls},names));
            hold off
            clearvars f1 idxCLR SS_v idxSc
            pause(2);
    end
end
end
