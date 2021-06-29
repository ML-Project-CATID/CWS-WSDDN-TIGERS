function [dets] = wsddn_test_TIGER(newmode,varargin)
% @author: Rita Pucci
% wsddn_test : this script evaluates detection performance in Tiger
% Individual Identification dataset for given a WSDDN model

%threshold LINE 131
% no for
% n = 2;
% fileDataTest = fullfile('Cut_test/32',int2str(n));
% detsFoldername = fullfile('Dets/Cut_test/32',int2str(n));
% mkdir(detsFoldername);
% classificationFolder= fullfile(vl_rootnn, 'TestOutput/Cut_test/32',int2str(n));
% mkdir(classificationFolder);
fileDataTest = 'TIGERm100_bal_2018';
detsFoldername = 'TestDets/32 ub ind new';
mkdir(detsFoldername);
classificationFolder= fullfile(vl_rootnn, 'TestOutput/11.RandomInd_TIGERm100_bal_2018');
mkdir(classificationFolder);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.imageSave = fullfile(classificationFolder,'Hakan_PDF_det_loc_prova') ;
mkdir(opts.imageSave);
opts.detFoldeName = fullfile(vl_rootnn, 'TestOutput', detsFoldername, 'TestDets_train_32_ub.mat');
mkdir(fullfile(vl_rootnn, 'TestOutput', detsFoldername));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% opts.imageCMSave = fullfile(vl_rootnn, 'TestOutput/1.RandomSelectiveSearch_2/colormap') ;
% mkdir(opts.imageCMSave);
%--------------------------------------------------------------------------
opts.dataDir = fullfile(vl_rootnn, 'data') ;
opts.expDir = fullfile(vl_rootnn, 'exp/3.RandomSelectiveSearch/Net epoch_32_ub') ;
opts.imdbPath = fullfile(vl_rootnn, 'data/Imdbs/RandomInd_Tiger_m100_UC/imdb_eb_32.mat');
opts.proposalType = 'eb' ;
opts.proposalDir = fullfile(vl_rootnn, 'data','EdgeBoxesIndiatest/RandomTiger_32_bal') ;
%--------------------------------------------------------------------------
opts.maxNumProposals = 1893; % limit number
opts.imageScales = 688; % scales
opts.minBoxSize = 20;

opts.gpu = [] ; %vonfigure gpu
opts.train.prefetch = true ;
opts.vis = true ;
opts.numFetchThreads = 1 ;
opts = vl_argparse(opts, varargin) ;

opts.modelPath = fullfile(opts.expDir, 'net-epoch-12.mat');%'net.mat') ;

pause('on');

display(opts);

opts.train.expDir = opts.expDir ;
% -------------------------------------------------------------------------
%                                                    Network initialization
% -------------------------------------------------------------------------
net = load(opts.modelPath);
if isfield(net,'net')
  net = net.net;
end
net = dagnn.DagNN.loadobj(net) ;

net.mode = 'test' ;
if ~isempty(opts.gpu)
  gpuDevice(opts.gpu) ;
  net.move('gpu') ;
end

if isfield(net,'normalization')
  bopts = net.normalization;
else
  bopts = net.meta.normalization;
end

bopts.rgbVariance = [] ;
bopts.interpolation = net.meta.normalization.interpolation;
bopts.jitterBrightness = 0 ;
bopts.imageScales = opts.imageScales;
bopts.numThreads = opts.numFetchThreads;
bs = find(arrayfun(@(a) isa(a.block, 'dagnn.BiasSamples'), net.layers)==1);
bopts.addBiasSamples = ~isempty(bs) ;
bopts.vgg16 = any(arrayfun(@(a) strcmp(a.name, 'relu5'), net.layers)==1) ;
% To change le layer used for getting the ouput, it is necessary to change
% che 'relu5' with other names. The names of the layers are relaible from
% the net value in exp folder.


% -------------------------------------------------------------------------
%                                                   Database initialization
% -------------------------------------------------------------------------

fprintf('loading imdb...');
if exist(opts.imdbPath,'file')==2
  imdb = load(opts.imdbPath) ;
  display(opts.imdbPath);
else
    disp('The dataset does not exist');
    exit
end

fprintf('done\n');

imdb = fixBBoxes(imdb, opts.minBoxSize, opts.maxNumProposals);

TIGERinit;
Tigeropts.testset = newmode;
%newmode = Tigeropts.testset
Tigeropts.imgsetpath = fullfile(opts.dataDir,'Tigerm32_ub_2021','ImageSets','Main','%s.txt');
display(Tigeropts.imgsetpath);
cats = Tigeropts.classes;
disp(cats)
ovTh = 0.4;
scTh = 1e-3;
% --------------------------------------------------------------------
%                                                               Detect
% --------------------------------------------------------------------
if strcmp(Tigeropts.testset,'test')
  testIdx = find(imdb.images.set == 3);
  writematrix(testIdx, 'testIdx-test-32-ub.csv');
