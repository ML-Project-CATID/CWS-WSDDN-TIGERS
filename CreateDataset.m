function CreateDataset()
% @author: Rita Pucci
% Modified by: Yogesh Purushotham and Abheeshta Rao
% wsddn CreateDataset : this organise the dataset in order to be used with wsddn 
% Individual Identification dataset for given a WSDDN model


pause('on');

minElem = 1;   % Min elements for each individual
scale = 1;    % Scale of the input image (that is applied only on images not in folder 'flacks')
DB = 1;         % Save the corrispondence of created dataset and original dataset
cat = 1;        % Counting categories taken into consideration
BAL = 0;        % Balancing guard
area = 0;       % Boxing technique

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------CHANGE NAMES FOR DIFFERENT DATASET ----------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pathImages = '/media/rpucci/Data/DeductedDataset/32_Tigers'; 
pathImages = 'C:/Users/USER/Desktop/code/Kartic_code/camtrap/src/matlab/MatConvNet/Tiger/Create dataset test/163 balanced images/'; %completed
listFolders  = dir(pathImages);
dataset = 'RandomInd_Tiger_m100_UC';
pathDataset = 'C:/Users/USER/Desktop/code/Kartic_code/camtrap/src/matlab/MatConvNet/Tiger/Create dataset test/tiger_dump/tiger_dump_163_bl/';
expFilename = '4.RandomSelectiveSearch_Tiger_m100_UC';
labelcsv = readtable('C:\Users\USER\Desktop\code\Kartic_code\camtrap\src\matlab\MatConvNet\Tiger\Create dataset test\label\imdb_labels_163_bl.csv');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pathStructureFolder = fullfile(vl_rootnn,'data/Imdbs',dataset);
if ~7==exist(pathStructureFolder,'dir')
    mkdir(pathStructureFolder);
    disp(strcat('Imdbs created in',pathStructureFolder));
end

structureFilename = fullfile(pathStructureFolder,'imdb_eb_163_bl.mat');
optsFilename = fullfile(pathStructureFolder,'opts_163_bl.mat');
if ~7==exist(pathDataset,'dir')
    mkdir(pathDataset);
    disp(strcat('Dataset created in',pathDataset));
end

tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minNElem = intmax;
if BAL == 1
    for i =1:length(listFolders)
        individualFolder = fullfile(listFolders(i).folder,listFolders(i).name); %%name replace with imagesFolder....

        subFolders = dir2(individualFolder);%%%%%%%%%%%%%%%%%%%imagesFolder
        numElem = 0;
        for sub=1:length(subFolders)
            numElem = numElem + length(dir(fullfile(subFolders(sub).folder,subFolders(sub).name)));
        end
        if numElem > minElem
            if minNElem > numElem
                minNElem = numElem
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
emptLis = {}; 
for i =3:length(listFolders)
    %disp(length(listFolders))
    individualFolder = fullfile(listFolders(i).folder,listFolders(i).name);%%name replace with imagesFolder
    subFolders = dir(individualFolder);
    %disp(length(subFolders))
    numElem = 0;
    for sub=1:length(subFolders)
        numElem = numElem + length(dir(fullfile(subFolders(sub).folder,subFolders(sub).name)));
    end
    if numElem > minElem
        categories{cat} = listFolders(i).name;
        disp(listFolders(i).name);
        disp(cat);
        cat = cat+1;
        
        for sub=1%%%%%%%%%%%%%%%%%%%%% imagesFolder
            listImages = dir(fullfile(subFolders(sub).folder, '*jpg'));%%%%%%%%%%%%%%%%%%%%%% imagesFolder
            %disp(length(listImages))
            %fprintf('\n folder %s',subFolders(sub).folder);%%%%%%%%%%%%%%%%%%%%%% imagesFolder
            
            mNE = min(minNElem/length(subFolders),length(listImages));       %%%        
            r = randperm(length(listImages),floor(mNE));    %%%
                    
            train = (mNE*60)/100 ;               %((MNE)/100)*60;
            val = (mNE*10)/100;                %((MNE)/100)*10;

            for j=1:mNE    
             %1:length(listImages)
                id{DB} = int2str(DB);
                name{DB} = strcat('00000',int2str(DB),'.jpg');
                setN = 1;
                if (j>train) && (j<train+val)
                    setN=2;
                else
                    if j>train+val
                        setN=3;
                    end
                end

                set{DB} = setN;
                label{DB} = listFolders(i).name;
                
                imgIter = r(j);
                im = imread(fullfile(listImages(imgIter).folder, listImages(imgIter).name));
                if strcmp(subFolders(sub).name,'flacks')
                    scale_rz = 1;
                else
                    scale_rz = scale;
                end
                im_resized = imresize(im,scale_rz);
                fileName= fullfile(pathDataset,name{DB});
                imwrite(im_resized,fileName);          
                
                DB2O{DB} = fullfile(listImages(imgIter).folder, listImages(imgIter).name); %original name of the file

                dim = size(im_resized);       
                sizeDB{DB} = {dim(1),dim(2)};

                if area == 1
                    boxes{DB} = ExtractRandomBoxes_Area(dim);
                else
                    boxes{DB} = ExtractRandomBoxes_Diagonal(dim);
                end
                boxScores{DB} =  repmat(1,[length(boxes{DB}),1]);

                DB=DB+1;
                clearvars im im_resized
            end
        end
        
     end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%---id----
