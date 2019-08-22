function predictionMatrix = outcomes_heatmap(data_array,motorXpreds)
% This function is used to build the heatmap of inputs and outputs of the
% model as seen in Figure 7G and SFig 3 for Cheung et al. 2019.
%
% INPUTS: 
% data_array = wrapped data structure
% motorXpreds = outcome from master_classifier_builder
%
% OUTPUTS:
% predictionMatrix for comparing between counts+hilbert component models. 
%
% Date edited: 190625 by Jonathan Cheung 

%% USING MOTORxPREDS to build a full recreation of predictions for the session
ttpredMat = cell(numel(data_array),1); 
all_trial_mat = cell(numel(data_array),1); 
features = fields(motorXpreds);
preDecisionMask = preDecisionTouchMat(data_array);

for i = 1:length(data_array)
    
    %Calculate prediction probability difference between lick/nolick
    for d =1:length(features)
        ref = motorXpreds.countsangle{i};
        test = motorXpreds.(features{d}){i};
        

        %since predicted multiple times, we need to get average prediction
        %at each ple positoin 
        uniqueMotor = unique(test(:,1));
        uTest = nan(length(uniqueMotor),4);
        for r=1:length(uniqueMotor)
            matchIdx = find(test(:,1)==uniqueMotor(r));
            uTest(r,:) = mean(test(matchIdx,:),1);
        end
        
        uniqueMotor = unique(ref(:,1));
        uRef = nan(length(uniqueMotor),4);
        for r=1:length(uniqueMotor)
            matchIdx = find(ref(:,1)==uniqueMotor(r));
            uRef(r,:) = mean(ref(matchIdx,:),1);
        end
        
        %find trial intersections between reference and test feature using
        %motor position
        %motors = motor positions accounted for
        if ismember(uRef(:,1),uTest(:,1))==1
            [motors,itest] = sort(uTest(:,1));
        else
            [motors,~,itest] = intersect(uRef(:,1),uTest(:,1));
        end
        
        testprobs = uTest(itest,3) - uTest(itest,2);

%          rawMotors = unique(data_array{i}.meta.motorPosition);
         rawMotorsTMP = data_array{i}.meta.motorPosition;

        ib = ismember(sort(rawMotorsTMP),motors);
        

        ttpredMat{i}(:,d) = testprobs;
    end
    
    

    %NORMALIZE POLE POSITIONS 
