% low level function for TSP local search (implementing simple 2opt)
% Representation is an integer specifying which encoding is used
%	1 : adjacency representation
%	2 : path representation
%

function NewChrom = localsearch2(oldChrom,Representation,Dist)

NewChrom=oldChrom;

if Representation==1 
	NewChrom=adj2path(NewChrom);
end

tour_length = tspfun(path2adj(NewChrom),Dist);
changed = 1;
while(changed)
    changed = 0;
    tour_length = tspfun(path2adj(NewChrom),Dist);
    for i=1:length(NewChrom)-1
        for k =i+1:length(NewChrom)
            tmpChrom = NewChrom;
            tmpChrom(i:k) = fliplr(NewChrom(i:k));
            tmp_tour_length = tspfun(path2adj(tmpChrom),Dist);
            if(tmp_tour_length < tour_length)
                NewChrom = tmpChrom;
                tour_length = tmp_tour_length;
                changed = 1;
                break;
            end 
        end
        if(changed)
            break;
        end
    end
end



if Representation==1
	NewChrom=path2adj(NewChrom);
end
end
