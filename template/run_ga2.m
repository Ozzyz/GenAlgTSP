function [r_path, r_dist, r_gen, r_best_fits, r_mean_fits, r_worst_fits] = run_ga2(x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, LOCALLOOP, PARENT_SELECTION, MUTATION, Dist, MU_LAMBDA)

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
    % This mut change is chosen pretty much at random, and has no
    % scientific backing whatsoever.
    MUT_CHANGE = 30*PR_MUT/MAXGEN;
    PR_CHANGE = 15*PR_CROSS/MAXGEN;
    GGAP = 1 - ELITIST;
    mean_fits=zeros(1,MAXGEN+1);
    worst=zeros(1,MAXGEN+1);
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
    prev_diversity = 0;
    
    CROSSPR = zeros(MAXGEN);
    MUTPR = zeros(MAXGEN);
    DIV = zeros(MAXGEN);
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
            disp('stop because of similar fitness values');
            break;
        end
        fprintf("Generation %d, best: %d\n", gen, min(ObjV));
        
        % Do adaptive parameter control
        % Measure diversity by looking at differece between the fitness of best
        % individual and the average fitness, divided by the difference
        % between the fitness of the best and the worst individual.
        diversity = ((1/min(ObjV)) - (1/mean(ObjV))) / ((1/min(ObjV)) - (1/max(ObjV)));
        %fprintf("Best fitness: %d, Worst fitness: %d, Mean fitness: %d\n", 1/min(ObjV), 1/max(ObjV), 1/mean(ObjV));
        %fprintf("Diversity: %d\n", diversity);
        % If the diversity decreases (change is negative), increase
        % mutation rate
        diversity_change = diversity - prev_diversity;
        %fprintf("Diversity change: %d\n", diversity_change);
        % Diversity increases - lower mut rate since we have explored more
        % of the search space
        if diversity_change > 0 && PR_MUT > 0.05
            %fprintf("Changed mutation rate from %d to %d \n", PR_MUT, PR_MUT-MUT_CHANGE);
            PR_MUT = PR_MUT - MUT_CHANGE;
        end
        % Diversity decreases - hopefully we are near a local optima- so
        % increase crossover between individuals

      
         %Diversity decreases - hopefully we are near a local optima- so
         %increase crossover between individuals
        if diversity_change < 0 && PR_CROSS < 0.8
            PR_CROSS = PR_CROSS + PR_CHANGE;
        end
        CROSSPR(gen+1) = PR_CROSS;
        MUTPR(gen+1) = PR_MUT;
        
        prev_diversity = diversity;
        DIV(gen+1) = prev_diversity;
        %new stopping criterion
        stop_interval = 50;
        if (gen > stop_interval)
            min_stop_delta = best(gen-stop_interval)*0.001;
            if(abs(best(gen-stop_interval) - best(gen)) < min_stop_delta)
                disp('stop because of no fitness improvement');
                break;
            end
        end
        %assign fitness values to entire population
        FitnV=ranking(ObjV);
        %select individuals for breeding
        SelCh=select(PARENT_SELECTION, Chrom, FitnV, GGAP);
        %recombine individuals (crossover)
        SelCh = recombin(CROSSOVER,SelCh,PR_CROSS);
        
        representation = 1;
        SelCh=mutateTSP(MUTATION,SelCh,PR_MUT, representation);
        %evaluate offspring, call objective function
        ObjVSel = tspfun(SelCh,Dist);
        %reinsert offspring into population
        % if mu_lambda is true, do  (mu, lambda) survivor selection
        if MU_LAMBDA
           [Num_Parents, ~] = size(Chrom);
           [Num_Children, ~] = size(SelCh);
           % if there are more parents than children, select all children
           if Num_Parents > Num_Children
              Chrom = SelCh;
              ObjV = ObjVSel;
           else
              Chrom = SelCh(1:Num_Parents, :);
              ObjV = ObjVSel(1:Num_Parents, :);
           end
        else 
           [Chrom, ObjV]= reins(Chrom,SelCh,1,1,ObjV,ObjVSel);
        end
        
        Chrom = tsp_ImprovePopulation(NIND, NVAR, Chrom,LOCALLOOP,Dist);
        %increment generation counter
        gen=gen+1;            
    end
    %{
    hold off;
    figure;
    CROSSPR = CROSSPR(1:gen);
    MUTPR = MUTPR(1:gen);
    DIV = DIV(1:gen);
    plot(linspace(0,gen, gen), CROSSPR);
    hold on;
    plot(linspace(0, gen, gen), MUTPR);
    hold on;
    plot(linspace(0,gen,gen), DIV);
    ylim([0 1])
    xlabel('Generation');
    ylabel('Probability/Value');
    hold on;
    yyaxis right;
    %disp(best(1:gen).^-1);
    plot(linspace(0,gen,gen), best(1:gen).^-1);
    ylabel("Fitness value");
    hleg = legend('p_c', 'p_m', 'Diversity', 'Fitness best individual');
    set(hleg,'Location','best')
    hold off;
    %}
end
