function [hitmaxp,missmaxp,FAmaxp,CRmaxp] = maxProtractionPreD(array)

%%%%% **** LOOKS AT MAXP FROM 500:1250 **** POLE ONSET + SAMPLING PERIOD
%%%%% %%%%%%%%%%%%
licks = squeeze(array.S_ctk(16,:,:))';

fl = [];
for i = 1:size(licks,1)
    licktmps = find(licks(i,:)==1);
    fl(i) = min([licktmps(licktmps>1250) array.t]);
end
flraw = fl;
fl = fl(fl<3000);
fls = sort(fl);
flninety= fls(ceil(numel(fls)*.9));
flraw((flraw>flninety))=flninety;

thetas = squeeze(array.S_ctk(1,:,:));
lickmask = nan(size(thetas));

for b = 1:length(flraw)
    lickmask(500:flraw(b),b)=1;
end

        hits = double(array.meta.trialCorrect == 1) .* double(array.meta.trialType ==1);
        miss = double(array.meta.trialCorrect == 0) .* double(array.meta.trialType ==1);
        FA = double(array.meta.trialCorrect == 0) .* double(array.meta.trialType ==0);
        CR = double(array.meta.trialCorrect == 1) .* double(array.meta.trialType ==0);
        
maxProtraction = max(lickmask.*thetas);

hitmaxp = maxProtraction(find(hits==1));
missmaxp = maxProtraction(find(miss==1));
FAmaxp = maxProtraction(find(FA==1));
CRmaxp = maxProtraction(find(CR==1));