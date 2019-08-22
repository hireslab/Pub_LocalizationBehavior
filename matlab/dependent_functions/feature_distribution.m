function feature_distribution(U,V,params)
%Find all whisks pre touch
whiskThetapret = perWhiskpeakProtraction(U);

if strcmp(params.classes,'gonogo')
    colors = {'b','r'};
elseif strcmp(params.classes,'lick')
    colors = {'m','k'};
end

%% Visualization of distribution of features
figure(41);clf
overlap = zeros(length(U),1);
ratio = zeros(length(U),1);

for rec = 1:length(U)
    [DmatX, DmatY, ~] = designMatrixBuilder_v4(V(rec),U{rec},params);
    nDimX = size(DmatX,2);
    switch nDimX
        case 1
            %Plotting histogram of feature
            if strcmp(params.designvars,'counts')
                x = 0:1:20;
                firstvar = histc(DmatX(DmatY==1),x);
                secondvar = histc(DmatX(DmatY==2),x);
                fv(rec,:) = firstvar./sum(firstvar+secondvar);
                sv(rec,:) = secondvar./sum(firstvar+secondvar);
                
                % calculating overlap between the distributions of go and nogo counts
                overlapIDX = (fv(rec,:)>0).*( sv(rec,:)>0);
                overlapspace = sum(min( sv(rec,:), fv(rec,:) ).*overlapIDX,2);
                totaluniquespace = sum(max(sv(rec,:), fv(rec,:)),2);
                overlap(rec) = (overlapspace./totaluniquespace)'; 
                
                ratio(rec) = sum(DmatX(DmatY==1)) ./ (sum(DmatX(DmatY==1))+sum(DmatX(DmatY==2))); %ratio of go touches to nogo touches
                
                mean_angle_of_whisks(rec) = nanmean(whiskThetapret{rec}(:));
                variance_of_whisks(rec) = nanstd(whiskThetapret{rec}(:));
                meanTouchesgng(rec,:) = [mean(DmatX(DmatY==1)) mean(DmatX(DmatY==2))]; 
                
            else
                x=linspace(min(DmatX),max(DmatX),15);
            end
            
            firstvar = histc(DmatX(DmatY==1),x);
            secondvar = histc(DmatX(DmatY==2),x);
            
            figure(41);subplot(5,3,rec)
            bar(x,firstvar/sum(firstvar),colors{1});
            hold on;bar(x,secondvar/sum(secondvar),colors{2});
            alpha(.5)
            
            set(gca,'xlim',[min(DmatX) max(DmatX)])
            xlabel(params.designvars)
            
            
        case 3
            % Plotting scatter of features for 3 variables
            figure(41);subplot(5,3,rec)
            scatter3(DmatX(DmatY==1,1),DmatX(DmatY==1,2),DmatX(DmatY==1,3),[colors{1} '.'])
            hold on;scatter3(DmatX(DmatY==2,1),DmatX(DmatY==2,2),DmatX(DmatY==2,3),[colors{2} '.'])
            set(gca,'xlim',[min(DmatX(:,1)) max(DmatX(:,1))],'ylim',[min(DmatX(:,2)) max(DmatX(:,2))],'zlim',[min(DmatX(:,3)) max(DmatX(:,3))])
            
            if strcmp(params.designvars,'pas')
                xlabel('Amplitude');ylabel('Midpoint');zlabel('Phase')
            elseif strcmp(params.designvars,'decompTime')
                xlabel('time to touch');ylabel('whisk angle onset');zlabel('velocity')
            end
            
    end
end


%% Population visualization

if strcmp(params.designvars,'counts')
    %Plotting distribution for population 
    x = 0:1:20;
    figure(43);subplot(1,3,1)
    bar(x,nanmean(fv),'b')
    hold on; bar(x,nanmean(sv),'r')
    alpha(1)
    set(gca,'xlim',[-.5 20])
    xlabel('number of touches');
    ylabel('proportion of trials')
    legend('go','nogo')
    axis square
    
    %Plotting mean of whisking against ratio of counts
    figure(43);subplot(1,3,2)
    mdl = fitlm(mean_angle_of_whisks,ratio);
    scatter(mean_angle_of_whisks,ratio,[],'markerfacecolor',rgb('DarkTurquoise'),'markeredgecolor',rgb('DarkTurquoise'))
    hold on; plot(sort(mean_angle_of_whisks),mdl.predict(sort(mean_angle_of_whisks)'),'k')
    set(gca,'xlim',[-20 20],'xtick',-20:10:20,'ylim',[.4 1],'ytick',0:.2:1)
    text(10,.9,['r=' num2str(sqrt(mdl.Rsquared.Ordinary))])
    axis square
    xlabel('average peak of protraction (relative to dbound)')
    ylabel('Proportion of touches in go region')
    
    %Plotting variance of whisking against overlap of counts
    figure(43);subplot(1,3,3)
    mdl = fitlm(variance_of_whisks,overlap);
    scatter(variance_of_whisks,overlap,[],'markerfacecolor',rgb('DarkTurquoise'),'markeredgecolor',rgb('DarkTurquoise'))
    hold on; plot(sort(variance_of_whisks),mdl.predict(sort(variance_of_whisks)'),'k')
    set(gca,'xlim',[5 15],'ylim',[0 1],'ytick',0:.25:1)
    text(12,.8,['r=' num2str(sqrt(mdl.Rsquared.Ordinary))])
    axis square
    xlabel('variance of peak of whisking')
    ylabel('proportion of distribution overlap')
    
    suptitle('Fig 3a/b/c: How does whisking strategy affect distribution of touch counts?')
    
end
