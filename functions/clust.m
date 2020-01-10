%% Parallel Computing Clusters
% * Filename: clust.m
% * Authors: Matt Reimer
% * Created: 06/01/17
% * Updated: 07/01/19
% * Purpose: 
%
%% Description
% The function |clust| returns an cluster object for parallel computing.
%
    function [c,poolsize] = clust(x,open)
        % Default parameters
        if (nargin<2 || isempty(open)), open='yes'; end
        
        % Close cluster that's open
        delete(gcp('nocreate'))
        
        % Cloud, local, and no cluster
        switch x
            case 'local'    % Use local clusters
                c = parcluster('local'); poolsize = 4;  
                switch open
                    case 'yes'
                        parpool(c,poolsize)
                end
            case 'cloud'    % Use cloud clusters
                c = parcluster('Work Computer 18core cluster'); poolsize = 18;
                start(c); wait(c);
                switch open
                    case 'yes'
                        parpool(c,poolsize)
                end
            otherwise
                c = []; poolsize = [];
        end
    end