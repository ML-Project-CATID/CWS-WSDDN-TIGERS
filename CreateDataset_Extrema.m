function [images] = CreateDataset_Extrema()
fprintf('Boxes extractions..')

%%
% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.

pause('on');

random = 0;
BGon = 0;

pathImages = '/media/rpucci/Data/DeductedDataset/MatConvNet_tiger_dataset';
listFolders  = dir2(pathImages);
pathDataset = '/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/data/India/Tiger/NOBG/Extrema&SelectiveSearch';
night_image_path = '/media/rpucci/Data/Results_TEST/TEST_DATASET/MaskedImages/10x10_sf0.5/EI';
if ~7==exist(pathDataset,'dir')
    mkdir(pathDataset);
end

scale = 0.5;
% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
datasetBoxes = {};
id = {};
label={};
set = {};
sizeDB = {};
DB=1;

tic
for i =1:length(listFolders)
    
    imagesFolder = fullfile(listFolders(i).folder,listFolders(i).name);
    listImages = dir2(imagesFolder);
    fprintf('\n folder %s',imagesFolder);
    train = (length(listImages)/100)*60;
    val = (length(listImages)/100)*10;
    for j=1:length(listImages)
        if strcmp(listFolders(i).name,'Unclassified')
            if random == 1
                boxes = SelectedOmogeneousArea([1 1 768 1024]);
                boxScores = repmat(0.1,[length(boxes),1]);
            else
                [boxes, boxScores] = selectiveResearchUnclassified(listImages(j).name,listImages(j).folder);
            end

        else
            if random == 1
                [boxes, boxScores] = RandomTigerSelectiveBoxes(listImages(j).name,listImages(j).folder,night_image_path,listFolders(i).name,BGon);     
            else
                [boxes,boxScores] = TigerSelectiveBoxes(listImages(j).name,listImages(j).folder,night_image_path,listFolders(i).name,BGon);
            end
        end
        datasetBoxes{DB} = boxes;
        datasetBoxScore{DB} = boxScores;
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
        im = imread(fullfile(listImages(j).folder,listImages(j).name));
        im_resized = imresize(im,scale);
        dim = size(im_resized);
        %sizeDB{DB} = {dim(1),dim(2)};
        sizeDB{DB} = {768,1024};
        fileName= fullfile(pathDataset,strcat('00000',int2str(DB),'.jpg'));
        imwrite(im_resized,fileName);
        DB=DB+1
        clearvars im fileName
    end
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
    sizedb = cat(1,sizedb,a);
end

categories = {'Individual1','Individual2','Individual3','Unclassified'};
labelDB = labelstr2mat(categories,label);
imagesIndia = struct('id',{idInt},'name',{name},'set',{setInt},'label',{labelDB},'size',{sizedb},'boxes',{datasetBoxes},'boxScores',{datasetBoxScore});
classesIndia = struct('name',{categories},'description',{categories});
imageDir = pathDataset;

images = struct('classes', classesIndia ,'imageDir', imageDir, 'images', imagesIndia);
toc
end

function [boxes, boxScores] = selectiveResearchUnclassified(name,folder)
    colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
    colorType = colorTypes{1}; % Single color space for demo

    % Here you specify which similarity functions to use in merging
    simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};
    simFunctionHandles = simFunctionHandles(1:2); % Two different merging strategies

    % Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
    % Note that by default, we set minSize = k, and sigma = 0.8.
    k = 100; % controls size of segments of initial segmentation. 
    minSize = k;
    sigma = 0.8;
    imageName = fullfile(folder,name);
    im = imread(imageName);
    im = imresize(im,0.5);
    [boxes blobIndIm blobBoxes hierarchy] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
    boxes = BoxRemoveDuplicates(boxes); 
    boxScores = repmat(0.1,[length(boxes),1]);
end
    
    
    
    
    
