function numTouchesLickProbability(uberarray,touchDirection,touchOrder)

preDecisionMask = preDecisionTouchMat(uberarray);

for rec = 1:length(uberarray)
    
    array=uberarray{rec};
    
    hit = intersect(find(array.meta.trialType==1), find(array.meta.trialCorrect==1));
    miss = intersect(find(array.meta.trialType==1), find(array.meta.trialCorrect==0));
    FA = intersect(find(array.meta.trialType==0), find(array.meta.trialCorrect==0));
    CR = intersect(find(array.meta.trialType==0), find(array.meta.trialCorrect==1));
    
    lix = zeros(array.k,1);
    lix([hit FA])= 1;
    gng = array.meta.trialType;
    
    motors = normalize_var(array.meta.motorPosition,-1,1)';
    
    [numTouches, ~] = preDecisionTouchFeatures(array,preDecisionMask{rec},1,touchDirection,touchOrder);
    
    [sortedbyTouch] = binslin(numTouches,[lix gng'],'equalE',17,-.5,15.5);
    [sortedbyPole] = binslin(motors,[numTouches' lix gng'],'equalE',11,-1.1,1.1);
    
    
    golicktmp = [];
    nogolicktmp = [];
    for d = 1:length(sortedbyPole)
        ttype = sortedbyPole{d}(:,3);
        lp = sortedbyPole{d}(:,2);
        meanNormPole = sortedbyPole{d}(:,1)-mean(sortedbyPole{d}(:,1));
        if ~isempty(ttype==1)
            golicktmp = [golicktmp; [meanNormPole(ttype==1) lp(ttype==1)]];
        end
        if ~isempty(ttype==0)
            nogolicktmp = [nogolicktmp; [meanNormPole(ttype==0) lp(ttype==0)]];
        end
    end
    
    gosorted = binslin(golicktmp(:,1),golicktmp(:,2),'equalE',7,-5.5,5.5);
    nogosorted = binslin(nogolicktmp(:,1),nogolicktmp(:,2),'equalE',7,-5.5,5.5);
    
    

    %find lick prob based on ttype at each bin of touch counts
    golicktmp = nan(length(sortedbyTouch),1);
    nogolicktmp = nan(length(sortedbyTouch),1);
    for b = 1:length(sortedbyTouch)
        if ~isempty(sortedbyTouch{b})
            ttype = sortedbyTouch{b}(:,2);
            lp = sortedbyTouch{b}(:,1);
            if ~isempty(ttype==1)
                golicktmp(b) = mean(lp(ttype==1));
            end
            if ~isempty(ttype==0)
                nogolicktmp(b) = mean(lp(ttype==0));
            end
        end
    end
    
    goLick(:,rec) = golicktmp;
    nogoLick(:,rec) = nogolicktmp;
    
    goPoleLick(:,rec) = cellfun(@nanmean,gosorted); 
    nogoPoleLick(:,rec) = cellfun(@nanmean,nogosorted); 
    
    goTouches(:,rec) = histcounts(numTouches(gng==1),linspace(-.5,15.5,17),'normalization','probability');
    nogoTouches(:,rec) = histcounts(numTouches(gng==0),linspace(-.5,15.5,17),'normalization','probability');
end
%% fig 5a
gocibins = nan(size(goLick,1),1);
nogocibins = nan(size(nogoLick,1),1);

goSEM = nanstd(goLick,[],2)./ sqrt(sum(~isnan(goLick),2));
for i = 1:size(goLick,1)
    x = goLick(i,:); 
    SEM = goSEM(i); 
    ts = tinv([0.025  0.975],sum(~isnan(x),2)-1);      % T-Score
    gocibins(i,:) = ts(2).*SEM;   %confidence intervals
end

nogoSEM = nanstd(nogoLick,[],2)./ sqrt(sum(~isnan(nogoLick),2));
for i = 1:size(nogoLick,1)
    x = nogoLick(i,:); 
    SEM = nogoSEM(i); 
    ts = tinv([0.025  0.975],sum(~isnan(x),2)-1);      % T-Score
    nogocibins(i,:) = ts(2).*SEM;   %confidence intervals
end

gomean = nanmean(goLick,2);
nogomean = nanmean(nogoLick,2);

figure(51);clf 
subplot(1,2,1);
bar(0:15,nanmean(goTouches,2),'b')
hold on; bar(0:15,nanmean(nogoTouches,2),'r')


hold on;shadedErrorBar(0:15,gomean,gocibins,'b')
hold on; shadedErrorBar(0:15,nogomean,nogocibins,'r')
set(gca,'ytick',0:.5:1,'xtick',0:5:15,'ylim',[0 1],'xlim',[-.5 15.5])


axis square
%% fig 5b
gocibins = nan(size(goPoleLick,1),1);
nogocibins = nan(size(nogoPoleLick,1),1);

goSEM = nanstd(goPoleLick,[],2) ./ sqrt(sum(~isnan(goPoleLick),2)); 
for i = 1:size(goPoleLick,1)
    x = goPoleLick(i,:); 
    SEM = goSEM(i); 
    ts = tinv([0.025  0.975],sum(~isnan(x),2)-1);      % T-Score
    gocibins(i,:) = ts(2).*SEM;   %confidence intervals
end

nogoSEM = nanstd(nogoPoleLick,[],2) ./ sqrt(sum(~isnan(nogoPoleLick),2)); 
for i = 1:size(nogoPoleLick,1)
    x = nogoPoleLick(i,:); 
    SEM = nogoSEM(i); 
    ts = tinv([0.025  0.975],sum(~isnan(x),2)-1);      % T-Score
    nogocibins(i,:) = ts(2).*SEM;   %confidence intervals
end



gopolemean = nanmean(goPoleLick,2);
nogopolemean = nanmean(nogoPoleLick,2);

subplot(1,2,2);
hold on;shadedErrorBar(linspace(-5,5,6),gopolemean,gocibins,'b')
hold on; shadedErrorBar(linspace(-5,5,6),nogopolemean,nogocibins,'r')
axis square
set(gca,'xlim',[-5 5],'xtick',-5:5:5,'ylim',[0 1],'ytick',0:.5:1)

suptitle('5a/b : touchNumber X lick probability (mean+/-95CI)')


set(gcf, 'Units', 'pixels', 'Position', [250, 250, 1000, 600]);



