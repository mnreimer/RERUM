%% Figure File for Plotting Policy Simulation Outcomes
% * Filename: fig_num_sims.m
% * Authors: Matt Reimer
% * Created: 10/24/19
% * Updated: 10/24/19
% * Purpose: 
%
%% Description
% The function |fig_num_sims| returns a function handle that plots
% outcomes for hypothetical bycatch reduction policies.
%
%% Notes
% * |D| is a structural array containing simulation results for two types
% of bycatch reduction policies (closures and tac reductions), as well as
% baseline (or status quo) simulations.
% * |policies| is a cell array containing vectors of the reductions
% evaluated in the simulations.
%
function h = fig_num_sims(outcomes,policies,export,filename)
% 
%% PRELIMINARIES
 % Policies to be exaamined
 scen = size(outcomes.bycatch.tac,2);
 closed = policies.clos;
 tac_pol = policies.tac;
 
 % Outcomes
 bycatch = outcomes.bycatch;
 netrev = outcomes.netrev;
 wstar = outcomes.wstar;
 
 % New and useful policy vectors
 closed_f = [closed,fliplr(closed)];
 tac_pol_f = [tac_pol,fliplr(tac_pol)];
 
 % Figure export 
  path = 'C:\Users\mnrei\Dropbox\Apps\Overleaf\Structural Behavioral Models for Rights-Based Fisheries\figures\';
  if nargin < 4
      filename = 'fig_num_sims';
  end
  if nargin < 3
      export = 'no'; 
  end
  figurename = ['figures\' filename '.fig']; 
  
%% Summary Statistics
 % Performance metrics
 for i = 1:scen
     % TAC Policies
     xbase = bycatch.tac(:,i,1);
     ybase = netrev.tac(:,i,1);
     for tp = 1:numel(tac_pol)
         % Bycatch and netrev, relative to baseline
         bycatch_tac(:,tp,i) = prctile((bycatch.tac(:,i,tp) - xbase)./xbase,...
             [25 50 75],1);
         netrev_tac(:,tp,i) = prctile((netrev.tac(:,i,tp) - ybase)./ybase,...
             [25 50 75],1);
         % Quota prices
         wstar_tac(:,:,tp,i) = prctile(wstar.tac(:,:,i,tp),...
             [25 50 75],1);
     end
     % Closure Policies
     xbase = bycatch. clos(:,i,1);
     ybase = netrev.clos(:,i,1);
     for cl = 1:numel(closed)
          % Bycatch and netrev, relative to baseline
         bycatch_clos(:,cl,i) = prctile((bycatch.clos(:,i,cl) - xbase)./xbase,...
             [25 50 75],1);
         netrev_clos(:,cl,i) = prctile((netrev.clos(:,i,cl) - ybase)./ybase,...
             [25 50 75],1);
         % Quota prices
         wstar_clos(:,:,cl,i) = prctile(wstar.clos(:,:,i,cl),...
             [25 50 75],1);
     end
 end
     

%% Plots
 % Parent Figure
  fig_name = 'Bycatch Reduction Policy Simulations';
  h = figure('Name',fig_name,'Units','normalized',...
       'Position',[0.2578    0.0435    0.3309    0.8454]);
          
 % Set axes for subplots: [left, bottom, width, height]
  hgt = 0.175; wdt = 0.32; marg = 0.15; 
  pos{1} = [marg,0.76,wdt,hgt];
  pos{2} = [1-0.75*marg-wdt,0.76,wdt,hgt];
  pos{3} = [marg,0.54,wdt,hgt];
  pos{4} = [1-0.75*marg-wdt,0.54,wdt,hgt];
  pos{5} = [marg,0.32,wdt,hgt];
  pos{6} = [1-0.75*marg-wdt,0.32,wdt,hgt];
  pos{7} = [marg,0.1,wdt,hgt];
  pos{8} = [1-0.75*marg-wdt,0.1,wdt,hgt];
  pos{9} = [0.3,0.01,0.4,0.0275];
 
 % Subplot (1,1): Change Utility, Closures, Both scenarios
 % Create axes
  axes1 = axes('Parent',h,'Position',pos{1});
  hold(axes1,'on');  
 % Set Color
  facecolor = {[0, 0.4470, 0.7410],[0.8500, 0.3250, 0.0980]};
 % Plot, by scenario 
  for i = 1:scen
     clear y
     y = netrev_clos(:,:,i);
     inBetween = [y(1,:),fliplr(y(3,:))];
     pl(i) = fill(closed_f, inBetween,facecolor{i},'EdgeColor',[1 1 1],...
         'FaceAlpha',0.25);
     hold on; 
     line(closed,y([1 3],:),'Color',[0.50,0.50,0.50]); 
     line(closed,y(2,:),'Color',facecolor{i},'LineWidth',2);
  end
  % X-label and axis
   xlabel('');
   axis([closed(1) closed(end) -Inf Inf])  
  % Y-label
   ylabel({'\% $\Delta$ Expected','Utility'},'Interpreter','latex');
  % Column Title
   title('Hot-Spot Closures','FontSize',11,'Interpreter','latex')
  % Grid
   grid on
  % Axes Box
   box(axes1,'on');

 % Subplot (1,2): Change Utility, TAC reductions, Both scenarios
 % Create axes
  axes2 = axes('Parent',h,'Position',pos{2});  
  hold(axes2,'on');
  for i = 1:scen
     clear y
     y = netrev_tac(:,:,i);
     inBetween = [y(1,:),fliplr(y(3,:))];
     fill(tac_pol_f, inBetween,facecolor{i},'EdgeColor',[1 1 1],...
         'FaceAlpha',0.25);
     hold on; 
     line(tac_pol,y([1 3],:),'Color',[0.50,0.50,0.50]); 
     line(tac_pol,y(2,:),'Color',facecolor{i},'LineWidth',2);
  end
  % X-label and axis
   xlabel('');
   axis([tac_pol(1) tac_pol(end) -Inf Inf])  
  % Column Title
   title('TAC Reductions','FontSize',11,'Interpreter','latex');
  % Grid
   grid on
  % Axes Box 
   box(axes2,'on');
     
 % Subplot (2,1): Change Bycatch, Closures, Both scenarios
 % Create axes
  axes3 = axes('Parent',h,'Position',pos{3});
  hold(axes3,'on');
  for i = 1:scen
     clear y
     y = bycatch_clos(:,:,i);
     inBetween = [y(1,:),fliplr(y(3,:))];
     fill(closed_f, inBetween,facecolor{i},'EdgeColor',[1 1 1],...
         'FaceAlpha',0.25);
     hold on; 
     line(closed,y([1 3],:),'Color',[0.50,0.50,0.50]); 
     line(closed,y(2,:),'Color',facecolor{i},'LineWidth',2);
  end
  % X-label and axis
   xlabel('');
   axis([closed(1) closed(end) -Inf Inf])  
  % Y-label
   ylabel('\% $\Delta$ Bycatch','Interpreter','latex');
  % Grid
   grid on
  % Axes Box 
   box(axes3,'on');
     
 % Subplot (2,2): Change Bycatch, TAC reductions, Both scenarios
 % Create axes
  axes4 = axes('Parent',h,'Position',pos{4});
  hold(axes4,'on');
  for i = 1:scen
     clear y
     y = bycatch_tac(:,:,i);
     inBetween = [y(1,:),fliplr(y(3,:))];
     fill(tac_pol_f, inBetween,facecolor{i},'EdgeColor',[1 1 1],...
         'FaceAlpha',0.25);
     hold on; 
     line(tac_pol,y([1 3],:),'Color',[0.50,0.50,0.50]); 
     line(tac_pol,y(2,:),'Color',facecolor{i},'LineWidth',2);
  end
  % X-label and axis
   xlabel('');
   axis([tac_pol(1) tac_pol(end) -Inf Inf])  
  % Y-label
   ylabel('');
  % Grid
   grid on   
  % Axes Box 
   box(axes4,'on');
        
 % Subplot (3,1): Quota Price (s = 1), Closures, Both scenarios
 % Create axes
  axes5 = axes('Parent',h,'Position',pos{5});
  hold(axes5,'on'); 
  for i = 1:scen
     clear y
     y = squeeze(wstar_clos(:,1,:,i));
     inBetween = [y(1,:),fliplr(y(3,:))];
     fill(closed_f, inBetween,facecolor{i},'EdgeColor',[1 1 1],...
         'FaceAlpha',0.25);
     hold on; 
     line(closed,y([1 3],:),'Color',[0.50,0.50,0.50]); 
     line(closed,y(2,:),'Color',facecolor{i},'LineWidth',2);
  end 
  % X-label and axis
   xlabel('');
   axis([closed(1) closed(end) -Inf Inf])  
  % Y-label
   ylabel({'Target ($s = 1$)','Quota Price'},'Interpreter','latex');
  % Grid
   grid on 
   % Axes Box 
   box(axes5,'on');

 % Subplot (3,2): Quota Price (s = 1), TAC reductions, Both scenarios
 % Create axes
  axes6 = axes('Parent',h,'Position',pos{6});
  hold(axes6,'on');
  for i = 1:scen
     clear y
     y = squeeze(wstar_tac(:,1,:,i));
     inBetween = [y(1,:),fliplr(y(3,:))];
     fill(tac_pol_f, inBetween,facecolor{i},'EdgeColor',[1 1 1],...
         'FaceAlpha',0.25);
     hold on; 
     line(tac_pol,y([1 3],:),'Color',[0.50,0.50,0.50]); 
     line(tac_pol,y(2,:),'Color',facecolor{i},'LineWidth',2);
  end 
  % X-label and axis
   xlabel('');
   axis([tac_pol(1) tac_pol(end) -Inf Inf])  
  % Y-label
   ylabel('');
  % Grid
   grid on 
  % Axes Box 
   box(axes6,'on');

 % Subplot (4,1): Quota Price (s = 2), Closures, Both scenarios
 % Create axes
  axes7 = axes('Parent',h,'Position',pos{7});
  hold(axes7,'on');
  for i = 1:scen
     clear y
     y = squeeze(wstar_clos(:,2,:,i));
     inBetween = [y(1,:),fliplr(y(3,:))];
     fill(closed_f, inBetween,facecolor{i},'EdgeColor',[1 1 1],...
         'FaceAlpha',0.25);
     hold on; 
     line(closed,y([1 3],:),'Color',[0.50,0.50,0.50]); 
     line(closed,y(2,:),'Color',facecolor{i},'LineWidth',2);
  end 
  % X-label and axis
   xlabel('Closed areas (\%)','Interpreter','latex','FontSize',10);
   axis([closed(1) closed(end) -Inf Inf])  
  % Y-label
   ylabel({'Bycatch ($s = 2$)','Quota Price '},'Interpreter','latex');
  % Grid
   grid on 
  % Axes Box 
   box(axes7,'on');

 % Subplot (4,2): Quota Price (s = 2), TAC reductions, Both scenarios
 % Create axes
  axes8 = axes('Parent',h,'Position',pos{8});
  hold(axes8,'on');
  for i = 1:scen
     clear y
     y = squeeze(wstar_tac(:,2,:,i));
     inBetween = [y(1,:),fliplr(y(3,:))];
     fill(tac_pol_f, inBetween,facecolor{i},'EdgeColor',[1 1 1],...
         'FaceAlpha',0.25);
     hold on; 
     line(tac_pol,y([1 3],:),'Color',[0.50,0.50,0.50]); 
     line(tac_pol,y(2,:),'Color',facecolor{i},'LineWidth',2);
  end 
  % X-label and axis
   xlabel('Reduction in $TAC_{2}$ (\%)','Interpreter','latex','FontSize',10);
   axis([tac_pol(1) tac_pol(end) -Inf Inf])  
  % Y-label
   ylabel('');
  % Grid
   grid on 
  % Axes Box 
   box(axes8,'on');
   
 % Create Legend
  axes9 = axes('Parent',h,'Position',[0 0 1 0.1]);
  axis off   
  legend1 = legend(axes9,'show',pl,{'Scenario 1','Scenario 2'});
  set(legend1,'Orientation','horizontal','Position',pos{9},'FontSize',9);  
 
%% Export Figure
    switch export
        case 'yes'
            print([path filename],'-dpng')
            savefig(figurename); 
        otherwise
    end
end
  
