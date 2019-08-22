function [optLambda] = optimalLambda(V,U,params,learnparam)
for z = 1:length(learnparam.lambda)
    display(['iterating w/ lambda ' num2str(learnparam.lambda(z)) '. ' 'value ' num2str(z) '/' num2str(length(learnparam.lambda))])
    clear Bfeat
    for rec = 1:length(U)
        
        [DmatX, DmatY, motorX] = designMatrixBuilder_v4(V(rec),U{rec},params);
        
        if strcmp(learnparam.biasClose,'yes')
            mean_norm_motor = motorX - mean(U{rec}.meta.ranges);
            close_trials = find(abs(mean_norm_motor)<learnparam.distance_round_pole*10000);
            DmatX = DmatX(close_trials,:);
            DmatY = DmatY(close_trials,:);
        end
        
        g1 = DmatY(DmatY == 1);
        g2 = DmatY(DmatY == 2);
        
        g1cvInd = crossvalind('kfold',length(g1),learnparam.cvKfold );
        g2cvInd = crossvalind('kfold',length(g2),learnparam.cvKfold );
        
        % shuffle permutations of cv indices
        g1cvInd = g1cvInd(randperm(length(g1cvInd)));
        g2cvInd = g2cvInd(randperm(length(g2cvInd)));
        
        selInds = [g1cvInd ;g2cvInd];
        
        clear opt_thresh
        txp = [];
        for u=1:learnparam.cvKfold
            testY = [DmatY(selInds==u)];
            testX = [DmatX(selInds==u,:)];
            trainY = [DmatY(~(selInds==u))];
            trainX = [DmatX(~(selInds==u),:)];
            
            [thetas,~,~] = ML_oneVsAll(trainX, trainY, numel(unique(DmatY)), learnparam.lambda(z), learnparam.regMethod);
            Bfeat{rec}.theta{u}=thetas;
            
            [pred,~,~]=ML_predictOneVsAll(thetas,testX,testY,'Max');
            
            txp = [txp ; testY pred];
        end
        
        poptxp{rec} = txp;
    end
    
    %Raw truths and predictions: use this to calculate MCC, F1 scores,
    %etc...
    lambdatxp{z} = poptxp;
    
    
    clear feats
    clear oddsR
    
    for rec = 1:length(Bfeat)
        ms=cell2mat(Bfeat{rec}.theta);
        feats{rec} = reshape(ms(1,:)',size(DmatX,2)+1,learnparam.cvKfold);
    end
    
    for g = 1:length(Bfeat)
        for b = 1:learnparam.cvKfold
            xv = feats{g}(2:end,b);
            pn = sign(xv);
            oddsR{g}(:,b)=exp(pn.*xv).*pn;
        end
        
        oddsR{g}(isinf(oddsR{g})) = nan;
        
        group = [zeros(1,size(oddsR{g},2));oddsR{g}];
        sg = sign(group);
        nsg = normalize_var(abs(group),0,1) .* sg;
%         indivMedians{g}(z,:) = nanmean(nsg(2:end,:),2);       
        indivMediansRaw{g}(z,:) = nanmedian(abs(oddsR{g}) .* (oddsR{g}./abs(oddsR{g})),2);
        
    end
    
    
end

[selLambdaIdx] = lambdaAnalysis(lambdatxp,indivMediansRaw);
optLambda = learnparam.lambda(selLambdaIdx);