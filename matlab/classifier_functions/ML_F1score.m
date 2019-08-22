function [opt_threshold] = ML_F1score(pred_vals,real)

thresholds = [.1:.05:1];
m=size(real,1);
pred = zeros(m,length(thresholds));
for i = 1:length(thresholds)
    pred(:,i)=pred_vals>=thresholds(i);
end

%pred(pred==0)=2; %setting all those not classified as go to nogo

ATPidx=(real==1); %all true positives 

TP = sum(pred(ATPidx,:)==1);
FN = sum(pred(ATPidx,:)==0);
predPos = sum(pred==1);

P = TP./predPos; %precision defined as TRUEPOS/predicted pos

R = TP./(TP+FN); %recall defined as TRUEPOS/ACTUALPOS
    
F1s = 2 .* (P.*R)./(P+R);

[~,B] = max(F1s);

idx=find(F1s==max(F1s));

opt_threshold = thresholds(idx(end));