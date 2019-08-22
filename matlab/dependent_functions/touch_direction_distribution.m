uberarray = U
preDecisionMask = preDecisionTouchMat(uberarray);

for rec = 1:length(uberarray)
    
    array=uberarray{rec};

    varx=[1:5 17];
    % TOUCH VARIABLES AND TOUCH COUNT
    for variableNumber=5
        [numTouches, meanFeature] = preDecisionTouchFeatures(array,preDecisionMask{rec},variableNumber,'all','all');
    end
    
    protraction =  sum(meanFeature<0)>=1;
    retraction = sum(meanFeature>0)>=1;
    
    numMixed = intersect(find(protraction),find(retraction));
    protractionOnly = setdiff(find(protraction),find(retraction));
    retractionOnly = setdiff(find(retraction),find(protraction));
    totalTouchTrials = sum(numTouches>0);
    
    output.names = {'protraction','retraction','mixed'};
    output.values{rec} = [numel(protractionOnly) numel(retractionOnly) numel(numMixed)] ./ totalTouchTrials; 
     
end
% touch breakdown
tb = cell2mat(output.values');
figure(8);clf
errorbar(1:3,mean(tb),std(tb),'ko')
set(gca,'xlim',[0 4],'ylim',[0 1],'ytick',0:.25:1,'xtick',1:3,'xticklabel',{'pro only','ret only','mixed'})
ylabel('proportion of trials')