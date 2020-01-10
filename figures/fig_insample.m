%% Figure File for Plotting In-Sample Performance
% * Filename: fig_insample.m
% * Authors: Matt Reimer
% * Created: 02/07/19
% * Updated: 08/27/19
% * Purpose: 
%
%% Description
% The function |fig_insample| returns a function handle that plots
% in-sample performance metrics.
%
function h = fig_insample(results,export,filename)
%
%% Preliminaries
    bias = results.bias;
    rmse = results.rmse;
    fields = fieldnames(results.bias);
    x = 1:numel(fields);    % Categories to plot over
    sz = 75;                % Marker size
    path = 'C:\Users\mnrei\Dropbox\Apps\Overleaf\Structural Behavioral Models for Rights-Based Fisheries\figures\';
    
   if nargin < 3
       filename = 'fig_insample';
   end
   if nargin < 2
       export = 'no';
   end
   figurename = ['figures\' filename '.fig']; 
    
%% Figure 
   h = figure('Name','In-sample Prediction Performance',...
       'Units', 'normalized', 'Position', [0.2957    0.4368    0.4070    0.1854]);
               
   % Bias
   ttl = {'Bias $\left( \hat{\theta}_{Revenue} \right)$',...
        'Bias $\left( \hat{\theta}_{Distance} \right)$'};
   
   for s = 1:2
        subplot(1,3,s,'Parent',h);
        % Plot "error bars" (elements 1 and 3)
        for i = 1:numel(fields)
            scen = fields{i};
            y(i,:) = prctile(bias.(scen)(s,:),[25 50 75],2);
            line([x(i) x(i)],[y(i,1) y(i,3)],'LineWidth',1.25,...
                'Color','black'); 
            hold on
        end
        
        % Set axis
        axis([0.5 (numel(fields)+0.5) -Inf Inf])
        ax = get(gcf,'CurrentAxes');
        
        % Dashed line at zero
        line(ax.XLim,[0 0],'Color','black','LineStyle','--');
        
        % Scatter plot of median bias
        scatter(x,y(:,2),sz,[0.5 0.5 0.5],'filled','MarkerEdgeColor','k'); grid on;
        
        % Add category labels on x-axis
        set(gca, 'XTickLabel',fields, 'XTick',1:numel(fields),'fontsize',7)
        
        % Title
        title(ttl{s},'Interpreter','latex','FontSize',9);
   end
   
    % RMSE in Predicted Probabilities
        subplot(1,3,3,'Parent',h);
    
        % Plot "error bars" (elements 1 and 3)
        for i = 1:numel(fields)
            scen = fields{i};
            y(i,:) = prctile(rmse.(scen),[25 50 75],2);
            line([x(i) x(i)],[y(i,1) y(i,3)],'LineWidth',1.25,...
                'Color','black'); 
            hold on
        end
        
        % Set axis
        axis([0.5 (numel(fields)+0.5) -Inf Inf])
        
        % Scatter plot of median RMSE
        scatter(x,y(:,2),sz,[0.5 0.5 0.5],'filled','MarkerEdgeColor','k'); grid on; 
        
        % Add category labels on x-axis
        set(gca, 'XTickLabel',fields, 'XTick',1:numel(fields),'fontsize',7)
        
        % Title
        title('RMSE $\left( \hat{Pr} \right)$','Interpreter','latex','FontSize',9);
   
        
%% Export Figure
    switch export
        case 'yes'
            print([path filename],'-dpng')
            savefig(figurename); 
        otherwise
    end
    end
    
    
            
        
