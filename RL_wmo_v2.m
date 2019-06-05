%% Set-up
%Requires psychtoolbox function Shuffle

%arbitrarily set s-a pairs
trials = 40;
%lowercase letters are correct responses....def not the best way to do this. 
State_pairs = Shuffle(repelem({'Aj','Bk','Cl'}, trials));

%model Parameters
alpha = 0.5; %set arbitrarily 
gamma = [];
%initial values
action = 'l';% set arbitrarily
Available_actions = {'j','k','l'};
Q = zeros(trials, 4, size(State_pairs,2)/trials);%initialize q table: |state|a1|a2|a3|

%Generate fieldnames for each state to store q table
%for x=1:size(State_pairs,2)/trials
    
 %   Q.(['state',num2str(x)]) = zeros(trials, 4, size(State_pairs,2));
%end


R = {zeros(trials, 1),repelem({'x'}, trials),nan(1, trials)};


%% Model
%var t iterates through trials
%var i iterates through Q table. vars ia, ib, ic indicate the index for
%each state - gets incremented only if the current trial is state a,b, or
%c. This it to prevent gaps in Q table. 

i  = [];
ia = 0;
ib = 0;
ic = 0;
for t = 1:length(State_pairs) - 1
    
    %current state s
    
    switch State_pairs{t}(1)
        case 'A'
            s = 1;
           ia = 1 + ia;
           i= ia;
        case 'B'
            s = 2;
         
          ib = 1 + ib;
           i= ib;
        case 'C'
            s = 3;

           ic = 1 + ic;
           i= ic;
    end

    
    %to reward or not to reward
    if strcmp(State_pairs{t}(2), action)
        rewardVal = 1;
    else
        rewardVal = 0;
    end

    %
    Q(i, 1, s) = t; %just an index to the State_pairs cell.
    R{1}(t) = s;
      
    %update Q table 
    
    
    Q(i+1, 2:end, s) = Q(i, 2:end, s) + alpha * (rewardVal - Q(i, 2:end, s));
         
    
    %some probability mood and action selection
 
         boltz_out = boltzmann(Q(i+1,2:end, s));
       
         prob = unifrnd(0,1);
         
         choice = prob < boltz_out;
         
         %if more than 1 action satisfies the condition, select the first
         %option
         if sum(choice) > 2
            choice = [1 zeros(1,length([1 2 3])-1)];
         end   
      % [~, choice] = max(boltzmann(Q(t+1,2:end)));
           action = Available_actions{choice};
     
     %save data 
      R{2}(t) = {action};
      R{3}(t) = rewardVal;
end



disp(['Total Acc: ' num2str(mean(R{3}))])



%% functions
function varargout = boltzmann(varargin)
%performs noisy boltzman selection process and returns probabilities. 
%Requires input from Q table for n available actions
%added cumsum to boltzmann output

[varargout{1:nargout}] = cumsum( exp(varargin{:}) / sum(exp(varargin{:})));
    
end

