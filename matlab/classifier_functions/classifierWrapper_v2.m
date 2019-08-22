% Function for wrapping necessary variables for the logistic classifier.
% Takes the uber array and a couple other functions to output a struct with
% all desired predecision touch variables

%INPUT: uber array
%OUTPUT: V array which is a struct for all predecision touch variables

function [V] = classifierWrapper_v2(uberarray,touchDirection,touchOrder)

preDecisionMask = preDecisionTouchMat(uberarray);

for rec = 1:length(uberarray)
    
    array=uberarray{rec};

    
    hit = intersect(find(array.meta.trialType==1), find(array.meta.trialCorrect==1));
    miss = intersect(find(array.meta.trialType==1), find(array.meta.trialCorrect==0));
    FA = intersect(find(array.meta.trialType==0), find(array.meta.trialCorrect==0));
    CR = intersect(find(array.meta.trialType==0), find(array.meta.trialCorrect==1));
    
    
    V(rec).varNames = {'theta','velocity','amplitude','setpoint','phase','deltaKappa','timing.timetotouch/startTheta/whiskcycleVelocity','torsionBytheta','maxProtraction','pOnset:firsttouch(ms)','RadialDistance'};
    

    varx=[1:5 17];
    % TOUCH VARIABLES AND TOUCH COUNT
    for variableNumber=1:length(varx)
        
        [numTouches, meanFeature] = preDecisionTouchFeatures(array,preDecisionMask{rec},varx(variableNumber),touchDirection,touchOrder);
 
        meanFeature = nanmean(meanFeature);
        
       if variableNumber == 1
            V(rec).touchNum.hit=numTouches(hit); % count number of predecision touches using theta vals
            V(rec).touchNum.miss=numTouches(miss);
            V(rec).touchNum.FA=numTouches(FA);
            V(rec).touchNum.CR=numTouches(CR);
        end
        
        V(rec).var.hit{variableNumber}   =     meanFeature(hit);
        V(rec).var.miss{variableNumber}  =     meanFeature(miss);
        V(rec).var.FA{variableNumber}    =     meanFeature(FA);
        V(rec).var.CR{variableNumber}    =     meanFeature(CR);
        
    end
    
    % Average radial distance at touch
    [outputs] = radialDistance(array,preDecisionMask{rec});
    V(rec).var.hit{11} = [outputs{1}];
    V(rec).var.FA{11} = [outputs{2}];
    V(rec).var.CR{11} = [outputs{3}];
    V(rec).var.miss{11} = [outputs{4}];
    
    % FINDING TIMES FROM POLE ONSET TO FIRST TOUCH
