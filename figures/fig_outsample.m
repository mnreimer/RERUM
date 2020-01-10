%% Figure File for Plotting Out-of-Sample Performance
% * Filename: fig_outsample.m
% * Authors: Matt Reimer
% * Created: 03/06/19
% * Updated: 11/04/19
% * Purpose: 
%
%% Description
% The function |fig_outsample| returns a function handle that plots
% out-of-sample performance metrics for hypothetical bycatch TAC reductions
% and hot-spot closures.
%
%% Notes
% * |D| is a structural array containing simulation results for two types
% of bycatch reduction policies (closures and tac reductions), as well as
% baseline (or status quo) simulations.
% * |policies| is a cell array containing vectors of the reductions
% evaluated in the simulations.
%
function h = fig_outsample(D,policies,export,filename)
% 
%% PRELIMINARIES
 % Policies to be examined
 est_sc = fieldnames(D);
 scen = size(D.TRUE.netrev.tac,2);
 closed = policies.clos;
 tac_pol = policies.tac;

 % Figure parameters
 width = 2;                          % Distance between markers (for jittering)
 sz = 4;                             % Marker size
 lwdth = 0.75;                       % Line Width (for whiskers)
 
 % X-axis variable
 x0_tac = policies.tac;
 x0_clos = policies.tac;
 ax_tac = [x0_tac(1)-width,x0_tac(end)+width,-inf,inf];
 ax_clos = [x0_clos(1)-width,x0_clos(end)+width,-inf,inf];
 
 % Figure export 
  path = 'C:\Users\mnrei\Dropbox\Apps\Overleaf\Structural Behavioral Models for Rights-Based Fisheries\figures\';
  if nargin < 4
      filename = 'fig_outsample';
  end
  if nargin < 3
      export = 'no'; 
  end
  figurename = ['figures\' filename '.fig']; 
  
%% Summary Statistics
 % Performance metrics
 for i = 1:scen
     % TAC Policies: Relative to baseline
     for es = 1:numel(est_sc)
         esc = est_sc{es};
         xbase = D.(esc).bycatch.tac(:,i,1);
         ybase = D.(esc).netrev.tac(:,i,1);
         for tp = 1:numel(tac_pol)
             x.(esc)(:,tp) = 100*(D.(esc).bycatch.tac(:,i,tp) - xbase)./xbase;
             y.(esc)(:,tp) = 100*(D.(esc).netrev.tac(:,i,tp) - ybase)./ybase;
         end
     end
     % TAC Policies: relative to TRUE model
     for es = 1:numel(est_sc)
         esc = est_sc{es};
         for tp = 1:numel(tac_pol)
             bycatch_tac(i).(esc)(:,tp) = prctile(x.(esc)(:,tp) - ...
                 x.TRUE(:,tp),[25 50 75],1);
             netrev_tac(i).(esc)(:,tp) = prctile(y.(esc)(:,tp) - ...
                 y.TRUE(:,tp),[25 50 75],1);
         end
     end
     
    % Closure Policies: Relative to baseline
     clear xbase ybase x y
     for es = 1:numel(est_sc)
         esc = est_sc{es};
         xbase = D.(esc).bycatch.clos(:,i,1);
         ybase = D.(esc).netrev.clos(:,i,1);
         for cl = 1:numel(closed)
             x.(esc)(:,cl) = 100*(D.(esc).bycatch.clos(:,i,cl) - xbase)./xbase;
             y.(esc)(:,cl) = 100*(D.(esc).netrev.clos(:,i,cl) - ybase)./ybase;
         end
     end
     % Closure Policies: relative to TRUE model
     for es = 1:numel(est_sc)
         esc = est_sc{es};
         for cl = 1:numel(closed)
             bycatch_clos(i).(esc)(:,cl) = prctile(x.(esc)(:,cl) - ...
                 x.TRUE(:,cl),[25 50 75],1);
             netrev_clos(i).(esc)(:,cl) = prctile(y.(esc)(:,cl) - ...
                 y.TRUE(:,cl),[25 50 75],1);
         end
     end
 end
     
%% Figure
 clear x y
 h = figure('Name','Out-of-sample Performance: Spatial Closures',...
     'Units','normalized','Position',[0.4203    0.1660    0.3797    0.7111]);
 
 % Subplot 1: (Scenario 1, Closures)
  % Create axes 
   axes1 = axes('Parent',h,'Position',[0.1,0.57,0.37,0.3]);
   hold(axes1,'on');  
  % Outcome variables, by scenario
   out = netrev_clos(1);  
   out = rmfield(out,'TRUE');
  % Utility specification names
   fields = fieldnames(out);   
  % Jittering markers
   jitter = linspace(-width,width,numel(fields));  
  % Loop through utility specifications
   SC = numel(fields); 
   for sc = 1:SC
    scenario = fields{sc};
    x = x0_clos + jitter(sc);                   % Jittered x values
    Y = vertcat(out.(scenario));                % Stack results
    y = Y(2,:);                                 % Median values
    neg = y - Y(1,:); pos = Y(3,:) - y;         % Error bar values
    errorbar(x,y,neg,pos,'Marker','o','MarkerFaceColor','auto',...
        'MarkerSize',sz,'LineWidth',lwdth); 
    hold on;
   end  
  % Set X-axis Ticks
   set(gca,'XTick',0:15:75); 
  % X-label and axis
   xlabel('Closed areas (%)');
   axis(ax_clos);
  % Y-label 
   ylabel('Prediction Error');
  % Title
   title('Scenario 1: Closures','Interpreter','latex');
  % Grid
   grid on
  % Axes Box 
   box(axes1,'on'); 
   
 % Subplot 2: (Scenario 2, Closures)
  % Create axes 
   axes2 = axes('Parent',h,'Position',[0.56,0.57,0.37,0.3]);  
   hold(axes2,'on');  
  % Outcome variables, by scenario
   out = netrev_clos(2);  
   out = rmfield(out,'TRUE');
  % Utility specification names
   fields = fieldnames(out);   
  % Jittering markers
   jitter = linspace(-width,width,numel(fields));  
  % Loop through utility specifications
   SC = numel(fields); 
   for sc = 1:SC
    scenario = fields{sc};
    x = x0_clos + jitter(sc);                   % Jittered x values
    Y = vertcat(out.(scenario));                % Stack results
    y = Y(2,:);                                 % Median values
    neg = y - Y(1,:); pos = Y(3,:) - y;         % Error bar values
    errorbar(x,y,neg,pos,'Marker','o','MarkerFaceColor','auto',...
        'MarkerSize',sz,'LineWidth',lwdth); 
    hold on;
   end  
  % Set X-axis Ticks
   set(gca,'XTick',0:15:75); 
  % X-label and axis
   xlabel('Closed areas (%)');
   axis(ax_clos);
  % Y-label 
%    ylabel('Prediction Error');
  % Title
   title('Scenario 2: Closures','Interpreter','latex');
  % Grid
   grid on
  % Axes Box 
   box(axes2,'on');    
   
 % Subplot 3: (Scenario 1, TACs)
  % Create axes 
   axes3 = axes('Parent',h,'Position',[0.1,0.136,0.37,0.3]);
   hold(axes3,'on');  
  % Outcome variables, by scenario
   out = netrev_tac(1);  
   out = rmfield(out,'TRUE');
  % Utility specification names
   fields = fieldnames(out);   
  % Jittering markers
   jitter = linspace(-width,width,numel(fields));  
  % Loop through utility specifications
   SC = numel(fields); 
   for sc = 1:SC
    scenario = fields{sc};
    x = x0_clos + jitter(sc);                   % Jittered x values
    Y = vertcat(out.(scenario));                % Stack results
    y = Y(2,:);                                 % Median values
    neg = y - Y(1,:); pos = Y(3,:) - y;         % Error bar values
    errorbar(x,y,neg,pos,'Marker','o','MarkerFaceColor','auto',...
        'MarkerSize',sz,'LineWidth',lwdth); 
    hold on;
   end  
  % Set X-axis Ticks
   set(gca,'XTick',0:15:75); 
  % X-label and axis
   xlabel('Reduction in TAC_{2} (%)');
   axis(ax_tac);
  % Y-label 
   ylabel('Prediction Error');
  % Title
   title('Scenario 1: TAC Reductions','Interpreter','latex');
  % Grid
   grid on
  % Axes Box 
   box(axes3,'on');  
   
 % Subplot 4: (Scenario 2, TACs)
  % Create axes 
   axes4 = axes('Parent',h,'Position',[0.56,0.136,0.37,0.3]);
   hold(axes4,'on');  
  % Outcome variables, by scenario
   out = netrev_tac(2);  
   out = rmfield(out,'TRUE');
  % Utility specification names
   fields = fieldnames(out);   
  % Jittering markers
   jitter = linspace(-width,width,numel(fields));  
  % Loop through utility specifications
   SC = numel(fields); 
   for sc = 1:SC
    scenario = fields{sc};
    x = x0_clos + jitter(sc);                   % Jittered x values
    Y = vertcat(out.(scenario));                % Stack results
    y = Y(2,:);                                 % Median values
    neg = y - Y(1,:); pos = Y(3,:) - y;         % Error bar values
    sub(sc) = errorbar(x,y,neg,pos,'Marker','o','MarkerFaceColor','auto',...
        'MarkerSize',sz,'LineWidth',lwdth); 
    hold on;
   end  
  % Set X-axis Ticks
   set(gca,'XTick',0:15:75); 
  % X-label and axis
   xlabel('Reduction in TAC_{2} (%)');
   axis(ax_tac);
  % Y-label 
%    ylabel('Prediction Error');
  % Title
   title('Scenario 2: TAC Reductions','Interpreter','latex');
  % Grid
   grid on
  % Axes Box 
   box(axes4,'on');
   
 % Create Legend
  axes5 = axes('Parent',h,'Position',[0 0 1 0.2]);
  axis off   
  legend1 = legend(axes5,'show',sub,fields,'Position',[0.3,0.01,0.4,0.05],...
      'FontSize',9);
   
  set(legend1,'Orientation','horizontal'); 
  
%% Export Figure
    switch export
        case 'yes'
            print([path filename],'-dpng')
            savefig(figurename); 
        otherwise
    end
end
  
