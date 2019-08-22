function [nor] = ConvertToOddsRatio(weights,cvKfold)

nDimX=size(weights{1}.theta{1},2)-1;

feats = cell(1,length(weights));
for rec = 1:length(weights)
    ms=cell2mat(weights{rec}.theta);
    feats{rec} = reshape(ms(1,:)',nDimX+1,cvKfold);
end

nor = nan(nDimX,length(weights));
oddsR = cell(1,length(weights));
for g = 1:length(weights)
    for b = 1:cvKfold
        
        xv = feats{g}(2:end,b);
        pn = sign(xv);
        oddsR{g}(:,b)=exp(pn.*xv).*pn;
        
    end
    
    oddsR{g}(isinf(oddsR{g})) = nan;
    
    group = [zeros(1,size(oddsR{g},2));oddsR{g}];
    sg = sign(group);
    nsg = normalize_var(abs(group),0,1) .* sg;
    nor(:,g) = nanmean(nsg(2:end,:),2);
    
end