elseif strcmp(Tigeropts.testset,'trainval')
  testIdx = find(imdb.images.set < 3);
  writematrix(testIdx, 'testIdx-trainval-32-ub.csv');
end
bopts.useGpu = numel(opts.gpu) >  0 ;
scores = cell(1,numel(testIdx));
boxes = imdb.images.boxes(testIdx);
names = imdb.images.name(testIdx);
detLayer = find(arrayfun(@(a) strcmp(a.name, 'xTimes'), net.vars)==1);
net.vars(detLayer(1)).precious = 1;
% To change le layer used for getting the ouput, it is necessary to change
% che 'xTimes' with other names. The names of the layers are relaible from
% the net value in exp folder.
% run detection

start = tic ;
for t=1:numel(testIdx)
  batch = testIdx(t);
  
 scoret = [];
  for s=1:numel(opts.imageScales)
    for f=1:2 % add flips
      
      inputs = getBatch(bopts, imdb, batch, opts.imageScales(s), f-1 );
      net.eval(inputs) ;% Evaluation of test set with the network
      
      if isempty(scoret)
        scoret = squeeze(gather(net.vars(detLayer).value));
      else
        scoret = scoret + squeeze(gather(net.vars(detLayer).value));
      end
    end
  end
  scores{t} = scoret;
  
  time = toc(start) ;
  n = t * 2 * numel(opts.imageScales) ; % number of images processed overall
  speed = n/time ;
  if mod(t,10)==0
    fprintf('test %d / %d speed %.1f Hz\n',t,numel(testIdx),speed);
  end
  

  %                                                             Hakan Bilen
  % this code is coming from wsddn pack. This classification is mantained
  % to get the score cell array.
  cPvect = [];
  if opts.vis
    for cls = 1:numel(cats)
      idx = (scores{t}(cls,:)>0.005);   %%%%%%%%%%%% threshold 
      
      if sum(idx)==0, cPvect = cat(1,cPvect,-1);continue; end
      cPvect = cat(1,cPvect,1);
              % divide by number of scales and flips
  
      im = imread(fullfile(imdb.imageDir,imdb.images.name{testIdx(t)}));
      boxest  = double(imdb.images.boxes{testIdx(t)}(idx,:));
      scorest = scores{t}(cls,idx)' / (2 * numel(opts.imageScales));
      boxesSc = [boxest,scorest];
      pick = nms(boxesSc, ovTh);
      boxesSc = boxesSc(pick,:);
      
% -------------------------------------------------------------------------  
% To print out the visible box for localization
% -------------------------------------------------------------------------
%       f = figure('visible','off');
%       clf;
%       im = bbox_draw(im,boxesSc(1,[2 1 4 3 5]));
%       fprintf('%s %.2f',cats{cls},boxesSc(1,5));
%      
%       fprintf('\n') ;
%       
%       saveas(f,fullfile(opts.imageSave,imdb.images.name{testIdx(t)}));
%       
%       hold off
%-------------------------------------------------------------------------         
    end
     clearvars im boxest scorest boxesSc boxesSc f
  end
  dets.labelPred{t} = cPvect ;
  dets.scoret{t} = scoret;
  %                                                             Hakan Bilen
  
end
dets.names  = names;
dets.scores = scores;
dets.boxes  = boxes;
toc(start)
save(opts.detFoldeName,'dets');

%top30 classification by the means of scores
%output = Classification_topN(opts.imdbPath,detsFoldername)
%resultsDerivationsConfM = multiClass_derivationsFromConfMatrix(output.confMatrix);
%ClassificationSubFolder = fullfile(classificationFolder,'Classification');
%mkdir(ClassificationSubFolder);
%save(fullfile(ClassificationSubFolder,'matlab.mat'),'output','resultsDerivationsConfM');

