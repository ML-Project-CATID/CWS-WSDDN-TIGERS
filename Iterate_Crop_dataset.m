function Iterate_Crop_dataset()
% @author: Rita Pucci
% CropImages : Cropping image by tiger localization. 
% 3 possible crop: MaxBox,MiddleBox, and intersection+Middlebox

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                           Custom datafile
    dets_filename = fullfile(vl_rootnn, 'TestOutput/9.RandomInd_Tiger_m70_bal_2_Train/Classification/matlab.mat');
    classfication_filename = fullfile(vl_rootnn, 'TestOutput/Dets_Training/TestDets_RandomInd_Tiger_m70_bal_2/TestDets.mat');
    imdb_filename = fullfile(vl_rootnn,'data/IndiaImdbs','RandomInd_Tiger_m70_bal_2', 'imdb-eb.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    if exist(dets_filename,'file')==2
        classification = load(dets_filename);
    end
    if exist(classfication_filename,'file')==2
        dets = load(classfication_filename);
    end
    
    if exist(imdb_filename,'file')==2
        imdb = load(imdb_filename);
        imdb_dir = imdb.imageDir;
    end

    images_names = dets.dets.names;
    
    % 1 => MaxBox
    % 2 => MiddleBox
    % 3 => intersection+Middlebox
    type_box = 3;
    
    for j =1:size(images_names,2)
        % 1. avoid missclassified images
        missC_cell = classification.missClassified;
        missClassified = cell2mat(missC_cell(:,1));
        
        if isempty(find(missClassified==j))
      % if the image is not missclassified during the test classification
           boxes_topN_cell = classification.boxesClass{1,j};
           boxes_topN = boxes_topN_cell(:,1);
           class_topN_cell = classification.boxesClass{1,j};
           class_topN = cell2mat(class_topN_cell(:,2));
           
           predVec = classification.predVec{:,j};
           class_predicted = find(predVec==1);
    
           boxes = dets.dets.boxes{1,j};
    
           ind_boxes = find(class_topN == class_predicted);
           
           boxes = boxes(ind_boxes,:);
        % the new dataset is created by cutting off the box that is
        % selected. The maximum box or the middle box between maximum and
        % minimum.
           if type_box == 1
               b2 = min(boxes(:,2));
               b3 = max(boxes(:,3));      
               b4 = max(boxes(:,4));
               b1 = min(boxes(:,1));
               newDb_foldername = fullfile('/media/rpucci/Data/DeductedDataset/12_Tigers_2_crop',int2str(class_predicted),'flacks');
           end
           if type_box == 2
               b2 = min(boxes(:,2)) + floor((abs(min(boxes(:,2))+max(boxes(:,2)))/2));
               b3 = max(boxes(:,3)) - floor((abs(max(boxes(:,3))-min(boxes(:,3)))/2));      
               b4 = max(boxes(:,4)) - floor((abs(max(boxes(:,4))-min(boxes(:,4)))/2));
               b1 = min(boxes(:,1)) + floor((abs(min(boxes(:,1))+max(boxes(:,1)))/2));
               newDb_foldername = fullfile('/media/rpucci/Data/DeductedDataset/12_Tigers_2_crop_T2',int2str(class_predicted),'flacks');
           end
           if type_box == 3  
               b2 = min(boxes(:,2)) + floor((abs(min(boxes(:,2))+max(boxes(:,2)))/2));
               b3 = max(boxes(:,3)) - floor((abs(max(boxes(:,3))-min(boxes(:,3)))/2));      
               b4 = max(boxes(:,4)) - floor((abs(max(boxes(:,4))-min(boxes(:,4)))/2));
               b1 = min(boxes(:,1)) + floor((abs(min(boxes(:,1))+max(boxes(:,1)))/2));
               
                b2 = max(boxes(:,2)) - ((b4-b2)/2-(min(boxes(:,4))-max(boxes(:,2)))/2)/2;
                b3 = min(boxes(:,3)) + ((b3-b1)/2-(min(boxes(:,3))-max(boxes(:,1)))/2)/2;      
                b4 = min(boxes(:,4)) + ((b4-b2)/2-(min(boxes(:,4))-max(boxes(:,2)))/2)/2;
                b1 = max(boxes(:,1)) - ((b3-b1)/2-(min(boxes(:,3))-max(boxes(:,1)))/2)/2;   
                newDb_foldername = fullfile('/media/rpucci/Data/DeductedDataset/12_Tigers_2_crop_T3',int2str(class_predicted),'flacks');
          end
           
           crop_box = [b1,b2,b4-b2,b3-b1];
          
           if ~exist(newDb_foldername)
               mkdir(newDb_foldername);
           end
           
           newDB_filename = fullfile(newDb_foldername,images_names{j}); 
           I = imread(fullfile(imdb_dir, images_names{j}));
           crop_I = imcrop(I,crop_box);     
           imwrite(crop_I,newDB_filename);
           
           clearvars boxes boxes_topN boxes_topN_cell class_predicted class_topN class_topN_cell crop_box crop_I I missC_cell predVec ind_boxes b1 b2 b3 b4
        end
    end
end