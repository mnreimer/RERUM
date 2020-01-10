%% Evaluate Out-of-sample Performance
% * Filename: evaluate_out.m
% * Authors: Matt Reimer
% * Created: 02/28/19
% * Updated: 011/01/19
% * Purpose: Simulates counterfactual policies and compares policy
% predictions to the true model.
%
%% Description
% * The function |evaluate_out| is the main function for generating
% out-of-sample policy predictions, given a set (or distribution) of
% parameters and a behavioral model. The function draws heavily on the
% function |dgpdraw|, which generates data from the dgp under the
% counterfactual policy scenarios. The main purpose of this function is to
% loop through the different policies, behavioral models, and biological
% scenarios, as well as to exploit parallel and cloud processing for
% generating several draws from the dgp.
%
%% Notes:
% * Called by: |policy_simulations|
%
function [out,policies] = evaluate_out(b,par,est_sc,closed,tac_pol,draws,start,btstrp)
%% Input arguments:
% * |b| = a structural array of parameter estimates.
% * |par| = a structural array of dgp parameters.
% * |est_sc| = a structural array of scenarios used for estimation (include
% TRUE model);
% * |closed| = a vector of closure policy simulation scenarios.
% * |tac_pol| = a vector of TAC policy simulation scenarios.
% * |draws| = number of draws from dgp for policy simulation
% * |start| = a scalar indicating the starting seed number value. 
% * |btstrp| = a string indicating whether parameter estimates are bootstrapped. 
%
%% Output arguments:
% * |out| = structural array of performance metrics.
% * |policies| = structural array of policy change values.
%
%% Preliminaries
 % Default handling of parameter estimate distributions
  if nargin < 8, btstrp = 'no'; end

 % Starting seed number default
  if nargin < 7, start = 0; end
  
 % Monte Carlo draws for policy simulation
  % Note: This do not need to be the same as it was for estimation
  if (nargin < 6 || isempty(draws)), draws = 1; end
  
  % Default simulation parameters
  parnames = {'years','periods','individuals','gridsize','species',...
      'btrue','sigma','tac','price'};   
  parvals = {1,50,20,10,2,[1;-0.4],3,[1.3e-2,0.7e-2],[1000;0]}; 
  par = set(par,parnames,parvals);
  btrue = par.btrue;
  
 % Default DGP Scenarios
  dat_sc.par = {'mu'};               % Data-generating parameter
  dat_sc(1).val = {[-2.5,2.5;2.5,-2.5]};   
  dat_sc(2).val = {[1.5,1.5;0,0]};   % Data-generating param values
  
 % Number of parameter estimates
 for es = 1:numel(est_sc)
     if strncmp('TRUE',est_sc(es),4)
         sz(es) = 1;
     else
         esc = est_sc{es};
         sz(es) = size(b(1).(esc),2);
     end
 end
     
 % Parameter Estimates
  for ds = 1:numel(dat_sc)
      for es = 1:numel(est_sc)
          esc = est_sc{es};
          switch btstrp
              case 'no' % Average beta across MC draws
                  switch esc
                      case 'TRUE'
                          b_est(ds).(esc) = btrue;
                      otherwise
                          b_est(ds).(esc) = ...
                              mean(b(ds).(esc),2);
                  end
              case 'yes' % Pass through all betas across MC draws
                for k = 1:sz(es)
                    switch esc
                        case 'TRUE'
                            b_est(ds).(esc)(k).b = btrue;
                        otherwise
                            b_est(ds).(esc)(k).b = b(ds).(esc)(:,k);
                    end
                end
          end
      end
  end
  
 % Parallel computing constants (values are constant across workers) 
  a = parallel.pool.Constant(b_est); 
    
