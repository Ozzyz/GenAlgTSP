% EDGE_RECOMBIN.M
% Based on Whitley's Edge Recombination
% This method assumes PATH REPRESENTATION.
%   INPUTS:
%   OldChrom:  Matrix containing the chromosomes of the old
%                population. Each line corresponds to one individual
%                (in any form, not necessarily real values)
%   XOVR      - Probability of recombination occurring between pairs
%                of individuals.
%

function NewChrom = edge_recomb(OldChrom, XOVR)
    % For each pair of parents, make one new individual that combines the
    % edges of the parents. Based on D.Whitley's algorithm.
    dim = size(OldChrom);
    num_individuals = dim(1);
    num_cities = dim(2);
    
    % Use two parents for each recombination
    num_recombinations = num_individuals/2;
    do_cross = rand(num_recombinations,1) < XOVR;
    edgetable = make_edgetable(OldChrom);
    NewChrom = [];
    for i = 1:num_recombinations
        if ~do_cross(i)
            continue
        end
        % Common edges between parent i and j for each city
       union_edges = cell(num_cities);
       
       % Convert from cell format in order to use union
       % These are vectors for each
       for city = 1: num_cities
           p1_edges = cell2mat(edgetable(city, i));
           p2_edges = cell2mat(edgetable(city, i+1));
           % Convert back to save for cell
           all_edges = union(p1_edges, p2_edges);
           % Create nx1 size cell
           union_edges(city) = mat2cell(all_edges, 1,length(all_edges));
       end
       p1 = OldChrom(i);
       p2 = OldChrom(i+1);
       parents = [p1, p2];
       K = zeros(num_cities, 1);
       % Select random parent
       p = randi([1 2], 1, 1);
       chosen_parent = parents(p);
       % Select first city of parent
       N = chosen_parent(1);
       % For each iteration, pick a city and remove its references from the
       % union edgetable of the parents. 
       
       for j = 1:num_cities-1
          K(j) = N;
          [union_edges, N] = remove_edge(union_edges, N, K);
       end
       K(j+1) = N;
       % Append the new route to list
       NewChrom(i, :) = K;
    end
    
    % If there are a odd number of parents, the last one can not be mated,
    % but must be included in the new generation
    if rem(num_individuals, 2)
        NewChrom(num_individuals, :) = OldChrom(num_individuals, :);
    end
    
end

function [union_edgetable, N] = remove_edge(union_edgetable, city, K)
    % Removes a city from the edgetable and returns the next city to be
    % added to path
    % INPUT: Union edgetable: The table showing the neighbours of each city
    % for the two selected parents
    %        City : The currently selected city. Will be deleted in every
    %        entry of the edgetable
    %        K    : The current path
    % RETURNS:
    %        union_edgetable: The modified edgetable with all entries of
    %        {city} removed
    %        N: The next city to be added to path
    %
    
    cur_city_neigh = [];
    % Store the number of neighbours for each city - used to find best city
    % to visit next
    num_neighbours = zeros(length(union_edgetable), 1);
    num_cities = length(union_edgetable);
    % Remove the given city from each entry in the edgetable
    for i = 1:length(union_edgetable)
        neighbours = cell2mat(union_edgetable(i));
        neighbours = neighbours(neighbours ~= city);
        filtered_list = neighbours;
        num_neighbours(i) = length(filtered_list);
        if(isempty(filtered_list))
           union_edgetable{i} = []; 
        else
            union_edgetable(i) = mat2cell(filtered_list, 1, length(filtered_list));
        end
        if i == city
            cur_city_neigh = filtered_list;
        end
        
    end
    % If the city's neighbour list is not empty
    if ~isempty(cur_city_neigh)
       %then let N* be the neighbor of N with the fewest neighbors in its list (or a random one, should there be multiple)
       minimum = Inf;
       min_neighbours = [];
       count = 1;
       for cur_city = cur_city_neigh
           if num_neighbours(cur_city) <= minimum && cur_city ~= city
               min_neighbours(count) = cur_city;
               minimum = min_neighbours(count);
               count = count + 1;
           end
       end
       % Choose a random city of the given cities with shortest neighbour
       % lists
       N = min_neighbours(randi(length(min_neighbours)));
    else
        % Find all cities that are still not 'taken'
        available_cities = setdiff(1:num_cities, K);
        N = available_cities(randi(length(available_cities)));
    end
end

function EdgeTable = make_edgetable(OldChrom)
    % Make edgetable where EdgeTable[i, j] is the neighbours of i
    % in individual j 
    % this is made for each individual in oldchrom
    dim = size(OldChrom);
    num_individuals = dim(1);
    num_cities = dim(2);
    % Edgetable can maximum have four neighbours
    EdgeTable = cell(num_cities, num_individuals);
    for individual = 1:num_individuals
        ind_chrom = OldChrom(individual, :);
        
        for city_index = 1:num_cities
            city = ind_chrom(city_index);
            % If city is first in list, it has a neighbour at the far end
            % of the representation
            
            left = city_index - 1;
            right = city_index + 1;
            if city_index == 1
                left = num_cities;
            elseif city_index == num_cities
                right = 1;
            end 
            neighbours = [ind_chrom(left), ind_chrom(right)];
            EdgeTable{city, individual} = neighbours;
        end
    end
end