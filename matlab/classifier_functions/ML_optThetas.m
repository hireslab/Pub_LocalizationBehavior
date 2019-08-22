% feed me T, contacts, and params for one good session and this'll output
% best thetas for logistic classifier of new contact arrays. Works best
% maybe for one single session? 

function [OPTIMALTHETAS] = ML_optThetas(T,contacts,params)

%trainData
y = cell(length(T.trials),1);
x = y;

for trl=1:length(T.trials)
    
    
    % ouput
    if ~isempty(contacts{trl});
        recTimes = length(T.trials{trl}.whiskerTrial.time{1});
        y{trl} = ones(recTimes,1);
        tps=contacts{trl}.contactInds{1};
        y{trl}(tps,1)=2;
    
    % input
    
    x{trl} = zeros(recTimes,3);
    
    pavail=([T.trials{trl}.pinDescentOnsetTime T.trials{trl}.pinAscentOnsetTime].*1000);
    if pavail(2)>=recTimes
        pavail(2)=recTimes;
    end
    pavail=round(pavail);
    
    x{trl}(pavail(1):pavail(2),1)=1; %pole availability
    x{trl}(:,2)= T.trials{trl}.whiskerTrial.distanceToPoleCenter{1}; %distance to pole
    x{trl}(:,3)= T.trials{trl}.whiskerTrial.meanKappa{1}; %mean Kappa at each tp
    end
end


numIterations = 5;
sample = 'bias';
%% LOG CLASSIFIER
accprop = []

DmatX = cell2mat(x); DmatY = cell2mat(y);
nanrows=find(sum(isnan(DmatX),2)==1);
DmatX(nanrows,:)=[];DmatY(nanrows,:)=[];
% DmatX=filex_whiten(DmatX);

    g1 = DmatY(DmatY == 1);
    g2 = DmatY(DmatY == 2);
   
    
    for reit = 1:numIterations
        rando = randperm(length(DmatX));
        tmpDmatX=DmatX(rando,:);tmpDmatY=DmatY(rando,:);

        switch sample
            case 'bias'
                %             %FOR FA VS CR
                %             sample evenly from FA and CR for training set
                g1counts = round(numel(g1)*.7);
                g2counts = round(numel(g2)*.7);
                g1s = find(tmpDmatY==unique(g1));
                g2s = find(tmpDmatY==unique(g2));
                train=[g2s(1:g2counts);g1s(1:g1counts)];
                
                normPAS = [1:length(tmpDmatY)]';
                normPAS(train)=[];
                
                [thetas,cost,~] = ML_oneVsAll(tmpDmatX(train,:),tmpDmatY(train,:),numel(unique(DmatY)),0);
                Bfeat.theta{reit}=thetas;
                
                [pred,opt_thresh(reit),prob]=ML_predictOneVsAll(thetas,tmpDmatX(normPAS,:)...
                    ,tmpDmatY(normPAS,:),'Max');
                Acc(reit)= mean(double(pred == tmpDmatY(normPAS))) * 100
                F1s(reit,:) = F1score(pred,tmpDmatY(normPAS),2);
                
                accprop=[accprop ; pred tmpDmatY(normPAS)];

        end
        
    end
%     trainF1sstd(:)=nanstd(nansum(F1s,2));
    train_predOpt=mean(opt_thresh); %used for dboundaries
    train_Acc = mean(Acc);
    train_std= std(Acc);
    
    tmp=cell2mat(Bfeat.theta);
    OPTIMALTHETAS=[mean(tmp(:,1:4:end),2) mean(tmp(:,2:5:end),2) mean(tmp(:,3:6:end),2) mean(tmp(:,4:8:end),2)];
