clear
load('C:\Users\jacheung\Dropbox\LocalizationBehavior\DataStructs\publication\behavioral_structure.mat')
[V] = classifierWrapper_v2(BV,'all','all'); %inputs = uberarray | touchDirection | touchOrder

%% PARAMETERS SETTING
clearvars -except BV V
% var_set = {'countsBinary','counts'}; %Fig 3 %BUILD WITH ALL TOUCH DIRECTIONS AND NO drop
% var_set = {'curvature','cueTiming','whiskTiming','counts','radialD','angle'}; %FIG4G
% var_set = {'motor','curvature','cueTiming','whiskTiming','counts','radialD','angle','combined'}; %Fig 4H

% Fig 7 PROTRACTION ONLY BECAUSE OF PHASE IN HILBERT DECOMPOSITION
% var_set = {'angle','hilbert'} %Fig 7CD
% var_set =  {'phase','amp','midpoint','angle'}; %Fig7E
% var_set = {'countsphase','countsamp','countsmidpoint','countsangle'}; %fig 7FGH

var_set = {'countsmidpoint','countsangle'}; %Fog 7IJ

mdl = []; %starting w/ clean structure 
savedLambdas = nan(length(V),length(var_set));

for var_set_number = 1:length(var_set)
    
    %designMatrix Parameters
    params.designvars = var_set{var_set_number};
    % 1) 'angle' 2) 'hilbert' (phase amp midpoint) 3) 'counts' 4) 'ubered'
    % 5) 'timing' 6) 'motor' 7) 'decompTime' OR ,'kappa'
    % 'timeTotouch','onsetangle','velocity','Ivelocity' OR 'phase','amp','midpoint'
    
    params.classes = 'gonogo';
    % 1) 'gonogo' 2) 'lick'
    
    % Only for 'ubered' or 'hilbert'
    params.normalization = 'meanNorm';
    % 1) 'whiten'  2) 'meanNorm' 3)'none'
    
    params.dropNonTouch = 'yes';
    % 1) 'yes' = drop trials with 0 touches
    % 2) 'no' = keep all trials
    
    [DmatX, ~, ~] = designMatrixBuilder_v4(V(1),BV{1},params);
    
    %learning parameters
    learnparam.regMethod = 'lasso'; % 'lasso' or L1 regularization or 'ridge' or L2 regularization;
    learnparam.lambda = loadLambda;

    learnparam.cvKfold = 5;
    learnparam.biasClose = 'no';
    learnparam.distance_round_pole =2; %inmm. Only active if biasClose is on. 
    learnparam.numIterations = 20; 
    
    if size(DmatX,2)>1
        if sum(~isnan(savedLambdas(:,var_set_number)))==0
            [optLambda] = optimalLambda(V,BV,params,learnparam);
            savedLambdas(:,var_set_number) = optLambda;
            learnparam.lambda = optLambda;
        else
            learnparam.lambda = savedLambdas(:,var_set_number);
        end
    else
        learnparam.lambda = zeros(1,length(BV));
    end
    
    %% LOG CLASSIFIER
    
    for rec = 1:length(V)

        [DmatX, DmatY, motorX] = designMatrixBuilder_v4(V(rec),BV{rec},params); %lick/go = 1, nolick/nogo = 2;
        
        clear opt_thresh
        motorPlick = [];
        motorPlickWithPreds = [];
        txp = [];
        
        for f = 1:learnparam.numIterations  
            display(['iteration ' num2str(f) ' for sample ' num2str(rec) ' using optimal lambda ' num2str(learnparam.lambda(rec))])
            if strcmp(learnparam.biasClose,'yes')
                mean_norm_motor = motorX - mean(BV{rec}.meta.ranges);
                close_trials = find(abs(mean_norm_motor)<learnparam.distance_round_pole*10000);
                DmatX = DmatX(close_trials,:);
                DmatY = DmatY(close_trials,:);
            end
            
            g1 = DmatY(DmatY == 1);
            g2 = DmatY(DmatY == 2);
            
            g1cvInd = crossvalind('kfold',length(g1),learnparam.cvKfold);
            g2cvInd = crossvalind('kfold',length(g2),learnparam.cvKfold);
            
            % shuffle permutations of cv indices
            g1cvInd = g1cvInd(randperm(length(g1cvInd)));
            g2cvInd = g2cvInd(randperm(length(g2cvInd)));
            
            selInds = [g1cvInd ;g2cvInd];
            
            for u=1:learnparam.cvKfold
                testY = [DmatY(selInds==u)];
                testX = [DmatX(selInds==u,:)];
                trainY = [DmatY(~(selInds==u))];
                trainX = [DmatX(~(selInds==u),:)];
                
                [beta,~,~] = ML_oneVsAll(trainX, trainY, numel(unique(DmatY)), learnparam.lambda(rec), learnparam.regMethod);
                weights.(var_set{var_set_number}){rec}.theta{u}=beta;
                
                [pred,opt_thresh(u),prob]=ML_predictOneVsAll(beta,testX,testY,'Max');
                
                motorPlick= [motorPlick;motorX(selInds==u) prob(:,1)];
                motorPlickWithPreds= [motorPlickWithPreds ; motorX(selInds==u) prob pred];
                txp = [txp ; motorX(selInds==u) testY pred];
            end
        end
            mdl.input.(var_set{var_set_number}).DmatX{rec} = DmatX;
            mdl.input.(var_set{var_set_number}).DmatY{rec} = DmatY;
            mdl.input.(var_set{var_set_number}).motor{rec} = motorX; 
            
            mdl.output.true_preds.(var_set{var_set_number}){rec} = txp;
            mdl.output.motor_preds.(var_set{var_set_number}){rec} = motorPlickWithPreds;
            mdl.output.decision_boundary.(var_set{var_set_number}){rec} = mean(opt_thresh); %used for dboundaries
    end
    
    % Model Outputs; 
    mdl.build_params = params; %build parameters 
    mdl.learn_params = learnparam; %model learn parameters
    mdl.output.weights = weights; %model weights
    
end

if strcmp(mdl.build_params.designvars,'combined')
    mdl.input.combined.column_def = {'curvature', 'cue timing','whisk timing','touch count','radial','angle'};
end
mdl.build_params.designvars = var_set;

