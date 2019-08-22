function model_precision_comparison(mdl,behav_struct)

% Resolution of model from optimal prediction  %requires U,trueXpreds
pfields = fields(mdl.output.true_preds);
color = {'g','b'};
figure(80);clf

for k = 1:length(pfields)
    cvs = mdl.output.true_preds.(pfields{k});
    binned = cellfun(@(x) binslin(x(:,1),x(:,[2 3]),'equalE',11,min(x(:,1)),max(x(:,1))),cvs,'uniformoutput',0);
    pc = cellfun(@(x) cellfun(@(y) mean(y(:,1) == y(:,2)),x),binned,'uniformoutput',0);
    pcFA = cellfun(@(x) [ones(length(x)./2,1) - x(1:length(x)./2) ; x((length(x)./2)+1:end)] ,pc,'uniformoutput',0) ; %convert to FArate
    
    binnedFine = cellfun(@(x) binslin(x(:,1),x(:,[2 3]),'equalE',21,min(x(:,1)),max(x(:,1))),cvs,'uniformoutput',0);
    pcFine = cellfun(@(x) cellfun(@(y) mean(y(:,1) == y(:,2)),x),binnedFine,'uniformoutput',0);
    pcFAFine = cellfun(@(x) [ones(length(x)./2,1) - x(1:length(x)./2) ; x((length(x)./2)+1:end)] ,pcFine,'uniformoutput',0) ; %convert to FArate
    
    
    ts = tinv(0.975,numel(binned)-1);      % T-Score @ 95% for calculating 95CI
    
    finemnsct = nanmean(cell2mat(pcFAFine),2);
    finesemsct = nanstd(cell2mat(pcFAFine),[],2) ./ sqrt(numel(binned)); %SEM error
    fineci = abs(ts.*finesemsct);  %95CI error
    finerr = fineci;
    
    fasfine = [finemnsct(1:length(finemnsct)./2) finerr(1:length(finerr)./2)];
    hitsfine = flipud([finemnsct((length(finemnsct)./2)+1:end) finerr((length(finerr)./2)+1:end)]);
    
    mnsct = nanmean(cell2mat(pcFA),2);
    semsct = nanstd(cell2mat(pcFA),[],2) ./ sqrt(numel(binned)); %SEM error
    ci = abs(ts.*semsct); %95CI error
    error = ci; %error chosen
    
    fas = [mnsct(1:length(mnsct)./2) error(1:length(error)./2)];
    hits = flipud([mnsct((length(mnsct)./2)+1:end) error((length(error)./2)+1:end)]);
    
    gfas = [fas ; fasfine(end,:)];
    ghits = [hits ; hitsfine(end,:)];
    
    
    hold on; errorbar(gfas(:,1),ghits(:,1),ghits(:,2),ghits(:,2),gfas(:,2),gfas(:,2),[color{k} '-o']);
    
    set(gca,'xtick',[0 1],'ytick',[0 1],'ylim',[0 1],'xlim',[0 1]);
    axis square
    xlabel('FA rate');ylabel('hit rate')
    
end

[outputs] = discrimination_precision(behav_struct,'off');
hold on; errorbar(outputs.means(:,1),outputs.means(:,2),outputs.errors(:,2),outputs.errors(:,2),outputs.errors(:,1),outputs.errors(:,1),'k-o')
hold on; plot([0 1],[0 1],'-.k')
legend([pfields ;{'mouse'}])
