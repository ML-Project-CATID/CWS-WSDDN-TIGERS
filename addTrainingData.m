function [images] = addTrainingData(opts_add)

% opts.pathStructureFolder 'data/IndiaImdbs'
% opts.dataset 'RandomInd_MaskedData'
% opts.imdb_eb pathStructureFolder+dataset+'imdb-eb.mat'
% opts.newTraining
% '/media/rpucci/Data/Results_TEST/12_individuals_bal/MaskedImages/10x10_sf0.5/EI_AL'

BAL = 1;
area = 0;
minElem = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------CHANGE NAMES FOR DIFFERENT DATASET ----------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataset = 'RandomInd_Lep_m100_mask';
pathDataset = '/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/data/India/Lepards/IndLep_m100_mask';
expFilename = '11.RandomInd_Lep_m100_mask';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~7==exist(pathDataset,'dir')
    mkdir(pathDataset);
    disp(strcat('Dataset created in',pathDataset));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pathStructureFolder = fullfile(vl_rootnn,'data/IndiaImdbs',dataset);
if ~7==exist(pathStructureFolder,'dir')
    mkdir(pathStructureFolder);
    disp(strcat('IndiaImdbs created in',pathStructureFolder));
end

%1 load imdb.mat
opts_add.imdb_eb = fullfile(opts_add.pathStructureFolder,opts_add.dataset,'imdb-eb.mat');
fprintf('loading imdb-eb.mat...');
if exist(opts_add.imdb_eb,'file')==2
  imdb_eb = load(opts_add.imdb_eb) ;
  display(opts_add.imdb_eb);
else
    display('The dataset does not exist');
    exit
end

DB = length(imdb_eb.images.id);

%2 load EdgeBoxesIndiaTest.mat and EdgeBoxesIndiaTraining.mat
opts_add.opts_eb = fullfile(opts_add.pathStructureFolder,opts_add.dataset,'opts.mat');
fprintf('loading imdb-eb.mat...');
if exist(opts_add.opts_eb,'file')==2
  opts_eb = load(opts_add.opts_eb) ;
  display(opts_add.opts_eb);
  edgeBoxesPath = opts_eb.opts.proposalDir;
else
    display('The dataset does not exist');
    exit
end

%balanced style!
listFolders  = dir2(opts_add.newTraining);
if BAL == 1
    minNElem = intmax;
    for i =1:length(listFolders)
        individualFolder = fullfile(listFolders(i).folder,listFolders(i).name);%%name replace with imagesFolder

        subFolders = dir2(individualFolder);%%%%%%%%%%%%%%%%%%%imagesFolder
        numElem = 0;
        for sub=1:length(subFolders)
            numElem = numElem + length(dir2(fullfile(subFolders(sub).folder,subFolders(sub).name)));
        end
        if numElem > minElem
            if minNElem > numElem
                minNElem = numElem
            end
        end
    end
end
%IMDB
DB_loc = 1;
cat_iter = 1;
index_test = find(imdb_eb.images.set == 3);
list_test_filename = imdb_eb.DB2O(index_test);

for i =1:length(listFolders)
%5 for each folder: check if the name of the folder is a class in
%imdb.classes 
    name_class = listFolders(i).name;
    %6 if it is: 
    if ~isempty(find(strcmp(imdb_eb.classes.name,name_class)==1))

        categories{cat_iter} = listFolders(i).name;
        cat_iter = cat_iter+1;
        listImages = dir2(fullfile(listFolders(i).folder,listFolders(i).name));%%%%%%%%%%%%%%%%%%%%%% imagesFolder
        fprintf('\n folder %s',fullfile(listFolders(i).folder,listFolders(i).name));%%%%%%%%%%%%%%%%%%%%%% imagesFolder

        mNE = min(minNElem,length(listImages));             
        r = randperm(length(listImages),floor(mNE));
        
        for j=1:mNE  
            DB = DB +1;
            id{DB_loc} = int2str(DB);
            name{DB_loc} = strcat('00000',int2str(DB),'.jpg');
            set{DB_loc} = 1;
            label{DB_loc} = listFolders(i).name;

            imgIter = r(j);
            if ~isempty(find(strcmp(listImages(imgIter).name,list_test_filename)==1)) 
                stop = 3;
                for search = 1:stop
                    imgIter = randperm(length(listImages),1);
                    if isempty(find(strcmp(listImages(imgIter).name,list_test_filename)==1)) 
                        stop = search;
                    else
                        stop = stop +1;
                    end
                end
            end

            im = imread(fullfile(listImages(imgIter).folder,listImages(imgIter).name));
            fileName= fullfile(pathDataset,name{DB_loc});
            imwrite(im,fileName);          

            DB2O{DB_loc} = fullfile(listImages(imgIter).folder,listImages(imgIter).name); %original name of the file
            
            dim = size(im);       
            sizeDB{DB_loc} = {dim(1),dim(2)};

            if area == 1
                boxes{DB_loc} = ExtractRandomBoxes_Area(dim);
            else
                boxes{DB_loc} = ExtractRandomBoxes_Diagonal(dim);
            end
            boxScores{DB_loc} =  repmat(1,[length(boxes{DB_loc}),1]);
            DB_loc = DB_loc+1;
            clearvars im 
        end       
    end
