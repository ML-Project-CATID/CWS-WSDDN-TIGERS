function CreateMLCImage_PDF_SImage(folder,filename,output)

listfolder = dir2(folder)
c = length(listfolder)
r = length(filename)

f = figure(1);
clf;
j=1;
for row = 1:5
    for column= 1:c
        nameFolder = fullfile(folder,listfolder(column).name);        
        im = imread(fullfile(nameFolder,filename{row}));
        subplot(5,c,j);
        j = j+1;
        image(im);
        axis off
    end
end
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

saveas(f,fullfile(output,'BOXES_FOCUS_TRUE.jpg'));
