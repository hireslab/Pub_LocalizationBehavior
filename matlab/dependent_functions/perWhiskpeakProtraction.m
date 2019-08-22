function [ttwtheta_pretouch,ttwtheta] = perWhiskpeakProtraction(U)
% This function will find the peak protraction angle (relative to the
% discrimination boundary) for all whisks in a trial from cue onset.
% OUTPUT:
% :1) ttwtheta_pretouch: all whisks pre first touch and pre-decision
% :2) ttwtheta : all whisks in the trial pre-decision

%preallocated variables that will be outputed
ttwtheta = cell(1,length(U));
ttwtheta_pretouch = cell(1,length(U));

%optional variables of setpoint and amplitude at peak of whisk
ttwsp= cell(1,length(U));
ttwamp = cell(1,length(U));

for i = 1:length(U)
    [w] = findMaxMinProtraction(U{i},5,'avail2end');
    whisks(i) = w;
end

for i = 1:length(U)
    
    %Find the discrimination boundary wihsker angle
    ppoles = nan(U{i}.k,50);
    for b = 1:U{i}.k
        touchIdx = [find(U{i}.S_ctk(9,:,b)==1) find(U{i}.S_ctk(12,:,b)==1)];
        if ~isempty(touchIdx)
            tmpThetas = U{i}.S_ctk(1,touchIdx,b);
            ppoles(b,1:length(tmpThetas)) = tmpThetas;
            
        end
    end
    polyinputs = sortrows([U{i}.meta.motorPosition'  ppoles(:,1)]);
    polyinputs(isnan(polyinputs(:,2)),:)=[];
    [coeff, ~ , mu] = polyfit(polyinputs(:,1),polyinputs(:,2),2);
    
    dbtheta = polyval(coeff,mean(U{i}.meta.ranges),[],mu);
    
    %Converting whisk index into trial index
    whisks(i).whisktimes = mod(whisks(i).peakidx,U{i}.t);
    
    ttwtheta{i} = nan(U{i}.k,30);
    ttwsp{i} = nan(U{i}.k,30);
    ttwamp{i} = nan(U{i}.k,30);
    ttwtheta_pretouch{i} = nan(U{i}.k,30);
    
    % first lick and touch index
    pOnset = round(mean(U{i}.meta.poleOnset)*1000);
    answerPeriodOpening = pOnset+750; 
    for k = 1:U{i}.k
        lix(k) =min([find(U{i}.S_ctk(16,answerPeriodOpening:2500,k)==1,1) 2500])+answerPeriodOpening;
        touch(k) =min([find(U{i}.S_ctk(9,pOnset:2500,k)==1,1) 2500])+pOnset;
    end
    
    % for each trial find all whisks pre-first touch and pre-decision
    for k = 1:U{i}.k
        wtind = find(whisks(i).trialNums==k);
        keepidx =  whisks(i).whisktimes(wtind)<lix(k);% find all whisks pre-decision
        ttwtheta{i}(k,1:sum(keepidx)) = whisks(i).theta(wtind(keepidx))-dbtheta;
        ttwsp{i}(k,1:sum(keepidx)) = whisks(i).setpoint(wtind(keepidx)); %midpoint for each whisk
        ttwamp{i}(k,1:sum(keepidx)) = whisks(i).amp(wtind(keepidx)); % amplitude for each whisk
        
        keepidx_pretouch =  whisks(i).whisktimes(wtind)<lix(k) & whisks(i).whisktimes(wtind)<touch(k);
        ttwtheta_pretouch{i}(k,1:sum(keepidx_pretouch)) = whisks(i).theta(wtind(keepidx_pretouch))-dbtheta;
    end
    
    
end
