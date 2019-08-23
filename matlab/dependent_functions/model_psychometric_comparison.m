function model_psychometric_comparison(mdl,BV)

colors = {'g','b'};
numBins = 10;

real_sorted = cell(1,numel(BV)); 
pred_sorted = [];

%generate psychometric curves
pfields = fields(mdl.output.true_preds);
for k = 1:length(pfields)
    cvs = mdl.output.true_preds.(pfields{k});
    
    for rec = 1:length(BV)
        hits = double(BV{rec}.meta.trialType==1) .* double(BV{rec}.meta.trialCorrect==1);
        FAs = double(BV{rec}.meta.trialType==0) .* double(BV{rec}.meta.trialCorrect==0);
        real_choice = sum([hits;FAs]);
        real_motor = BV{rec}.meta.motorPosition;
        [real_sorted{rec}] = binslin(normalize_var(real_motor,1,-1),real_choice','equalE',numBins+1,-1,1);
        
        pred_choice = cvs{rec}(:,3)==1; %recoding optimal values for 0 = nogo
        pred_motor = cvs{rec}(:,1);
        [pred_sorted.(pfields{k}){rec}] = binslin(normalize_var(pred_motor,1,-1),pred_choice,'equalE',numBins+1,-1,1);
        
    end
end

%plot psychometric curves
rc = numSubplots(length(BV));
figure(79);clf
for rec = 1:length(BV)
    
    subplot(rc(1),rc(2),rec)
    plot(linspace(-1,1,numBins),cellfun(@nanmean,real_sorted{rec}),'k')
    
    for g = 1:length(pfields)
        hold on; plot(linspace(-1,1,numBins),cellfun(@nanmean,pred_sorted.(pfields{g}){rec}),colors{g})
    end
    
    if rec == 5
        legend('mouse','midpoint+counts','angle+counts')
    end
end

suptitle('Figure 7I')