%     [ttimes] = onsetTotouch(array);
    poleOnsetT = round(array.meta.poleOnset*1000); 
    cueToTouchMat = nan(array.k,1); 
    ftPreDecision = squeeze(array.S_ctk(9,:,:)) .* preDecisionMask{rec};
    [row,col] = find(ftPreDecision==1);
    cueToTouchMat(col) = (row - poleOnsetT(col)') ;
    
    
    V(rec).var.hit{10} = [cueToTouchMat(hit) hit'];
    V(rec).var.FA{10} = [cueToTouchMat(FA) FA'];
    V(rec).var.CR{10} = [cueToTouchMat(CR) CR'];
    V(rec).var.miss{10} = [cueToTouchMat(miss) miss'];
    
    % FINDING TIMES FROM WHISK ONSET TO TOUCH FOR TOUCHES
    [hx,FAx,CRx,mx] = touchTimeDecomp(array,touchOrder);
    V(rec).var.hit{7} = [hx];
    V(rec).var.FA{7} = [FAx];
    V(rec).var.CR{7} = [CRx];
    V(rec).var.miss{7} = [mx];
    
    % FINDING KAPPA DURING FREE WHISK FOR TTYPES
    %         [kappaattheta,tnumskt] = uber_rollmodel(array);
    %         V(rec).var.hit{8} = [kappaattheta{1} tnumskt{1}];
    %         V(rec).var.FA{8} = [kappaattheta{2} tnumskt{2}];
    %         V(rec).var.CR{8} = [kappaattheta{3} tnumskt{3}];
    %         V(rec).var.miss{8} = [kappaattheta{4} tnumskt{4}];
    
    %MAX PROTRACTION PRE DECISION
    [hitmaxp,missmaxp,FAmaxp,CRmaxp] = maxProtractionPreD(array);
    V(rec).var.hit{9} = hitmaxp;
    V(rec).var.FA{9} = FAmaxp;
    V(rec).var.CR{9} = CRmaxp;
    V(rec).var.miss{9} = missmaxp;
    %
    % TRIAL TYPE ORGANIZATION
    V(rec).trialNums.matNames = {'hit','miss','FA','CR','licks','lick and hit'};
    V(rec).trialNums.matrix = zeros(5,array.k);
    V(rec).trialNums.matrix(1,find(array.meta.trialType == 1 & array.meta.trialCorrect ==1))= 1; %hit trials
    V(rec).trialNums.matrix(2,find(array.meta.trialType == 1 & array.meta.trialCorrect ==0))= 1; %miss trials
    V(rec).trialNums.matrix(3,find(array.meta.trialType == 0 & array.meta.trialCorrect ==0))= 1; % FA trials
    V(rec).trialNums.matrix(4,find(array.meta.trialType == 0 & array.meta.trialCorrect ==1))= 1; %CR trials
    V(rec).trialNums.matrix(5,:) = sum(V(rec).trialNums.matrix([1 3],:)); %lick trials 
    V(rec).trialNums.matrix(6,:) = sum(V(rec).trialNums.matrix([1 5],:))==2; %lick and hit trials
    
    
    
    %
    %     %figuring out previous TT and whether it was lick or not
    %     lix{1} = [0 V(rec).trialNums.matrix(6,:)]; %padded with 0 to account for indexing
    %     lix{2} = [0 0 V(rec).trialNums.matrix(6,:)];
    %     lix{3} = [0 0 0 V(rec).trialNums.matrix(6,:)];
    %
    %     hx_prevT = find(V(rec).trialNums.matrix(1,:)==1); % using current T num b/c licks shifted by padded 0
    %     mx_prevT = find(V(rec).trialNums.matrix(2,:)==1);
    %     FAx_prevT = find(V(rec).trialNums.matrix(3,:)==1); % using current T num b/c licks shifted by padded 0
    %     CRx_prevT = find(V(rec).trialNums.matrix(4,:)==1); % using current T num b/c licks shifted by padded 0
    %
    %     Ttype = {'hit','miss','FA','CR'};
    %     Ttypemat={hx_prevT,mx_prevT,FAx_prevT,CRx_prevT};
    %
    %     for d = 1:length(Ttype)
    %         V(rec).licks.oneT.(Ttype{d}) = lix{1}(Ttypemat{d});
    %         V(rec).licks.twoT.(Ttype{d}) = lix{2}(Ttypemat{d});
    %         V(rec).licks.threeT.(Ttype{d}) = lix{3}(Ttypemat{d});
    %     end
    %
    
    V(rec).name = array.meta.layer;
    
    % MAX PROTRACTION POLE AVAIL:LICK... UNFINISHED. NOT SURE IF ITLL BE
    % USEFUL
    %     [P] = findMaxProtraction(array,'avail2lick');
    % tmp = {'hit','miss','FA','CR'};
    %     inputs = {hx_prevT,mx_prevT,FAx_prevT,CRx_prevT};
    %     for g = 1:length(tmp) %for trial types...
    %     V(rec).maxProt.(tmp{g}){1} = []; V(rec).maxProt.(tmp{g}){3} = [];
    %     V(rec).maxProt.(tmp{g}){4} = []; V(rec).maxProt.(tmp{g}){5} = [];
    %
    %         for k = 1:length(inputs{g}) %for number of T within trial types...
    %         d = inputs{g}(k); %for specific trial number...
    %     V(rec).maxProt.(tmp{g}){1}(k) = min([max(P.theta(P.trialNums==d)) array.t]);%max theta protraction in each cycle
    %     test(k) = median(P.theta(P.trialNums==d));
    %
    % %     V(rec).maxProt.(tmp{g}){3} = [V(rec).maxProt.(tmp{g}){3} ;P.amp(P.trialNums==d)];
    % %     V(rec).maxProt.(tmp{g}){4} = [V(rec).maxProt.(tmp{g}){4}; P.setpoint(P.trialNums==d)];
    % %     V(rec).maxProt.(tmp{g}){5} = [V(rec).maxProt.(tmp{g}){5}; P.phase(P.trialNums==d)];
    %          end
    %     end
    
    
    
    
    
    
    
    
    
end