end
categories{cat_iter} = int2str(13);

%%%%%%%%%ID%%%%%%%%%%
S = sprintf('%s ', id{:});
D = sscanf(S, '%d');
idInt = transpose(D);
images.id = cat(2,imdb_eb.images.id,idInt);

%%%%%%%%%DB20%%%%%%%%%%
%6.1 add the name in DB20 
images.DB2O = cat(2,imdb_eb.DB2O,DB2O);

%%%%%%%%%name%%%%%%%%%%
%6.1 add the name in images.name
images.name = [imdb_eb.images.name, name];

%%%%%%%%%set%%%%%%%%%%
%6.1 add the set in images.set
S = sprintf('%d ', set{:});
setInt = sscanf(S, '%d');
setInt = transpose(setInt);
images.set = cat(2,imdb_eb.images.set,setInt);
%%%%%%%%%label%%%%%%%%%%
%6.1 add the label in images.label
labelDB = labelstr2mat(categories,label);
images.label = cat(2,imdb_eb.images.label,labelDB);
%%%%%%%%%size%%%%%%%%%%
%6.1 add the size in images.size
sizedb = [];
length(sizeDB)
for i=1:length(sizeDB)
    a = [];
    ans = sizeDB{1,i};
    x = sprintf('%d',ans{1,1});
    y = sprintf('%d',ans{1,2});
    X = sscanf(x,'%d');
    Y = sscanf(y,'%d');
    a = [X,Y];
    sizedb = [sizedb;a];
end
images.size = cat(1,imdb_eb.images.size,sizedb);
%%%%%%%%%boxes%%%%%%%%%%
%6.1 add the boxes in images.boxes
images.boxes = [imdb_eb.images.boxes, boxes];

%%%%%%%%%boxScores%%%%%%%%%%
%6.1 add the boxScores in images.boxScores
images.boxScores = [imdb_eb.images.boxScores, boxScores];

%%%%%%%%%%%%SAVE%%%%%%%%%
DB2O = images.DB2O;
structureFilename = fullfile(pathStructureFolder,'imdb-eb.mat');
optsFilename = fullfile(pathStructureFolder,'opts.mat');
images = struct('id',{images.id},'name',{images.name},'set',{images.set},'label',{images.label},'size',{images.size},'boxes',{images.boxes},'boxScores',{images.boxScores});
classes = struct('name',{categories},'description',{categories});
imageDir = pathDataset;

save(structureFilename,'classes', 'imageDir', 'images','DB2O');

%%%%%%%%%%%%%%%%%%%EDGE%%%%%%%%%%%%%%%%%%%
train = 1;
test = 1;
for i=1:length(images.set)
    if images.set(i)~=3
        imagesTrain{train} = images.name{i};
        boxesTrain{train} = images.boxes{i};
        boxScoresTrain{train} = images.boxScores{i};
        train = train+1;
    else
        imagesTest{test} = images.name{i};
        boxesTest{test} = images.boxes{i};
        boxScoresTest{test} = images.boxScores{i};
        test=test+1;
    end
end

edgeBoxesFoldername = fullfile('/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/data/IndiaEdgeBoxes',dataset);
mkdir(edgeBoxesFoldername);
images = imagesTrain;
boxes = boxesTrain;
boxScores = boxScoresTrain;
save(fullfile(edgeBoxesFoldername,'EdgeBoxesIndiatrainval.mat'),'images', 'boxes', 'boxScores');
images = imagesTest;
boxes = boxesTest;
boxScores = boxScoresTest;
save(fullfile(edgeBoxesFoldername,'EdgeBoxesIndiatest.mat'),'images', 'boxes', 'boxScores');

opts.expDir = fullfile('/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/exp/',expFilename);
opts.train.gpus = [];
opts.imdbPath = structureFilename;
opts.modelPath = '/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/models/imagenet-vgg-f.mat';
opts.proposalDir = edgeBoxesFoldername;

save(optsFilename,'opts');
end
