%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting function for single whisker precision using ROC curves.
% Will bin motor positions into 10 bins and use those for identify FArate
% vs Hitrate. Will only work for continuous uber array.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [outputs] = discrimination_precision(U,displayOpt)

if (nargin < 2), displayOpt = 'on'; end
willdisplay = ~(strcmp(displayOpt,'nodisplay') | strcmp(displayOpt,'n') ...
    | strcmp(displayOpt,'off'));

if willdisplay
    figure(28);clf
end

popA = cell(1,6);
p = nan(length(U),6);

for ms = 1:length(U)
    motors = U{ms}.meta.motorPosition;
    ttype = U{ms}.meta.trialType;
    tcorr = U{ms}.meta.trialCorrect;
    array = [motors' ttype' tcorr'];
    
    [sortedtmp]= binslin(array(:,1),array,'equalE',21,U{ms}.meta.ranges(1),U{ms}.meta.ranges(end));
    [sortedtmp2]= binslin(array(:,1),array,'equalE',11,U{ms}.meta.ranges(1),U{ms}.meta.ranges(end));
    sorted = [sortedtmp2(1:5) ;sortedtmp(10:11); sortedtmp2(6:10)];

    a = [6  5  4 3 2 1];
    b = [7 8 9 10 11 12];
    colors = prism(6);
    FAmat{ms} = nan(1000,length(b));
    HRmat{ms} = nan(1000,length(b));
    for d = 1:length(b)
        onemm = [sorted{a(d)};sorted{b(d)}];
        onemmFA = 1-mean(onemm(onemm(:,2)==0,3));
        onemmHR = mean(onemm(onemm(:,2)==1,3));
        
        FAs = onemm(onemm(:,2)==0,3);
        HRs = onemm(onemm(:,2)==1,3);
        
        FAmat{ms}(1:length(FAs),d) = FAs;
        HRmat{ms}(1:length(HRs),d) = HRs;
        
  
        [~,p(ms,d)] = ttest2(1-FAs,HRs);
        
        
        popA{d}(ms,:) = [onemmFA onemmHR];
        if willdisplay
            figure(28);
            hold on; scatter(onemmFA,onemmHR,'markeredgecolor',colors(d,:));
        end
    end
    plot([0 1],[0 1],'-k')
    xlabel('FA rate');ylabel('Hit rate')

end

% groupPvals
gFA = cell2mat(FAmat');
gHR = cell2mat(HRmat');
for k = 1:length(b)
    hr = gHR(:,k);
    fa=gFA(:,k);
    hr=hr(~isnan(hr));
    fa=fa(~isnan(fa));
    
    [~,pg(k)] =ttest2(hr,fa);
end
    

groupPrecision=cell2mat(cellfun(@mean,popA,'uniformoutput',0)');

    % 95% CI
    for i = 1:size(popA,2)
        x=popA{i};
        SEM = nanstd(x)/sqrt(length(x));               % Standard Error
        ts = tinv([0.05  0.95],length(x)-1);      % T-Score
        cibin(i,:) = abs(ts.*SEM);   %confidence intervals
    end


    if willdisplay
        figure(28);hold on;
        for i = 1:length(groupPrecision)
            hold on;
            errorbar(groupPrecision(i,1),groupPrecision(i,2),cibin(i,2),cibin(i,2),cibin(i,1),cibin(i,1),'x','Color',colors(i,:),'linewidth',1)
            
            scatter(groupPrecision(i,1),groupPrecision(i,2),400,'x','linewidth',2,'markeredgecolor',colors(i,:));
            %     h.CData = colors(i,:);
            
            xlabel('FA rate');ylabel('Hit rate')
            legend off
        end
        set(gca,'ytick',[0 .5 1],'xtick',[0 .5 1],'ylim',[0 1]);
        plot([0 1],[0 1],'-k')
        axis square
    end

outputs.means = groupPrecision;
outputs.errors = cibin;


%MATRIX for all pvals 
pmat = [.5 1 2 3 4 5 ; nan(1,6) ;p ; nan(1,6) ; sum(p<.1) ;sum(p<.05) ; sum(p<.01)];

