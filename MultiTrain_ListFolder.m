function MultiTrain_ListFolder(folder)

vl_setupnn();
vl_contrib('setup', 'WSDDN') ;


list_folders = dir2(folder);

start = tic ;
for i = 1:length(list_folders)
   
    filename = fullfile(fullfile(list_folders(i).folder,list_folders(i).name),'opts.mat');
    
    if exist(filename,'file')==2
        opts = load(filename) ;
        display(filename);
    else
        display('The dataset does not exist');
    end
    
    wsddn_train(opts.opts);
    
    clear opts;
end
toc(start)

end
