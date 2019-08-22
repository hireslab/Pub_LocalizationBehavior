function trialProportion(U,touchDirection)

preDecisionMaskFull = preDecisionTouchMat(U);

preD_protraction_Touches = cell(1,10);
for i = 1:length(U)
    array = U{i};
    preDecisionMask = preDecisionMaskFull{i};
    touchmat = nan(size(preDecisionMask));
    touchIdx = [find(array.S_ctk(9,:,:)==1) ;find(array.S_ctk(12,:,:)==1)];
    touchmat(touchIdx)=1;
    
    phaseMask = squeeze(array.S_ctk(5,:,:));
    proPhaseMask = double(phaseMask<=0);
    proPhaseMask(proPhaseMask==0)=nan;
    
    if strcmp(touchDirection,'protraction')
        preD_protraction_Touch_mask = touchmat .* preDecisionMask .* proPhaseMask; %protraction touches only
    elseif strcmp(touchDirection,'all')
        preD_protraction_Touch_mask = touchmat .* preDecisionMask;
    end
    
    preD_protraction_Touches{i} = nansum(preD_protraction_Touch_mask);
    
    
    hit = intersect(find(array.meta.trialType==1), find(array.meta.trialCorrect==1));
    miss = intersect(find(array.meta.trialType==1), find(array.meta.trialCorrect==0));
    FA = intersect(find(array.meta.trialType==0), find(array.meta.trialCorrect==0));
    CR = intersect(find(array.meta.trialType==0), find(array.meta.trialCorrect==1));
    
    lix = zeros(1,length(preD_protraction_Touches{i}));
    nolix = lix;
    lix([hit FA]) = 1;
    nolix([miss CR]) = 1;
    go = array.meta.trialType==1;
    nogo = array.meta.trialType==0;
    touch = find(preD_protraction_Touches{i}>0);
    notouch = find(preD_protraction_Touches{i}==0);
    
    output.propTouchGo(i) = mean(go(touch));
    output.propTouchNogo(i) = 1-mean(go(touch));
    
    output.propNoTouchGo(i) = mean(go(notouch));
    output.propNoTouchNogo(i) = 1-mean(go(notouch));
    
    output.propTouchGoLick(i) = mean(lix(intersect(find(go==1),touch)));
    output.propTouchGoNoLick(i) = 1-mean(lix(intersect(find(go==1),touch)));
    
    output.propTouchNoGoLick(i) = mean(lix(intersect(find(nogo==1),touch)));
    output.propTouchNoGoNoLick(i) = 1-mean(lix(intersect(find(nogo==1),touch)));
    
    output.propNoTouchGoLick(i) = mean(lix(intersect(find(go==1),notouch)));
    output.propNoTouchGoNoLick(i) = 1-mean(lix(intersect(find(go==1),notouch)));
    
    output.propNoTouchNoGoLick(i) = mean(lix(intersect(find(nogo==1),notouch)));
    output.propNoTouchNoGoNoLick(i) = 1-mean(lix(intersect(find(nogo==1),notouch)));
    
end

%% Fig 3G
xgo     = output.propNoTouchGoLick;
xnogo   = output.propNoTouchNoGoLick;
ygo     = output.propTouchGoLick;
ynogo   = output.propTouchNoGoLick;

figure(37);clf

plot(xgo,ygo,'bo','Linewidth',1)
hold on
plot([0 1],[0 1],'k-')
plot(xnogo,ynogo,'ro','Linewidth',1)
xlabel('Proportion licking | no touch')
ylabel('Proportion licking | touch')

plot(nanmean(xgo),nanmean(ygo),'bx','Linewidth',1,'markersize',12)
plot(mean(xnogo),mean(ynogo),'rx','Linewidth',1,'markersize',12)

egox = nanstd(xgo);
egoy = nanstd(ygo);
enogox = nanstd(xnogo);
enogoy = nanstd(ynogo);

errorbar(nanmean(xgo),nanmean(ygo),egoy,egoy,nanmean(xgo),egox,'linewidth',1)
errorbar(nanmean(xnogo),nanmean(ynogo),enogoy,enogoy,nanmean(xnogo),enogox,'linewidth',1)
set(gca,'xtick',0:.2:1,'ytick',0:.2:1)
set(gcf,'paperposition',[0 0 4 4])
axis square
title('Fig 3G')



