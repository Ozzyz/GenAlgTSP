function [r_path, r_dist, r_gen, r_best_fits, r_mean_fits, r_worst_fits] = run_ga2(x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, LOCALLOOP, PARENT_SELECTION, MUTATION)
% usage: [r_path, r_dist, 
%         r_gen, r_best_fits, 
%         r_mean_fits, r_worst_fits] 
%               =run_ga(x, y, 
%               NIND, MAXGEN, NVAR, 
%               ELITIST, STOP_PERCENTAGE, 
%               PR_CROSS, PR_MUT, CROSSOVER)
%
%
% x, y: coordinates of the cities
% NIND: number of individuals
% MAXGEN: maximal number of generations
% ELITIST: percentage of elite population
% STOP_PERCENTAGE: percentage of equal fitness (stop criterium)
% PR_CROSS: probability for crossover
% PR_MUT: probability for mutation
% CROSSOVER: the crossover operator
% 
% the returnvalues are the results of the ga and are further used for
% visualization

%uncomment if you want to dsiplay the parameters at the beginning of each run
%{NIND MAXGEN NVAR ELITIST STOP_PERCENTAGE PR_CROSS PR_MUT CROSSOVER LOCALLOOP} 

    GGAP = 1 - ELITIST;
    mean_fits=zeros(1,MAXGEN+1);
    worst=zeros(1,MAXGEN+1);
    Dist=zeros(NVAR,NVAR);
    for i=1:size(x,1)
        for j=1:size(y,1)
            Dist(i,j)=sqrt((x(i)-x(j))^2+(y(i)-y(j))^2);
        end
    end
    % initialize population
    Chrom=zeros(NIND,NVAR);
    for row=1:NIND
        Chrom(row,:)=path2adj(randperm(NVAR));
        %Chrom(row,:)=randperm(NVAR);
    end
    gen=0;
    % number of individuals of equal fitness needed to stop
    stopN=ceil(STOP_PERCENTAGE*NIND);
    % evaluate initial population
    ObjV = tspfun(Chrom,Dist);
    best=zeros(1,MAXGEN);
    % generational loop
    while gen<MAXGEN
        sObjV=sort(ObjV);
        best(gen+1)=min(ObjV);
        minimum=best(gen+1);
        mean_fits(gen+1)=mean(ObjV);
        worst(gen+1)=max(ObjV);
        for t=1:size(ObjV,1)
            if (ObjV(t)==minimum)
                break;
            end
        end

        %update return values for visualization
        r_path = adj2path(Chrom(t,:));
        r_gen = gen;
        r_dist = minimum;
        r_best_fits = best;
        r_mean_fits = mean_fits;
        r_worst_fits = worst;

        if (sObjV(stopN)-sObjV(1) <= 1e-15)
              break;
        end          
        %assign fitness values to entire population
        FitnV=ranking(ObjV);
        %select individuals for breeding
        SelCh=select(PARENT_SELECTION, Chrom, FitnV, GGAP);
        %recombine individuals (crossover)
        SelCh = recombin(CROSSOVER,SelCh,PR_CROSS);
        SelCh=mutateTSP(MUTATION,SelCh,PR_MUT);
        %evaluate offspring, call objective function
        ObjVSel = tspfun(SelCh,Dist);
        %reinsert offspring into population
        [Chrom ObjV]=reins(Chrom,SelCh,1,1,ObjV,ObjVSel);

        Chrom = tsp_ImprovePopulation(NIND, NVAR, Chrom,LOCALLOOP,Dist);
        %increment generation counter
        gen=gen+1;            
    end
end
