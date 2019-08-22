function [selLambdaIdx] = lambdaAnalysis(lambdatxp,indivMediansRaw)

%% LASSO MCC CALCULATOR
clear mcclambda
clear mcclambdasem

for i = 1:length(lambdatxp)
    cmatcurr = lambdatxp{i};
    for rec = 1:length(cmatcurr)
        currMat = cmatcurr{rec};
        tmp=find(currMat(:,1)==2);
        endIndices = tmp(logical([diff(tmp)>5;1])); %iffy... we used a hard value of 5 YIKES. THIS MIGHT BREAK. Need to find a remedy
        startIndices = [1;endIndices(1:end-1)+1];
        for u = 1:length(endIndices)
            currMatraw = currMat(startIndices(u):endIndices(u),:);
            cmat = confusionmat(currMatraw(:,1),currMatraw(:,2));
            TP = cmat(1);FP = cmat(3);
            TN = cmat(4);FN = cmat(2);
            top  = TP*TN - FP*FN;
            bottom = sqrt((TP+FP) * (TP+FN) * (TN+FP)* (TN+FN));
            mcctmp(u) = top./bottom;
            if isnan(mcctmp(u))
                mcctmp(u) = 0 ;
            end
        end
        
        meanMCC(rec) = mean(mcctmp);
        semMCC(rec) = std(mcctmp)./ length(startIndices);
    end
    
    mcclambda(i,:) = meanMCC;
    mcclambdasem(i,:) = semMCC;
end

[~,matmax] = max(mcclambda);
[~,minIdx] = min(abs(mcclambda- (max(mcclambda) - diag(mcclambdasem(matmax,1:size(mcclambda,2)))')));
selLambdaIdx = round(mean([matmax;minIdx]));
lambda = loadLambda;

figure(50);clf
for z=1:size(mcclambda,2)
    smoothY = smooth(mcclambda(:,z));
%     hold on; plot(lambda,smoothY,'k')
    hold on; errorbar(lambda,smoothY,mcclambdasem(:,z),'ko-')
    hold on; scatter(lambda(selLambdaIdx(z)),smoothY(selLambdaIdx(z)),'r','filled')
    hold on; scatter(lambda(matmax(z)),smoothY(matmax(z)),'g','filled')
    hold on; scatter(lambda(minIdx(z)),smoothY(minIdx(z)),'b','filled')
end
set(gca,'xscale','log','ytick',[0:.25:1],'xlim',[0 max(lambda)])
xlabel('lambda')
ylabel('mcc')


%% LASSO WEIGHTS 
figure(90);clf
gnormMat = zeros(size(indivMediansRaw{1}));
for k = 1:length(indivMediansRaw)
    
    currMat = indivMediansRaw{k};
    
    %This section for capping extremely high and low values
    %Can bypass to plot raw values
    tenp = round(length(currMat(:))*.10);
    ninetyp = round(length(currMat(:))*.85);
    tmp = sort(currMat(:));
    minNum = tmp(tenp);
    maxNum = tmp(ninetyp);
    currMat(currMat<minNum)=minNum;
    currMat(currMat>maxNum)=maxNum;
%     
    
    normMat = normalize_var(abs(currMat(:)),0,1) .* sign(currMat(:));
    reNormMat = reshape(normMat,size(currMat));
    figure(90);subplot(3,5,k)
    for d = 1:size(currMat,2)
        hold on;plot(lambda,smooth(reNormMat(:,d),10))
%         hold on;plot(lambda,reNormMat(:,d))
    end
    hold on; plot([lambda(selLambdaIdx(k)) lambda(selLambdaIdx(k))],[-1 1],'-.k')
    set(gca,'xscale','log','xlim',[0 max(lambda)],'ylim',[-1 1])
    
    gnormMat = gnormMat+reNormMat;
end

%GROUP WEIGHT
gnormMat = gnormMat./15;
normMat = normalize_var(abs(gnormMat(:)),0,1) .* sign(gnormMat(:));
regnormMat = reshape(normMat,size(gnormMat));

figure(575);clf
for t = 1:size(gnormMat,2)
    hold on; plot(lambda,smooth(regnormMat(:,t),10))
%     hold on; plot(lambda,regnormMat(:,t));
end
meanOptLambda = round(mean(selLambdaIdx));
plot([lambda(meanOptLambda) lambda(meanOptLambda)],[-1 1],'-.k')
set(gca,'xscale','log','xlim',[0 max(lambda)],'ylim',[-1 1],'ytick',[-1:.5:1])