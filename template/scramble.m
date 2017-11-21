% low level function for TSP mutation
% scramble mutation: two random cities a,b are chosen and citys between
% them are scrambled
% Representation is an integer specifying which encoding is used
%	1 : adjacency representation
%	2 : path representation
%

function NewChrom = scramble(OldChrom,Representation);

RANGE = length(OldChrom);
NewChrom=OldChrom;

if Representation==1 
	NewChrom=adj2path(NewChrom);
end

% select two positions in the tour

rndi=zeros(1,2);

while ((abs(rndi(1)-rndi(2)) > RANGE) || (rndi(1)==rndi(2)))
	rndi=rand_int(1,2,[1 size(NewChrom,2)]);
end
rndi = sort(rndi);
NewChrom(rndi(1):rndi(2)) = NewChrom(randperm(length(NewChrom(rndi(1):rndi(2))))+rndi(1)-1);

if Representation==1
	NewChrom=path2adj(NewChrom);
end


% End of function