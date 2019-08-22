function plot_decision_boundary(mdl,plot_variable)

if strcmp(mdl.build_params.classes,'gonogo')
    colors = {'b','r'};
elseif strcmp(mdl.build_params.classes,'lick')
    colors = {'m','k'};
end

for rec = 1:numel(mdl.input.(plot_variable).DmatX)

    DmatX = mdl.input.(plot_variable).DmatX{rec};
    DmatY = mdl.input.(plot_variable).DmatY{rec};
    nDimX = size(DmatX,2);
    switch nDimX
        case 1
            if strcmp(plot_variable,'curvature')
                x = 0:0.0025:.05; %kappa
            elseif strcmp(plot_variable,'counts')
                x = 0:1:15; % counts
            elseif strcmp(plot_variable,'cueTiming')
                x=0:25:750; %timing
            elseif strcmp(plot_variable,'whiskTiming')
                x=0:4:60; %time to touch
            elseif strcmp(plot_variable,'radialD')
                x = -5:.5:5; %radial distance NORMALIZED
            elseif strcmp(plot_variable,'angle')
                x = 0:2:40; %angle
            end

            firstvar = histc(DmatX(DmatY==1),x);
            secondvar = histc(DmatX(DmatY==2),x);
            
            figure(12);subplot(3,5,rec)
            bar(x,firstvar/(sum(firstvar)+sum(secondvar)),colors{1});
            hold on;bar(x,secondvar/(sum(firstvar)+sum(secondvar)),colors{2});

            for db = [1:2]
                ms=cell2mat(mdl.output.weights.(plot_variable){rec}.theta);
                coords=mean(reshape(ms(db,:)',2,mdl.learn_params.cvKfold),2);
                y= (exp(coords(1)+coords(2)*x)) ./ (1 + exp(coords(1)+coords(2)*x))  ;
                hold on; plot(x,y,['-.' colors{db}]);
            end
            
            alpha(.5)
            set(gca,'xlim',[min(x) max(x)],'ylim',[0 1]);

        
        case 2
            figure(12);subplot(3,5,rec)
            
            scatter(DmatX((DmatY==1),2),DmatX((DmatY==1),1),[],'filled','b')
            hold on;scatter(DmatX((DmatY==2),2),DmatX((DmatY==2),1),[],'filled','r')
%             alpha(.5)
            
            ms=cell2mat(mdl.output.weights.(plot_variable){rec}.theta);
            coords=mean(reshape(ms(1,:)',3,learnparam.cvKfold),2);
        
            plot_x = [min(DmatX(:,2)), max(DmatX(:,2))] ;
            plot_y = (-1./coords(2)) .* (coords(3).*plot_x + coords(1));
            hold on; plot(plot_x,plot_y,'-.k')
            
            set(gca,'xlim',[min(DmatX(:,2)) max(DmatX(:,2))],'ylim',[min(DmatX(:,1)) max(DmatX(:,1))]);
            
            title(num2str(mcc(rec,1)));
        case 3
            % %ASIDE: Plotting Decision Boundary for 3 variables
            
            ms=cell2mat(mdl.output.weights.(plot_variable){rec}.theta);
            coords=mean(reshape(ms(1,:)',4,mdl.learn_params.cvKfold),2);
            
            figure(10);clf
            scatter3(DmatX(DmatY==1,1),DmatX(DmatY==1,2),DmatX(DmatY==1,3),50,'m.')
            hold on;scatter3(DmatX(DmatY==2,1),DmatX(DmatY==2,2),DmatX(DmatY==2,3),50,'k.')
            
            %             hold on;scatter3(centroid(1,1),centroid(1,2),centroid(1,3),'k','linewidth',10)
            %             hold on;scatter3(centroid(2,1),centroid(2,2),centroid(2,3),'b','linewidth',10)
            
            plot_x = [min(DmatX(:,1))-2, min(DmatX(:,1))-2, max(DmatX(:,1))+2, max(DmatX(:,1))+2]; %ranges for amplitude
            plot_z = [-3 ,3,3,-3];
            plot_y = (-1/coords(3)) .* (coords(1) + (coords(2).*plot_x) + (coords(4).*plot_z) - log(mdl.output.decision_boundary.(plot_variable){rec}/(1-mdl.output.decision_boundary.(plot_variable){rec}))); % log p(go trial) to calculate decision boundary
            
            hold on; fill3(plot_x, plot_y, plot_z,'k');
            
            set(gca,'xlim',[min(DmatX(:,1)) max(DmatX(:,1))],'ylim',[min(DmatX(:,2)) max(DmatX(:,2))],'zlim',[min(DmatX(:,3)) max(DmatX(:,3))])
            if strcmp(mdl.build_params.designvars,'hilbert')
                xlabel('Amplitude');ylabel('Midpoint');zlabel('Phase')
            elseif strcmp(mdl.build_params.designvars,'decompTime')
                xlabel('time to touch');ylabel('whisk angle onset');zlabel('velocity')
            end
            
            
    end
    
end
suptitle(plot_variable)