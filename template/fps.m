% FPS.M          (Fitness Proportional Selection)
%
% This function performs selection with probability proportional to the fitness.
%
% Syntax:  NewChrIx = fps(FitnV, Nsel)
%
% Input parameters:
%    FitnV     - Column vector containing the fitness values of the
%                individuals in the population.
%    Nsel      - number of individuals to be selected
%
% Output parameters:
%    NewChrIx  - column vector containing the indexes of the selected
%                individuals relative to the original population, shuffled.
%                The new population, ready for mating, can be obtained
%                by calculating OldChrom(NewChrIx,:).

% Author:     Aasmund Brekke
% History:    19.11.17     file created
%             

function NewChrIx = fps(FitnV,Nsel)

% Perform fitness proportionate selection
   NewChrIx = zeros(1,Nsel);
   cumfit = cumsum(FitnV)/sum(FitnV);
   num_selected = 1;
   disp(cumfit);
   while(num_selected <= Nsel)
       r = rand();
       index = 1;
       for p = cumfit
           if p >= r
              NewChrIx(num_selected) = index;
              num_selected = num_selected + 1;
              break;
           end
           index = index + 1;
       end
   end
% Shuffle new population
   [~, shuf] = sort(rand(Nsel, 1));
   NewChrIx = NewChrIx(shuf);
% End of function
