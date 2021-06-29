function cutPercentageImdbEb(N,X,Y,DBcut,Percut)

subfolder_name = 'Cut';

for i = 1:length(X)
        for j = 1:length(Y)
            folder_name = fullfile(vl_rootnn,'data/IndiaImdbs',strcat('RandomInd_Tiger_',X{i},'_',Y{j}));
            file_name = fullfile(folder_name,'imdb-eb.mat');
            out_folder = fullfile(vl_rootnn,'data/IndiaImdbs',subfolder_name,strcat('RandomInd_Tiger_',X{i},'_',Y{j}));
            mkdir(out_folder);
            

            if exist(file_name,'file')==2
                imdb_val = load(file_name);
            else
                display(file_name);
                display('The dataset does not exist');
            end

            classes = imdb_val.classes;
            DB2O = imdb_val.DB2O;
            imageDir = imdb_val.imageDir;
            
            for dbc = 1:length(DBcut)
                DB_c = DBcut(dbc);
                tmp_folder = fullfile(out_folder,strcat(X{i},Y{j},'_',int2str(DB_c)));
                for pc = 1:length(Percut)
                   p_c = Percut(pc);
                   tmp2_folder = strcat(tmp_folder,strcat('_p',int2str(p_c))); 
                   mkdir(tmp2_folder);
                   filename = fullfile(tmp2_folder,'imdb-eb.mat');
                   
                   display(tmp2_folder);
                   
                   idInt = [];
                   setInt = [];
                   label = [];
                   sizedb = [];
                   name = {};
                   boxes ={};
                   boxScores ={};
                   
                   for ind = 1:length(classes.name)
                       ind_index = find(imdb_val.images.label(ind,:)==1);
                       
                       set_index = imdb_val.images.set(ind_index);
                       set_train = cat(2,find(set_index==1),find(set_index==2));
                       ind_index_train = ind_index(set_train);
                       set_test = find(set_index==3);
                       ind_index_test = ind_index(set_test);  
                        
                       train = (DB_c/100)*(p_c-10);
                       val = (DB_c/100)*10  ;              
                       rnd_ind_index_train = ind_index_train(randperm(length(set_train),min(floor(train+val),length(set_train))));
                       rnd_ind_index_test = ind_index_test(randperm(length(set_test),min(floor(DB_c-(train+val)),length(set_test))));
                       
                       
                                                                 
                       %1# extract the id array list
                       sub_id = cat(2,imdb_val.images.id(rnd_ind_index_train),...
                           imdb_val.images.id(rnd_ind_index_test));
                       %2# extract the name cell list
                       sub_name = cat(2,imdb_val.images.name(rnd_ind_index_train),...
                           imdb_val.images.name(rnd_ind_index_test));
                       %3# extract the set array list                     
                       set(1:floor(length(rnd_ind_index_train))) = 1;
%                        set(floor(train):floor(train+val)) = 2;
                       set(length(rnd_ind_index_train) +1:length(rnd_ind_index_train)+length(rnd_ind_index_test)) = 3;                        
                       %4# extract the label array list    
                       sub_label = cat(2,imdb_val.images.label(:,rnd_ind_index_train),...
                           imdb_val.images.label(:,rnd_ind_index_test));
                       %5# extract the size array list
                       sub_size = cat(1,imdb_val.images.size(rnd_ind_index_train,:),...
                           imdb_val.images.size(rnd_ind_index_test,:));
                       %6# extract the boxes cell list
                       sub_boxes = cat(2,imdb_val.images.boxes(rnd_ind_index_train),...
                           imdb_val.images.boxes(rnd_ind_index_test));
                       %7# extract the boxScores cell list
                       sub_boxScores = cat(2,imdb_val.images.boxScores(rnd_ind_index_train),...
                           imdb_val.images.boxScores(rnd_ind_index_test));                 
%                        
                       %8# CAT images parameters
                       idInt = cat(2,idInt,sub_id);
                       name = cat(2,name,sub_name);
                       setInt  = cat(2,setInt,set);
                       label = cat(2,label,sub_label);
                       sizedb = cat(1,sizedb,sub_size);
                       boxes = cat(2,boxes,sub_boxes);
                       boxScores = cat(2,boxScores,sub_boxScores);
                       
                       clear rnd_ind_index sub_id sub_name set sub_label sub_size ...
                           sub_boxes sub_boxScores
                   end
                   
                   %%%%%%%%%%%%%%%%%%%IMAGES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   images = struct('id',{idInt},'name',{name},'set',{setInt},...
                        'label',{label},'size',{sizedb},'boxes',{boxes},'boxScores',{boxScores});
                   save(filename,'classes', 'imageDir', 'DB2O','images');
                   
                   clear idInt name setInt label sizedb boxes boxScores
                   
                   
                   train = 1;
                   test = 1;
                   for n=1:length(images.set)
                       if images.set(n)~=3
                            imagesTrain{train} = images.name{n};
                            boxesTrain{train} = images.boxes{n};
                            boxScoresTrain{train} = images.boxScores{n};
                            train = train+1;
                       else
                            imagesTest{test} = images.name{n};
                            boxesTest{test} = images.boxes{n};
                            boxScoresTest{test} = images.boxScores{n};
                            test=test+1;
                       end
                   end
                    clear images
                    edgeBoxesFoldername = fullfile(vl_rootnn,'data/IndiaEdgeBoxes/Cut',strcat('RandomInd_Tiger_',X{i},'_',Y{j}),strcat(X{i},Y{j},'_',int2str(DB_c),'_',int2str(p_c)));
                    mkdir(edgeBoxesFoldername);
                    images = imagesTrain;
                    boxes = boxesTrain;
                    boxScores = boxScoresTrain;
                    save(fullfile(edgeBoxesFoldername,'EdgeBoxesIndiatrainval.mat'),'images', 'boxes', 'boxScores');
                    images = imagesTest;
                    boxes = boxesTest;
                    boxScores = boxScoresTest;
                    save(fullfile(edgeBoxesFoldername,'EdgeBoxesIndiatest.mat'),'images', 'boxes', 'boxScores');
                    
                    clear images boxes boxScores imagesTrain boxesTrain boxScoresTrain imagesTest boxesTest boxScoresTest
                    
                    optsFilename = fullfile(tmp2_folder,'opts.mat');
                    opts.expDir = fullfile(vl_rootnn,'exp/Cut',strcat(N{i},'.RandomSelectiveSearch_Tiger_',X{i},'_',Y{j},'_',int2str(DB_c),'_',int2str(p_c)));
                    opts.train.gpus = [];
                    opts.imdbPath = filename;
                    opts.modelPath = '/media/rpucci/Data/Matlab/MatConvNet/PROJECT/MatConvNet/matconvnet-1.0-beta25/models/imagenet-vgg-f.mat';
                    opts.proposalDir = edgeBoxesFoldername;

                    save(optsFilename,'opts');
                    
                    clear opts

                end
            end
            
            clear imdb_val tmp2_folder tmp_folder;
        end
        
end