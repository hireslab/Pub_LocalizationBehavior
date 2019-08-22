function [preDecisionTouchIdx] = preDecisionTouchMat(U)

%preDecision Touches
preDecisionTouchIdx = cell(length(U),1);
for rec = 1:length(U)
    %params to start looking for lix
    poleOnset = round(mean(U{rec}.meta.poleOnset)*1000);
    samplingPeriod = 750;
    
    ft = squeeze(U{rec}.S_ctk(9,:,:));
    st = squeeze(U{rec}.S_ctk(12,:,:));
    st(ft==1)=1;
    
    lix = squeeze(U{rec}.S_ctk(16,poleOnset+samplingPeriod:end,:)); %look for first licks starting from the answer period
    [r,c] = find(lix==1);
    [lickTrials,uniqueIdx ] = unique(c);
    nonlickTrials = setxor(lickTrials,1:U{rec}.k);
    firstLickTimes = r(uniqueIdx) + poleOnset+samplingPeriod ;
    medianLickTime = round(median(firstLickTimes));
    
    lickMask = nan(size(ft));
    %OLD ADDED poleONSET : firstLickTimes since Phil's data has some weird
    %touches pre poleUp. 
%     for b = 1:length(firstLickTimes)
%     lickMask(1:firstLickTimes(b),lickTrials(b))=1; %filling first lick times on lick trials
%     end
%     lickMask(1:medianLickTime,nonlickTrials)=1; %filling non lick trials with median lickTimes;
%     
    
    
    for b = 1:length(firstLickTimes)
    lickMask(poleOnset:firstLickTimes(b),lickTrials(b))=1; %filling first lick times on lick trials
    end
    lickMask(poleOnset:medianLickTime,nonlickTrials)=1; %filling non lick trials with median lickTimes;
    
    preDecisionTouchIdx{rec} = st.*lickMask;
end