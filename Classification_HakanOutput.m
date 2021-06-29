function [ConfMatrix,DC,MC] = Classification_HakanOutput(imdb,dets)

opts.imdbPath = fullfile(vl_rootnn, 'imdb-eb.mat');
opts.dets = fullfile(vl_rootnn, 'TestOutput', 'TestDets.mat');

fprintf('loading imdb...');
if exist(opts.imdbPath,'file')==2
  imdb = load(opts.imdbPath) ;
  display(opts.imdbPath);
else
    display('The dataset does not exist');
    %exit
end
fprintf('loading dets...');
if exist(opts.dets,'file')==2
  dets = load(opts.dets) ;
  display(opts.dets);
else
    display('The dataset does not exist');
    %exit
end

label = imdb.images.label;
names = dets.dets.names;
labelP = dets.dets.labelPred;
classes = imdb.classes.name;

ConfMatrix = zeros(numel(classes)+1);
elem = length(names);

m = 1;
MC = [];
for nelem = 1:elem
    name = names{1,nelem}
    labelPred = labelP(:,nelem);
    
    idx = find(strcmp(imdb.images.name,name));   
    labelElem = label(:,idx);
    
    labelT=find(labelElem==1);
    labelY = find(cell2mat(labelPred) == 1);
    if length(labelY)==0
        labelY = length(classes)+1;          
    end
    if length(labelY)>1
        DC{m} = [{name},find(labelT==1),[labelY]];
        m = m +1;
        labelY = length(classes)+1;       
    end
    if ~(labelT==labelY)
        MC= cat(1,MC,[{name},labelT,labelP]);
    end
    ConfMatrix(labelY,labelT) = ConfMatrix(labelY,labelT)+1;
end

if m==1
    DC{m} = [];
end
end
        
    
