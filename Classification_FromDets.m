function [classification,missClass,scoreT]=Classification_FromDets(imdb, dets,thr)

opts.imdbPath = fullfile(vl_rootnn, 'imdb-eb.mat');
opts.dets = fullfile(vl_rootnn, 'TestOutput', 'TestDets.mat');
pause('on');

fprintf('loading imdb...');
if exist(opts.imdbPath,'file')==2
  imdb = load(opts.imdbPath) ;
  display(opts.imdbPath);
else
    display('The dataset does not exist');
    %exit
end

classes = imdb.classes.name;

fprintf('loading dets...');
if exist(opts.dets,'file')==2
  dets = load(opts.dets) ;
  display(opts.dets);
else
    display('The dataset does not exist');
  %  exit
end

elem = length(dets.dets.names{1,1});
i=1;
classification = [];
for nelem = 1:elem
    names = dets.dets.names{1,1}{1,nelem};
    scoresP = dets.dets.scores{1,1}{1,nelem};
    idxName = find(strcmp(imdb.images.name,names));
    scoreT = imdb.images.label(:,idxName);
    cPvect = [];
    for cls = 1:4
        idx = (scoresP(cls,:)>thr);%prctile(scores(cls,:),70));
        if sum(idx)==0
            cPvect = cat(1,cPvect,-1);
        else
            cPvect = cat(1,cPvect,1);
        end
    end
    if ~isequal(cPvect,scoreT)
    missClass{i} = names;
    i = i+1;
    end
    classification = cat(2,classification,cPvect);
end
scoreT=imdb.images.label;
end


