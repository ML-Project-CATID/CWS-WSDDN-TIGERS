function [output] = Classification_topNAccuracy(imdb,dets)

opts.imdbPath = fullfile(vl_rootnn, 'imdb-eb.mat');
opts.dets = fullfile(vl_rootnn, 'TestOutput','TestDets.mat');
pause('on');

fprintf('loading imdb...'); 
if exist(opts.imdbPath,'file')==2
  imdb = load(opts.imdbPath) ;
  display(opts.imdbPath);
else
    display('The dataset does not exist');
   % exit
end
fprintf('loading dets...');
if exist(opts.dets,'file')==2
  dets = load(opts.dets) ;
  display(opts.dets);
else
    display('The dataset does not exist');
   % exit
end

top1 = 0; 
top5 = 0;

images = imdb.images;
label = images.label;

names = dets.dets.names;
classes = imdb.classes.name;

ConfMatrix = zeros(numel(classes));

ConfMatrix5 = zeros(numel(classes)+1);

elem = length(names);

missClassified = [];
max_class =[];
classification = [];

for nelem = 1:elem
    name = names{1,nelem};
    boxes = dets.dets.boxes{1,nelem};
    scores = dets.dets.scores{1,nelem};

    idx = find(strcmp(images.name,name));   
    labelElem = label(:,idx);
    labelT = find(labelElem == 1);

    for j=1:numel(classes)
            max_class = cat(1,max_class,[j,max(scores(j,:))]);
    end
    M_class{nelem} = max_class;
        
    out=sortrows(max_class,2,'descend');
        
    position_wanted_class = find(out(:,1) == labelT);
    
    if position_wanted_class(1) == 1
        top1 = top1 + 1;
    
        labelP = out(1,1);        
        position_list{nelem} = position_wanted_class(1);


        ConfMatrix(labelP,labelT) = ConfMatrix(labelP,labelT) +1;
        if ~(labelT==labelP)
            missClassified= cat(1,missClassified,[nelem,{name},labelT,labelP]);
        end
    end
    if isempty(position_wanted_class)
        position_wanted_class(1) = 11;
    end
    
    if position_wanted_class(1) < 10
        top5 = top5 + 1;
    
        labelP = out(position_wanted_class(1),1);
        position_list{nelem} = position_wanted_class(1);
        ConfMatrix5(labelP,labelT) = ConfMatrix5(labelP,labelT) +1;
    else
        labelP = numel(classes)+1;
        ConfMatrix5(labelP,labelT) = ConfMatrix5(labelP,labelT) +1;
    end
    
    
    classification = cat(1,classification,[nelem,{name},labelT,labelP]);
end

output.classifications = classification;
output.position_wanted_lis = position_list;
output.top1 = top1;
output.ConfMatrix= ConfMatrix;
output.top5 = top5;
output.ConfMatrix5 = ConfMatrix5;
output.Missclassified = missClassified;



