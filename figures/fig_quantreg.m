%% Figure File for Plotting Quantile Regressions of In-Sample Performance
% * Filename: fig_quantreg.m
% * Authors: Matt Reimer
% * Created: 08/27/19
% * Updated: 10/16/19
% * Purpose: 
%
%% Description
% The function |fig_insample| returns a function handle that plots
% in-sample performance metrics.
%
function h = fig_quantreg(T,export,filename)
%
%% Preliminaries
    % Defaults
    path = 'C:\Users\mnrei\Dropbox\Apps\Overleaf\Structural Behavioral Models for Rights-Based Fisheries\figures\';
    
   if nargin < 3
       filename = 'fig_quantreg_revbias';
   end
   if nargin < 2
       export = 'no';
   end
   figurename = ['figures\' filename '.fig']; 
   
   % Title and Labels
    ttl = {'Bias $\left( \hat{\theta}_{Revenue} \right)$','RMSE $\left( \hat{Pr} \right)$','Estimation Time'};
    ylab = {'Bias (\%)','RMSE','Hours'};
    
   % Output variables and regressors
    vars = {'observations','years','species','sigma'};
    out = {'bias','rmse','est_time'};
    
   % Quantiles
    quants = [0.1 0.5 0.9];
    
   % Axis
   ax = [-25 25 ; 0 3 ; 0 5];
        
%% Figure of Quantile Regression Results
   K = numel(out);
   J = numel(vars);
   
   for k = 1:K
          h(k) = figure('Name',['Quantile Regression: ',out{k}],...
       'Units', 'normalized', 'Position', [0.2715    0.3778    0.4109    0.2861]);
          sgtitle(ttl{k},'Interpreter','latex');        
       for j = 1:J
            subplot(1,J,j,'Parent',h(k));
           % Regressor
            X = T.(vars{j});
            % Outcome
            Y = T.(out{k});
            
            % Quantile Regression and Prediction
            for i = 1:numel(quants)
                % Quantile Regress
                p=quantreg(X,Y,quants(i),2);  
                % Predict
                dim = 20;
                Xnew = linspace(min(X),max(X),dim)';
                ypred(:,i) = polyval(p,Xnew);
            end
            
            % Plot Confidence Limits
            x = [Xnew', fliplr(Xnew')];
            inBetween = [ypred(:,1)', fliplr(ypred(:,3)')];
            fill(x, inBetween,[0.90,0.90,0.90],'EdgeColor',[1 1 1]);
            line(Xnew,ypred(:,[1 3]),'Color',[0.50,0.50,0.50]); hold on; grid on;
            axis([Xnew(1,1) Xnew(end,1) ax(k,:)])             
            
            % Predictions
            line(Xnew,ypred(:,2),'Color','black','LineWidth',1.5);     
            % Data Points
            scatter(X,Y,10,[0.40,0.40,0.40])
            % Axis Labels
            xlabel(vars{j},'Interpreter','latex');
            ylabel(ylab{k},'Interpreter','latex');
        end    
   end
          
%% Export Figure
    switch export
        case 'yes'
            print([path filename],'-dpng')
            savefig(figurename); 
        otherwise
    end
    
end
           
           