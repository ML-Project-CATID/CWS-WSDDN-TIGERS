function [ids,confidence,BB] = wsddnTigerevaldet(Tigeropts,cls,res,draw)

%valuta la performance per ogni classe

%cls è la classe che consideriamo quindi prendiamo tutti i file nel test
%set e valutiamo 

tic
[gtids,t]=textread(sprintf(Tigeropts.imgsetpath,Tigeropts.testset),'%s %d');
for i=1:length(gtids)
% display progress
    if toc>1
      fprintf('%s: pr: load: %d/%d\n',cls,i,length(gtids));
      drawnow;
      tic;
    end
end
hash=wsddnVOChash_init(gtids);
fprintf('%s: pr: evaluating detections\n',cls);
% load results
ids        = res.ids;
confidence = res.confidence;
BB         = res.bbox';

% sort detections by decreasing confidence
[sc,si]=sort(-confidence);
ids=ids(si);
BB=BB(:,si);
% assign detections to ground truth objects
nd=length(confidence);
tp=zeros(nd,1);
fp=zeros(nd,1);
tic;
for d=1:nd
  % display progress
  if toc>1
    fprintf('%s: pr: compute: %d/%d\n',cls,d,nd);
    drawnow;
    tic;
  end
    % find ground truth image
  i=wsddnVOChash_lookup(hash,ids{d})
  if isempty(i)
    error('unrecognized image "%s"',ids{d});
  elseif length(i)>1
    error('multiple image "%s"',ids{d});
  end
end

