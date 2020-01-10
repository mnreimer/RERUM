%% Figure File for Plotting Spatial Abundance Data
% * Filename: fig_abundance.m
% * Authors: Matt Reimer
% * Created: 11/28/18
% * Updated: 12/22/19
% * Purpose: 
%
%% Description
% The function |fig_abundance| returns a function handle that plots
% simulation results (spatial abundance) from the data generating process.
%
%% Notes
% * This is Figure 1 in the paper.
% * Called by: |model_figures|.
%
function h = fig_abundance(par,scenario,export,filename)
%
%% Preliminaries
   path = [homedir 'Dropbox/Apps/Overleaf/Structural Behavioral Models for Rights-Based Fisheries/figures/'];
   
   if nargin < 4
       filename = 'fig_abundance';
   end
   if nargin < 3
       export = 'no';
   end
   if nargin < 1
       scenario = 1;
   end
   figurename = ['figures/' filename '.fig']; 
   
%% Data for figures
    
    % DGP biological parameters
    if scenario==1
        mu = {[-2.5,2.5;2.5,-2.5]};
    else
        mu = {[1.5,1.5;0,0]};
    end
    par = set(par,{'mu'},mu);
    
    % Generate data
    TAC = par.TAC;
    T = par.periods;
    N = par.individuals;
    q = par.catchability;
    n = par.gridsize;
    [F,Fg] = abundance(par);                     % Abundance data
    globprod = T*N*q(1)*conhul(F);   % Global production set (summed over T and N)
    
%% Figure of Spatial Distribution (For 2 species only)
   h = figure('Name','Spatial Abundance and Global Production Set',...
       'Units', 'normalized', 'Position', [0.0953    0.2907    0.7818    0.3593]);
            
            for i = 1:2                
                % Create subplot
                sub = subplot(1,3,i,'Parent',h);
                hold(sub,'on');

                % Create image
                image(Fg(:,:,i),'Parent',sub,'CDataMapping','scaled');

                % Create labels
                xlabel('X-coordinate'); ylabel('Y-coordinate');

                % Create title
                title(['Species ',num2str(i)]);
                
                % Axis
                xlim(sub,[0.5 n+0.5]);
                ylim(sub,[0.5 n+0.5]);
                box(sub,'on');
                axis(sub,'ij');
                
                % Set the remaining axes properties
                set(sub,'Layer','top','YTick',1:n);
                % Create colorbar
                colorbar('peer',sub);
                hold(sub,'off');
            end
            % Create Final Subplot
            subplot(1,3,3,'Parent',h)
            
            % Fill plot for global production set
            fill(globprod(:,1),globprod(:,2),[0.85 0.85 0.85],'LineWidth',1); 
            
            % Create labels
            xlabel('Species 1'); ylabel('Species 2');
             
            % Create title
            title('Production Set');
                
            % Mark TAC on the production set
            hold on; grid on;
            scatter(TAC(1),TAC(2),'MarkerFaceColor','black','MarkerEdgeColor',[0 0 0 ]);
            line([TAC(1) TAC(1)],[0 TAC(2)],'Color','black','LineStyle','--','LineWidth',1.5);
            line([0 TAC(1)],[TAC(2) TAC(2)],'Color','black','LineStyle','--','LineWidth',1.5);
            
            % Super Title
            sgtitle(['Scenario ',num2str(scenario)]);

%% Export Figure
    switch export
        case 'yes'
            print([path filename],'-dpng')
            savefig(figurename); 
        otherwise
    end
end

%% Figures
    function out1 = conhul(f)  
    % This function generates the convex hull of all possible production bundles that emerge from
    % spatial distribution f = [f1,f2]

        k = convhull(f(:,1),f(:,2));        % Convex hull
        k(end)=[]; k(1)=[];             % Need to include the origin in the convex hull
        out1 = [0 , 0 ; f(k,1),f(k,2) ; 0 , 0];

    end
    
    
            
        
