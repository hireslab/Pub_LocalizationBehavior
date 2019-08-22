%% bDataWrapper - wraps behavioral data together

function [behaviorHist, behaviorInfo, behaviorTrim] = bdatawrapper(behaviorDir)
fileBehavior = dir([behaviorDir filesep '*mat']);
B = {fileBehavior.name};
numBArrays = numel(B);

behaviorHist = cell(1,numBArrays); 
behaviorInfo = cell(1,numBArrays);
behaviorTrim = cell(1,numBArrays);

%dateArray = zeros(numBArrays, 1);
for i = 1:numBArrays
    load([behaviorDir filesep B{i}])
    cd(behaviorDir)
    tmp = Solo.BehavTrialArray(B{i}, B{i}(35:40));
    behaviorTrim{i} = [tmp.hitTrialNums(1):tmp.hitTrialNums(end)];
    behaviorHist{i} = saved_history;
    behaviorInfo{i} = saved;
end 