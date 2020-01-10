%% In-Sample Performance Table
% * Filename: performance_table.m
% * Authors: Matt Reimer
% * Created: 07/11/19
% * Updated: 010/24/19
% * Purpose: Function that collates in-sample performance metrics and
% data-generating parameters into a table
%
%% Description
% 
%% Notes
% * Can generalize future code to allow use to input the regressors and
% outputs that they want included in the table. For now, they are
% hard-coded into the function.
%
function T = performance_table(results,estimates,params)

%% Regressors
% From Parameter Structure
    vars = {'observations','years','species','sigma'};
    for i = 1:numel(params)
            P.(vars{1})(i,:) = params(i).individuals*params(i).periods;
        for j = 2:numel(vars)
            P.(vars{j})(i,:) = params(i).(vars{j});
        end
    end
    
%% Outcomes
% From Estimates and Results Structure
    sc = 'RERUM';
    out = {'bias','rmse','est_time','convergence'};
    for i = 1:numel(params)
            P.(out{1})(i,:) = results.bias.(sc)(1,i);
            P.(out{2})(i,:) = results.rmse.(sc)(1,i);
            P.(out{3})(i,:) = estimates.(sc)(i).(out{3})/3600;
            P.(out{4})(i,:) = estimates.(sc)(i).ms_out.pct_corr;
    end
    
%% Table
    T = struct2table(P);
    
end