function proportionTTypeTouch(BV)

preDecisionMask = preDecisionTouchMat(BV);

for i = 1:length(BV)
    
    ttype = BV{i}.meta.trialType;
    tt  = sum(~isnan(preDecisionMask{i}))>0 ;
    tc = BV{i}.meta.trialCorrect;
    
    [numTouches, ~] = preDecisionTouchFeatures(BV{i},preDecisionMask{i},1,'all','all');

    %     tttc(i) = numel(intersect(find(numTouches>0),find(tc==1))) ./ numel(find(numTouches>0));
    %     nttc(i) = numel(intersect(find(numTouches<=0),find(tc==1))) ./ numel(find(numTouches<=0));
    
    tttc(i) = numel(intersect(find(numTouches>0),find(ttype==1))) ./ numel(find(ttype==1));
    nttc(i) = numel(intersect(find(numTouches>0),find(ttype==0))) ./ numel(find(ttype==0));
    
end

figure(35);
scatter(ones(length(BV),1),tttc,'bo')
hold on; errorbar(1,mean(tttc),std(tttc)./sqrt(length(BV)),'ko')
hold on; scatter(ones(length(BV),1)*2,nttc,'ro')
hold on; errorbar(2,mean(nttc),std(nttc)./sqrt(length(BV)),'ko')
set(gca,'xtick',[1 2],'xlim',[.5 2.5],'xticklabel',{'go trials','nogo trials'},'ylim',[0 1],'ytick',0:.25:1)
ylabel('proportion of trials with touch')
title('Fig 3E')


