%% Figure Files for Plotting Simulated Data
% * Filename: fig_wstar.m
% * Authors: Matt Reimer
% * Created: 11/28/18
% * Updated: 11/28/18
% * Purpose: 
%
%% Description
% The function |fig_star| returns function handles for figures that plot
% simulation results from the data generating process.
%
function h = fig_wstar(data,flag,export,filename)

% Convert from Structure to Array
    yr = 1;
    for k = 1:numel(data)
        data1(:,:,k) = data(k).wstar(:,:,yr);
        data2(:,:,k) = data(k).remainTAC(:,:,yr);
    end

% Preliminaries
    % Defaults
   if nargin < 3
       export = 'no';
   end
   
    T = size(data1,1);
    N = size(data(1).choice,1);
    S = size(data1,2);
    path = 'C:\Users\mnrei\Dropbox\Apps\Overleaf\Structural Behavioral Models for Rights-Based Fisheries\figures\';
    
switch flag
    % Plot a single realization 
    case 'single'   
        if nargin < 5
            filename = 'fig_wstar_single';
        end
            figurename = ['figures\' filename '.fig'];
        k = 1; 
        for i = 1:S
            data2(:,i,k) = 100*data2(:,i,k)/data2(1,i,k);
        end
        h = figure('Name','DGP: One Realization','Units', 'normalized',...
            'Position', [0.3738    0.2382    0.2691    0.3319]);
        subplot(2,2,1)
            plot(data1(:,:,k),'LineWidth',2); grid on; 
            title('Quota Prices'); xlabel('Period (t)'); ylabel('Price'); 
            legend('Species 1','Species 2'); axis([1 size(data2,1) 0 inf]);
        subplot(2,2,2)    
            plot(data2(:,:,k),'LineWidth',2); grid on; 
            title('Remaining Quota'); xlabel('Period (t)'); ylabel('Remaining TAC (%)'); 
            legend('Species 1','Species 2'); axis([1 size(data1,1) 0 inf]);
        subplot(2,2,3)
            J = size(data.COV,4);
            x = 100*histcounts(data.choice(:,:,yr),1:1:J+1)/(T*N);    % Percent of choices
            x = reshape(x',J^0.5,J^0.5);
            image(x,'CDataMapping','scaled'); colorbar;
            title('Location Choices (%)'); xlabel('X-coordinate'); ylabel('Y-coordinate'); 
        subplot(2,2,4)
            y = squeeze(sum(data(k).harvest(:,:,:,yr),1));
            b = bar(y); grid on;
            set(b(1),'DisplayName','Species 1',...
                'FaceColor',rgb('DodgerBlue'));
            try % In case S < 2
                set(b(2),'DisplayName','Species 2',...
                    'FaceColor',rgb('DarkOrange'));
            end
            title('Fleet-wide Harvest'); xlabel('Period (t)'); ylabel('Harvest'); 
            legend('Species 1','Species 2'); axis([1 size(data2,1) 0 inf]);
            
    case 'all'
        if nargin < 5
            path = 'C:\Users\mnrei\Dropbox\Apps\Overleaf\Structural Behavioral Models for Rights-Based Fisheries\figures\';
            filename = 'fig_wstar_all';
        end
            figurename = ['figures\' filename '.fig'];
        % Figure Details
        h = figure('Units', 'normalized', 'Position', [0.3008    0.5632    0.3227    0.2701]);
        ymax = max(max(max(data1)));
        %if ymax > 10, ymax = 10; end % Manual option for dealing with outliers that skew figure.
        K = size(data1,3);
        linecolor = {'DodgerBlue','DarkOrange'};
        
        for s = 1:2
            % Quantiles
            quant = quantile(squeeze(data1(:,s,:))',[0.25 0.5 0.75],1);
            % Subplots
            subplot(1,2,s)
            for k=1:K
                plot(1:1:T,data1(:,s,k),'Color',rgb(linecolor{s}),'LineWidth',1.25); grid on;
                title(['Equilibrium Price: S_{',num2str(s),'}']); xlabel('Period'); ylabel('Price')
                axis([1 T 0 ymax]);
                hold on
            end
            plot(1:1:T,quant(1,:),'Color','k','LineWidth',2,'LineStyle','--');
            plot(1:1:T,quant(2,:),'Color','k','LineWidth',2);
            plot(1:1:T,quant(3,:),'Color','k','LineWidth',2,'LineStyle','--');
            hold off
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

       
        