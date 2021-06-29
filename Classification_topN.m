function [output] = Classification_topN(imdb,dets)

nsample = 30;
N = 9;

opts.imdbPath = fullfile(vl_rootnn, 'data/Imdbs/RandomInd_Tiger_m100_UC/' , 'imdb_eb_32.mat');
opts.dets = fullfile(vl_rootnn, 'TestOutput/TestDets/32 ub ind new/', 'TestDets_train_32_ub.mat');
%labelcsv = readtable('C:\Users\USER\Desktop\code\Kartic_code\camtrap\src\matlab\MatConvNet\Tiger\Create dataset test\label\imdb_labels_163.csv')
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
    %exit
end

images = imdb.images;
label = images.label;

names = dets.dets.names;
classes = imdb.classes.name;
disp(classes);
ConfMatrix = zeros(numel(classes));

elem = length(names);

missClassified = [];

for nelem = 1:elem
    name = names{1,nelem};
    boxes = dets.dets.boxes{1,nelem};
    scores = dets.dets.scores{1,nelem};

    idx = find(strcmp(images.name,name));   
    labelElem = label(:,idx);
    labelT = find(labelElem == 1);
    pollPos = [];

    for cls = 1:numel(classes)     
        scores_c = sort(scores(cls,:),'descend');       
        pollPos = cat(1,pollPos,scores_c(1,1:nsample));
    end
    PPos{nelem} = pollPos;
    
    maxPPos = max(pollPos);
    
    X = zeros(1,numel(classes));
    Sum = zeros(1,numel(classes));
    
    PPos_A = [];
    boxesC = [];
    b = 1;
    for i = 1:nsample
        [idxPP c] = find(pollPos==maxPPos(i));
        if length(idxPP)>1
            for j=1:length(idxPP)
                PPos_A = cat(1,PPos_A,[idxPP(j),  maxPPos(i)]);
            end
        else
            PPos_A = cat(1,PPos_A,[idxPP,  maxPPos(i)]);
        end
        X(1,idxPP) = X(1,idxPP) + 1;
        Sum(1,idxPP) = Sum(1,idxPP) + maxPPos(i);
        idxB = find(scores(idxPP(1),:)==maxPPos(i));
        if length(idxB)>1
            for j=1:length(idxB)
                boxesC{b,1} = idxB(j);
                boxesC{b,2} = idxPP(1);
                b = b+1;
            end
        else          
                boxesC{b,1} = idxB;
                boxesC{b,2} = idxPP(1);
                b = b+1;
        end
            
    end
    boxesClass{nelem} = boxesC;
    SumMax{nelem} = Sum./X;
    vecP = [];
    Sum = Sum./X;
    for i = 1:numel(classes)
        if X(i) == 0
            vecP = cat(1,vecP,-1);
        else
            if Sum(i) == max(Sum)
                vecP = cat(1,vecP,1);
                labelP = i;
            else
                vecP = cat(1,vecP,-1);
            end
        end
    end
    predVec{nelem} = vecP;
    maxPos{nelem} = PPos_A;
    ConfMatrix(labelP,labelT) = ConfMatrix(labelP,labelT) +1;
    if ~(labelT==labelP)
        missClassified= cat(1,missClassified,[nelem,{name},labelT,labelP]);
    end
    
    for i =1:length(maxPos)
        list = maxPos{1,i};
        cls = [];
        for j=1:numel(classes)
            cls = cat(1,cls,sum(list(find(list(:,1)==j),2))/length(find(list(:,1)==j)));
            if isnan(cls(j))
                cls(j)=0.0;
            end
        end
        sort_cls = sort(cls,'descend');
        difference{i,1} = sort_cls(1);
        difference{i,2} = sort_cls(2);
        difference{i,3} = sort_cls(1) - sort_cls(2);
        meanSum{i} = cls;
    end
end    
size_MC = size(missClassified);
count = 0;
pwc = [];
ConfMatrix2 = ConfMatrix;
for i = 1:size_MC(1)

        mis_clas_file = missClassified(i,:);

        position_file = mis_clas_file(1);
        wanted_clas = mis_clas_file(3);
        predicted_clas = mis_clas_file(4);

        score = dets.dets.scores{1,cell2mat(position_file)};
        max_class = [];
        for j=1:numel(classes)
            max_class = cat(1,max_class,[j,max(score(j,:))]);
        end
        M_class{i} = max_class;

        out=sortrows(max_class,2,'descend');

        position_wanted_class = find(out(:,1) == cell2mat(wanted_clas));

        if position_wanted_class(1) < N
            count = count + 1;
            
            ConfMatrix2(cell2mat(wanted_clas),cell2mat(wanted_clas)) = ConfMatrix2(cell2mat(wanted_clas),cell2mat(wanted_clas))+1;
            ConfMatrix2(cell2mat(predicted_clas),cell2mat(wanted_clas)) = ConfMatrix2(cell2mat(predicted_clas),cell2mat(wanted_clas))-1;
        end
        pwc = cat(1,pwc,position_wanted_class(1));
        
end

output.MC_topN = length(find(pwc<N));
output.PollPosition = PPos;
output.maxPosition = maxPos;
output.MaxSum = SumMax;
output.prediction_vector = predVec;
output.confMatrix = ConfMatrix;
output.confMatrix2 = ConfMatrix2;
output.missClassified = missClassified;
output.boxesClass = boxesClass;
output.difference = difference;
output.meanSum = meanSum;

% To derieve scores from confusion atrix
tp_m = diag(output.confMatrix);
%mltable = table('VariableNames', {'TP', 'FP', 'FN', 'TN', 'Accuracy', 'Precision', 'Recall', 'Specificity', 'F1score'});
groupDataValidation = array2table(zeros(0,9));
groupDataValidation.Properties.VariableNames = {'TP','FP','FN','TN', 'Accuracy','Precision', 'Recall', 'Specificity', 'F1score'};

for i = 1:numel(classes)
    TP = tp_m(i);
    FP = sum(output.confMatrix(i, :), 2) - TP;
    FN = sum(output.confMatrix(:, i), 1) - TP;
    TN = sum(output.confMatrix(:)) - TP - FP - FN;
    Accuracy = (TP+TN)/(TP+FP+TN+FN);
   
    Recall = TP/(TP + FN); %tp/actual positive  RECALL SENSITIVITY
    if isnan(Recall)
    Recall = 0;
    end
    
    Precision = TP/ (TP + FP);  % tp / predicted positive PRECISION
    if isnan(Precision)
    Precision = 0;
    end
    
    Specificity = TN/ (TN+FP); %tn/ actual negative  SPECIFICITY
    if isnan(Specificity)
    Specificity = 0;
    end
    
    F1score = (2*(Precision * Recall)) / (Precision+Recall);
    if isnan(F1score)
    F1score = 0;
    end
    
    newrow = table(TP,FP,FN, TN, Accuracy, Recall, Precision, Specificity, F1score);
    groupDataValidation = [ groupDataValidation; newrow];

output.groupDataValidation = groupDataValidation;

writematrix(output.confMatrix,'trainConfMtx_32_ub_25.06.2021.csv');
writetable(output.groupDataValidation,'trainScores_32_ub_25.06.2021.csv');
writecell(output.missClassified,  'trainMissclassified_32_ub_25.06.2021.csv');

save('outputMetrics_32_ub_25.06.2021.mat', '-struct', 'output');


end

