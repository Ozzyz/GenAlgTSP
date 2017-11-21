% low level function for TSP mutation
% insert mutation: two random cities a,b are chosen and b is moved to a
% Representation is an integer specifying which encoding is used
%	1 : adjacency representation
%	2 : path representation
%

function NewChrom = insertion(OldChrom,Representation);

NewChrom=OldChrom;

if Representation==1 
	NewChrom=adj2path(NewChrom);
end

% select two positions in the tour

rndi=zeros(1,2);

while rndi(1)==rndi(2)
	rndi=rand_int(1,2,[1 size(NewChrom,2)]);
end
rndi = sort(rndi);

Chrom_middle = NewChrom(rndi(1)+1:rndi(2)-1);
NewChrom(rndi(1)+1) = NewChrom(rndi(2));
NewChrom(rndi(1)+2:rndi(2)) = Chrom_middle;

if Representation==1
	NewChrom=path2adj(NewChrom);
end


% End of function