%   
% % --------------------------------------------------------------------
% %                                                     TIGER evaluation
% % --------------------------------------------------------------------
% 
% aps = zeros(numel(cats),1);
% for cls = 1:numel(cats)
% %   
%    tigerDets.confidence = [];
%    tigerDets.bbox       = [];
%    tigerDets.ids        = [];
% % 
%    for i=1:numel(dets.names)
% %     
%      scores = double(dets.scores{i});
%      boxes  = double(dets.boxes{i});
% %     
%      boxesSc = [boxes,scores(cls,:)'];
%      size(boxesSc);
%      boxesSc = boxesSc(boxesSc(:,5)>scTh,:);
%      pick = nms(boxesSc, ovTh);
%      boxesSc = boxesSc(pick,:);
% %     
%      tigerDets.confidence = [tigerDets.confidence;boxesSc(:,5)];
%      tigerDets.bbox = [tigerDets.bbox;boxesSc(:,[2 1 4 3])];
%      tigerDets.ids = [tigerDets.ids; repmat({dets.names{i}(1:6)},size(boxesSc,1),1)];
% %     
%    end
%    display(tigerDets.confidence);
%    [rec,prec,ap] = wsddnTigerevaldet(Tigeropts,cats{cls},tigerDets,0);
% %   
% %   fprintf('%s %.1f\n',cats{cls},100*ap);
% %   aps(cls) = ap;
%  end

end

% --------------------------------------------------------------------
function inputs = getBatch(opts, imdb, batch, scale, flip)
% --------------------------------------------------------------------

opts.scale = scale;
opts.flip = flip;
is_vgg16 = opts.vgg16 ;
opts = rmfield(opts,'vgg16') ;

images = strcat([imdb.imageDir filesep], imdb.images.name(batch)) ;
opts.prefetch = (nargout == 0);

[im,rois] = wsddn_get_batch(images, imdb, batch, opts);


rois = single(rois');
if opts.useGpu > 0
  im = gpuArray(im) ;
  rois = gpuArray(rois) ;
end
rois = rois([1 3 2 5 4],:) ;


ss = [16 16] ;
if is_vgg16
  o0 = 8.5 ;
  o1 = 9.5 ;
else
  o0 = 18 ;
  o1 = 9.5 ;
end
rois = [ rois(1,:);
        floor((rois(2,:) - o0 + o1) / ss(1) + 0.5) + 1;
        floor((rois(3,:) - o0 + o1) / ss(2) + 0.5) + 1;
        ceil((rois(4,:) - o0 - o1) / ss(1) - 0.5) + 1;
        ceil((rois(5,:) - o0 - o1) / ss(2) - 0.5) + 1];

      
inputs = {'input', im, 'rois', rois} ;
  
  
if opts.addBiasSamples && isfield(imdb.images,'boxScores')
  boxScore = reshape(imdb.images.boxScores{batch},[1 1 1 numel(imdb.images.boxScores{batch})]);
  inputs{end+1} = 'boxScore';
  inputs{end+1} = boxScore ; 
end
end


% -------------------------------------------------------------------------
function imdb = fixBBoxes(imdb, minSize, maxNum)

for i=1:numel(imdb.images.name)
  bbox = imdb.images.boxes{i};
  % remove small bbox
  isGood = (bbox(:,3)>=bbox(:,1)+minSize) & (bbox(:,4)>=bbox(:,2)+minSize);
  bbox = bbox(isGood,:);
  % remove duplicate ones
  [dummy, uniqueIdx] = unique(bbox, 'rows', 'first');
  uniqueIdx = sort(uniqueIdx);
  bbox = bbox(uniqueIdx,:);
  % limit number for training
  if imdb.images.set(i)~=3
    nB = min(size(bbox,1),maxNum);
  else 
    nB = size(bbox,1);
  end
  
  if isfield(imdb.images,'boxScores')
    imdb.images.boxScores{i} = imdb.images.boxScores{i}(isGood);
    imdb.images.boxScores{i} = imdb.images.boxScores{i}(uniqueIdx);
    imdb.images.boxScores{i} = imdb.images.boxScores{i}(1:nB);
  end
  imdb.images.boxes{i} = bbox(1:nB,:);
  %   [h,w,~] = size(imdb.images.data{i});
  %   imdb.images.boxes{i} = [1 1 h w];
  
end
end

%-------------------------------------------------------------------------%

function im = bbox_draw(im,boxes,c,t)

% copied from Ross Girshick
% Fast R-CNN
% Copyright (c) 2015 Microsoft
% Licensed under The MIT License [see LICENSE for details]
% Written by Ross Girshick
% --------------------------------------------------------
% source: https://github.com/rbgirshick/fast-rcnn/blob/master/matlab/showboxes.m
%
%
% Fast R-CNN
% 
% Copyright (c) Microsoft Corporation
% 
% All rights reserved.
% 
% MIT License
% 
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the "Software"),
% to deal in the Software without restriction, including without limitation
% the rights to use, copy, modify, merge, publish, distribute, sublicense,
% and/or sell copies of the Software, and to permit persons to whom the
% Software is furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
% THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
% OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
% ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
% OTHER DEALINGS IN THE SOFTWARE.

image(im);
axis image;
axis off;
set(gcf, 'Color', 'white');

if nargin<3
  c = 'r';
  t = 2;
end

s = '-';
if ~isempty(boxes)
    x1 = boxes(:, 1);
    y1 = boxes(:, 2);
    x2 = boxes(:, 3);
    y2 = boxes(:, 4);
    line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', ...
        'color', c, 'linewidth', t, 'linestyle', s);
    for i = 1:size(boxes, 1)
        text(double(x1(i)), double(y1(i)) - 2, ...
            sprintf('%.4f', boxes(i, end)), ...
            'backgroundcolor', 'b', 'color', 'w', 'FontSize', 8);
    end
end
end