S = sprintf('%s ', id{:});
D = sscanf(S, '%f');
idInt = transpose(D);
%---set----
S = sprintf('%d ', set{:});
setInt = sscanf(S, '%d');
setInt = transpose(setInt);
%---size----
sizedb = [];
for i=1:length(sizeDB)
    a = [];
    ans = sizeDB{1,i};
    x = sprintf('%f',ans{1,1});
    y = sprintf('%f',ans{1,2});
    X = sscanf(x,'%d');
    Y = sscanf(y,'%d');
    a = [X,Y];
    sizedb = [sizedb;a];
end

%disp(categories);
%disp(label);
writecell(DB2O, 'nameMapping_163_bl.csv')
labelDB = table2array(labelcsv);
%match labels with exact image names [BD_sndjfsjdf.jpg 00002.jpg] , table
%of dim (total images, 2) ==5
%col names as actual images names. 
%for loop for 1:33: {form in 2:cate}
% search for the image 1 or -1
%changes the col name with labels. 

images = struct('id',{idInt},'name',{name},'set',{setInt},'label',{labelDB},'size',{sizedb},'boxes',{boxes},'boxScores',{boxScores});
classes = struct('name',{categories},'description',{categories});
imageDir = pathDataset;

save(structureFilename,'classes', 'imageDir', 'images','DB2O');

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
edgeBoxesFoldername = fullfile('C:/Users/USER/Desktop/code/Kartic_code/camtrap/src/matlab/MatConvNet/Tiger/Create dataset test/',dataset);
mkdir(edgeBoxesFoldername);
images = imagesTrain;
boxes = boxesTrain;
boxScores = boxScoresTrain;
save(fullfile(edgeBoxesFoldername,'EdgeBoxesIndiatrainval_163_bl.mat'),'images',  'boxes', 'boxScores', 'imageDir');
images = imagesTest;
boxes = boxesTest;
boxScores = boxScoresTest;
save(fullfile(edgeBoxesFoldername,'EdgeBoxesIndiatest_163_bl.mat'),'images','boxes', 'boxScores', 'imageDir');

opts.expDir = fullfile('C:/Users/USER/Desktop/code/Kartic_code/camtrap/src/matlab/MatConvNet/Tiger/Create dataset test/',expFilename);
opts.train.gpus = [];
opts.imdbPath = structureFilename;
opts.modelPath = 'C:/Users/USER/Desktop/code/Kartic_code/camtrap/src/matlab/MatConvNet/Tiger/Create dataset test/models/imagenet-vgg-f.mat';
opts.proposalDir = edgeBoxesFoldername;

save(optsFilename,'opts');

toc
end