%     [rawMotors,motorSortIdx] = sort(unique(data_array{i}.meta.motorPosition)); 
    [rawMotors,motorSortIdx] = sort(data_array{i}.meta.motorPosition); 
    dBound = mean(data_array{i}.meta.ranges);
    rawngPoles = normalize_var([data_array{i}.meta.ranges(1) ; rawMotors(rawMotors<dBound)'],1,0);
    rawngPoles = rawngPoles(2:end);
    rawgPoles = normalize_var([rawMotors(rawMotors>dBound)' ; data_array{i}.meta.ranges(2)],0,-1);
    rawgPoles = rawgPoles(1:end-1);
    poprawPoles = [rawngPoles ; rawgPoles]; 
    
    dBound = mean(data_array{i}.meta.ranges);
    ngPoles = normalize_var([data_array{i}.meta.ranges(1) ; motors(motors<dBound)],1,0);
    ngPoles = ngPoles(2:end);
    gPoles = normalize_var([motors(motors>=dBound) ; data_array{i}.meta.ranges(2)],0,-1);
    gPoles = gPoles(1:end-1);
     poles = [ngPoles;gPoles];
     
    %INSERT TRIALS THAT ARE DOUBLED UP
    if ~(sum(ib)==length(motors))
        sortedMotors = sort(rawMotorsTMP);
        dbldMotorPos = sortedMotors(find(diff(sort(sortedMotors))==0));
        if sum(dbldMotorPos == uniqueMotor)==1
            matchedIdx = find(dbldMotorPos == uniqueMotor);
            toInsert = ttpredMat{i}(matchedIdx,:);
            polesInsert = poles(matchedIdx);
            
            ttpredMat{i}=  [ttpredMat{i}(1:matchedIdx-1,:) ; toInsert ; ttpredMat{i}(matchedIdx:end,:)];
            poles = [poles(1:matchedIdx-1) ; polesInsert ; poles(matchedIdx:end)];
        end
    end

    %find lickTrials
    hits = intersect(find(data_array{i}.meta.trialType==1),find(data_array{i}.meta.trialCorrect==1));
    FA = intersect(find(data_array{i}.meta.trialType==0),find(data_array{i}.meta.trialCorrect==0));
    lickvect = ones(1,length(data_array{i}.meta.trialType==0)) ;
    lickvect([hits FA])=-1;
    lickvect = lickvect(motorSortIdx);
    
    ttype = data_array{i}.meta.trialType(motorSortIdx);
    ttpredMat{i} = [ttpredMat{i} lickvect(ib)' (ttype(ib)==0)' poles];
    
    %ADDING IN NON-TOUCH TRIALS
    all_trial_mat{i} = nan(length(poprawPoles),size(ttpredMat{i},2));
    ttrials = ismember(rawMotors,motors); 
    nttrials = ~ttrials; 
    all_trial_mat{i}(ttrials,:) = ttpredMat{i};
%     all_trial_mat{i}(nttrials,:) = [ones(sum(nttrials),length(features)) lickvect(nttrials)' (ttype(nttrials)==0)' abs(poprawPoles(nttrials))<.2 poprawPoles(nttrials)];
    all_trial_mat{i}(nttrials,:) = [ones(sum(nttrials),length(features)) lickvect(nttrials)' (ttype(nttrials)==0)'  poprawPoles(nttrials)];
    all_trial_mat{i}(:,end+1) = nttrials';
    
    %ADDING IN RETRACTION-TOUCH TRIALS
    [preD_touches_pro] = preDecisionTouchFeatures(data_array{i},preDecisionMask{i},1,'pro','all');
    [preD_touches_ret] = preDecisionTouchFeatures(data_array{i},preDecisionMask{i},1,'ret','all');
    
    bidir_touch_trial = intersect(find(preD_touches_pro>0),find(preD_touches_ret>0));
    preD_touches_ret(bidir_touch_trial)=0;
    only_ret_touch_trials = preD_touches_ret>0;
    only_ret_touch_trials = only_ret_touch_trials(motorSortIdx);

    %FILLS
%     draws = binornd(1,retLickProb(i),[sum(only_ret_touch_trials) 1]);
    toFill =  all_trial_mat{i}(only_ret_touch_trials,1:length(features)); 
    all_trial_mat{i}(only_ret_touch_trials,1:length(features)) = ones(size(toFill))*-1; 
%     
    %Add column for retraction touches only 
    all_trial_mat{i}(only_ret_touch_trials,length(features)+4)=-1;
    
    
    
    retLickProb(i)=mean(all_trial_mat{i}(only_ret_touch_trials,length(features)+2)==-1);
    proportion_ret_only(i) = mean(only_ret_touch_trials);
    
end

predictionMatrix.columnNames = {'phaseCounts_predictions','ampCounts_predictions','midpointCounts_predictions','angleCounts_predictions','choice','gonogo','polePositions','touchType'};
predictionMatrix.touch_trials_matrix = ttpredMat;
predictionMatrix.all_trials_matrix = all_trial_mat;

selMats = fields(predictionMatrix);
for g = 2:3
    
    for d = 1:length(predictionMatrix.(selMats{g}))
        currMat = predictionMatrix.(selMats{g}){d};
        
        allTrials = 1:length(currMat);
%         hardTrials = find(currMat(:,length(features)+3)==1);
        
        true = double(currMat(allTrials,length(features)+1)==1);
        testMats = double(currMat(allTrials,1:length(features))>0);
        
        for b = 1:size(testMats,2)
            
            cmat = confusionmat(true,testMats(:,b));
            TP = cmat(1);FP = cmat(3);
            TN = cmat(4);FN = cmat(2);
            %MCC
            top  = TP*TN - FP*FN;
            bottom = sqrt((TP+FP) * (TP+FN) * (TN+FP)* (TN+FN));
            predictionMatrix.mcc.(selMats{g})(d,b) = top./bottom;
            if isnan(predictionMatrix.mcc.(selMats{g})(d,b))
                predictionMatrix.mcc.(selMats{g})(d,b) = 0 ;
            end
            %Percent Correct
            predictionMatrix.accuracy.(selMats{g})(d,b) = mean(true == testMats(:,b));
        end

    end
end


figure(55);clf
% tempMap = [0 0 0; 0 0 1; 1 0 0]
for i = 1:15
    subplot(3,5,i)
    imagesc(predictionMatrix.all_trials_matrix {i});
    set(gca,'ytick',[],'xtick',[])
    caxis([-1 1])
    colorbar
%     colormap(tempMap)
end