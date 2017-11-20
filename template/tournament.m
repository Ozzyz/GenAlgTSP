% TOURNAMENT.M          (Tournament Selection)
%
% This function performs tournament selection - comparing k individuals
% randomly and choosing the best of them.
% 
%
% Syntax:  NewChrIx = tournament(FitnV, Nsel, k)
%
% Input parameters:
%    FitnV     - Column vector containing the fitness values of the
%                individuals in the population.
%    Nsel      - number of individuals to be selected
%   
%    K         - how many individuals to consider in each tournament
% Output parameters:
%    NewChrIx  - column vector containing the indexes of the selected
%                individuals relative to the original population, shuffled.
%                The new population, ready for mating, can be obtained
%                by calculating OldChrom(NewChrIx,:).

% Author:     Aasmund Brekke
% History:    19.11.17     file created
%             



function NewChrIx = tournament(FitnV,Nsel, k)

% Perform tournament selection
   NewChrIx = zeros(1,Nsel);
   num_selected = 1;
   % Indices of individuals
   Indices = 1:length(FitnV);
   
   while(num_selected <= Nsel)
       % Sample indices without replacement
       SampleIndices = datasample(Indices, k);
       % Get fitness values of chosen individuals
       FitnValues = FitnV(SampleIndices);
       % Find best individual of the chosen k
       [~, argmax] = max(FitnValues);
       NewChrIx(num_selected) = SampleIndices(argmax);
       num_selected = num_selected + 1;
   end
% Shuffle new population
   [~, shuf] = sort(rand(Nsel, 1));
   NewChrIx = NewChrIx(shuf);
% End of function
end