%% Out-of-sample Predictions 
 % Notications for tracking progress
  fprintf('\nSimulating Out-of-Sample scenarios using %d draws.\n',draws);
  fprintf('Progress:\n');                     
  fprintf([repmat('.',1,draws) '\n\n'])
  tic; 
  
 % Loop over draws
  parfor k = 1:draws
       % Retrieve scenarios and parameters from parallel.pool.constant
       b_est = a.Value; 
       
       % Setup temporary variables for slicing in nested for loops
       [xtac,ytac] = deal(zeros(numel(dat_sc),numel(tac_pol),numel(est_sc)));
       [xclos,yclos] = deal(zeros(numel(dat_sc),numel(closed),numel(est_sc)));
       ztac = zeros(2,numel(dat_sc),numel(tac_pol));
       zclos = zeros(2,numel(dat_sc),numel(closed));

       % Seed number for draw
        kk = k + start;
        
       % Loop over data scenarios
       for ds = 1:numel(dat_sc) 
           % Update scenario-specific parameters
           p = set(par,dat_sc(1).par,dat_sc(ds).val);
           
           % Baseline data: for quota-prices and closures
           D = dgpdraw(btrue,p,'TRUE',kk);
           w_obs = D.wstar;
           C = hotspots(D,[],p);
           
           % SIMULATIONS: TAC REDUCTIONS
           for tp = 1:numel(tac_pol)
               % TAC reduction
               red = (1-(tac_pol(tp))/100);
               % Update TACs in parameters
               p_tac = set(p,{'tac'},{[p.tac(1),p.tac(2)*red]});
               % Loop over estimation scenarios
               for es = 1:numel(est_sc)
                   esc = est_sc{es};
                   switch btstrp     
                       case 'no' % Use mean of estimated parameters
                        B = b_est(ds).(esc);   
                       case 'yes'    % Draw from parameter distribution
                        % Draw random number for parameter bootstrap
                        rng(kk), drw = randi([1 sz(es)],1);  
                        B = b_est(ds).(esc)(drw).b;  
                   end
                   D = dgpdraw(B,p_tac,esc,kk,[],w_obs);
                   % Bycatch and netrev
                   xtac(ds,tp,es) = sum(D.netrev(:));  % Pred netrev (across all N and T)
                   ytac(ds,tp,es) = D.TAC(1,2) - D.remainTAC(end,2);
                   % Quota lease prices (mean)
                   switch esc
                       case 'TRUE'
                           ztac(:,ds,tp) = mean(D.wstar,1,'omitnan');
                   end
               end
           end
               
          % CLOSURE SCENARIOS
          for cl = 1:numel(closed)
              % Find largest bycatch areas, on average
              [~,closures] = maxk(C,closed(cl),1); 
              % Loop over estimation scenarios
              for es = 1:numel(est_sc)
                  esc = est_sc{es};
                  switch btstrp     
                        case 'no' % Use mean of estimated parameters
                          B = b_est(ds).(esc);   
                        case 'yes'    % Draw from parameter distribution
                          % Draw random number for parameter bootstrap
                          rng(kk), drw = randi([1 sz(es)],1);                             
                          B = b_est(ds).(esc)(drw).b;  
                  end
                  D = dgpdraw(B,p,esc,kk,closures,w_obs);
                  % Bycatch and netrev
                  xclos(ds,cl,es) = sum(D.netrev(:));  % Pred netrev (across all N and T)
                  yclos(ds,cl,es) = D.TAC(1,2) - D.remainTAC(end,2);
                  % Quota lease prices (mean)
                  switch esc
                       case 'TRUE'
                           zclos(:,ds,cl) = mean(D.wstar,1,'omitnan');
                   end
              end
          end              
       end
       
       % Assign sliced arrays
       netrev_tac(k,:,:,:) = xtac; bycatch_tac(k,:,:,:) = ytac; 
       netrev_clos(k,:,:,:) = xclos; bycatch_clos(k,:,:,:) = yclos; 
       wstar_tac(k,:,:,:) = ztac; wstar_clos(k,:,:,:) = zclos;
       
       % Notify progress
       fprintf('\b|\n');
  end
  time = toc;
  fprintf('Finished: Total time = %d minutes.\n\n',time/60);
   
%% Outputs
 policies.tac = tac_pol;
 policies.clos = closed;  
 
 for es = 1:numel(est_sc)
    esc = est_sc{es};
    out.(esc).netrev.tac = netrev_tac(:,:,:,es);
    out.(esc).bycatch.tac = bycatch_tac(:,:,:,es);
    out.(esc).netrev.clos = netrev_clos(:,:,:,es);
    out.(esc).bycatch.clos = bycatch_clos(:,:,:,es);
 end  
    out.TRUE.wstar.tac = wstar_tac;
    out.TRUE.wstar.clos = wstar_clos;
  
  
end
        
        
        
   
        