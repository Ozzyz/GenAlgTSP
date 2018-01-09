%Evaluation script for EA on TSP 
%Use: this script can be used for benchmarking or for evaluating different parameters

%add toolbox to path (only relative so it implies the working dir is
%'template'
addpath('../gatbx');

%default values (will normally not be used)
NIND=50;		        % Number of individuals
PR_CROSS=0.95;          % probability of crossover
PR_MUT=0.05;            % probability of mutation

%file configurations
DATASET_PATH = 'datasets/';   %subfolder that contains the datasets
PLOT_PATH = 'plots/';         %subfolder for saving the plots
PLOT_SPECIFICATION = 'test';  %explenation of the plot
PLOT_NAME_PREFIX = strcat(PLOT_PATH,PLOT_SPECIFICATION);

%create folder if non-existing
%mkdir(PLOT_PATH);

%general configurations

%data_names = {'rondrit048' ,'xqf131'};
data_names = {'xqf131'};
%data_names = {'xqf131' 'bcl380'};
%data_names = {'xqf131' 'bcl380' 'xql662'};
LOCAL_SEARCH = 1;
SCALING = 1;                    %scaling for better plots (enabled by default, is overwritten for benchmarking)
CROSSOVER = 'xalt_edges';       %crossover operator
PARENT_SELECTION = 'tournament';       %parent selection operator
MUTATION = 'inversion';%'insertion';%'scramble';%'insertion'; %'inversion';         %mutation operator
MAXGEN=2000;		                % Maximum no. of generations
ELITIST=0.05;                   % percentage of the elite population
STOP_PERCENTAGE=.95;            % percentage of equal fitness individuals for stopping
PRECI=1;                        % Precision of variables
GGAP=1-ELITIST;		            % Generation gap
LOCALLOOP=0;                    % local loop removal
MU_LAMBDA = 0;                  % Whether or not to use (mu, lambda) as survivor selection
% Can't have both survivor algorithms as the time
if MU_LAMBDA && ELITIST
    error('Can not have both Elitism and (mu,lambda)-survivor algorithm');
end


MODE = 'benchmarking';
%benchmarking... mutation rate, crossover rate and population size are fixed and the performance is plotted for different benchmark problems
%parameter tuning... the parameters are changed and the different results are used to create a plot to see the development of fitness for the changes

if strcmp(MODE, 'benchmarking')
%Benchmarking configuration:
%---------------------------------------------------------------------------------------------------------------
    PLOT_NAME_PREFIX = strcat(PLOT_NAME_PREFIX, 'benchmark');
    
    SCALING = 0;            %enable or disable scaling, scaling can be used to compare different distances easier
    PLOT_TOURS= 1;          %enable or disable plotting of the resulting tour for every run
    BENCH_POP_SIZE= 200;    %used population size
    BENCH_MUT_RATE=0.2;     %used mutation rate
    BENCH_CROSS_RATE=0.5;   %used crossover rate
    NUM_RUNS = 5;           %number of runs that are averaged for every problem

    %do NOT change this!
    CHOSEN_PARAM = 'population size'; 
    NUM_PRS = 1;
    PRIM_MIN_POP_SIZE = 0;
    PRIM_MAX_POP_SIZE = BENCH_POP_SIZE;
    PRIM_MIN_MUT_RATE = 0;
    PRIM_MAX_MUT_RATE = 0;
    PRIM_MIN_CROSS_RATE=0;
    PRIM_MAX_CROSS_RATE=0;
    NUM_SECONDARY_PRS = 1;  
    MIN_POP_SIZE = 0;
    MAX_POP_SIZE = 0;
    MIN_MUT_RATE = 0;
    MAX_MUT_RATE = BENCH_MUT_RATE;
    MIN_CROSS_RATE=0;
    MAX_CROSS_RATE=BENCH_CROSS_RATE;

    PLOT_FILENAME = char(strcat(PLOT_NAME_PREFIX,'_',MUTATION,'_',CROSSOVER,'_',PARENT_SELECTION,'_loop=',num2str(LOCALLOOP),'_elit=',num2str(ELITIST),'pop=', num2str(BENCH_POP_SIZE), '_', 'mut=', num2str(BENCH_MUT_RATE*100),'cross=', num2str(BENCH_CROSS_RATE*100)));

elseif strcmp(MODE, 'parameter tuning')
%Parameter tuning configuration:
%---------------------------------------------------------------------------------------------------------------
    PLOT_NAME_PREFIX = strcat(PLOT_SPECIFICATION, 'tuning');
    PLOT_TOURS= 0;

    %PRIMARY parameter tuning (the parameter we want to iterate through)
    CHOSEN_PARAM = 'crossover rate'; 
    NUM_PRS = 8;                    % Number of parameter values (linearly spaced between min and max)  if 1 -> max
    NUM_RUNS = 5;                   % Number of times we evaluate each parameter setting 
    PRIM_MIN_POP_SIZE = 50;
    PRIM_MAX_POP_SIZE = 400;
    PRIM_MIN_MUT_RATE = 0.05;
    PRIM_MAX_MUT_RATE = 0.95;
    PRIM_MIN_CROSS_RATE=0.05;
    PRIM_MAX_CROSS_RATE=0.95;

    %SECONDARY parameter tuning (the parameters that are only changed sparsely)
    NUM_SECONDARY_PRS = 1;  % Number of parameter values for each parameter
    MIN_POP_SIZE = 10;
    MAX_POP_SIZE = 200;
    MIN_MUT_RATE = 0.05;
    MAX_MUT_RATE = 0.25;
    MIN_CROSS_RATE=0.05;
    MAX_CROSS_RATE=0.25;

end
%---------------------------------------------------------------------------------------------------------------

%create the vectors for iteration
PR_CROSSES = linspace(PRIM_MIN_CROSS_RATE, PRIM_MAX_CROSS_RATE, NUM_PRS);
PR_MUTS = linspace(PRIM_MIN_MUT_RATE, PRIM_MAX_MUT_RATE, NUM_PRS);
POP_SIZE = round(linspace(PRIM_MIN_POP_SIZE, PRIM_MAX_POP_SIZE, NUM_PRS));
PERFORMANCE = zeros(length(data_names),NUM_PRS);
KEYSET = {'crossover rate', 'mutation rate', 'population size'};
VALUES = {PR_CROSSES, PR_MUTS, POP_SIZE};
PARAMETER_MAP = containers.Map(KEYSET, VALUES);
CHOSEN_PARAM_DATA = PARAMETER_MAP(CHOSEN_PARAM);

if strcmp(CHOSEN_PARAM, 'crossover rate')
    PARAM_2 = 'mutation rate';
    PARAM_2_DATA = linspace(MIN_MUT_RATE, MAX_MUT_RATE, NUM_SECONDARY_PRS);
    PARAM_3 = 'population size';
    PARAM_3_DATA = round(linspace(MIN_POP_SIZE, MAX_POP_SIZE, NUM_SECONDARY_PRS));
elseif strcmp(CHOSEN_PARAM, 'mutation rate')
    PARAM_2 = 'crossover rate';
    PARAM_2_DATA = linspace(MIN_CROSS_RATE, MAX_CROSS_RATE, NUM_SECONDARY_PRS);
    PARAM_3 = 'population size';
    PARAM_3_DATA = round(linspace(MIN_POP_SIZE, MAX_POP_SIZE, NUM_SECONDARY_PRS));
elseif strcmp(CHOSEN_PARAM, 'population size')
    PARAM_2 = 'crossover rate';
    PARAM_2_DATA = linspace(MIN_CROSS_RATE, MAX_CROSS_RATE, NUM_SECONDARY_PRS);
    PARAM_3 = 'mutation rate';
    PARAM_3_DATA = linspace(MIN_MUT_RATE, MAX_MUT_RATE, NUM_SECONDARY_PRS);
else
    msg = 'Must specify either crossover, mutation or population as chosen parameter!';
    error(msg)
end 


%---------------------------------------------------------------------------------------------

%iterate through the secondary parameters
for PARAM_2_VALUE=PARAM_2_DATA
    if strcmp(PARAM_2, 'crossover rate')
        PR_CROSS = PARAM_2_VALUE;
    elseif strcmp(PARAM_2, 'mutation rate')
        PR_MUT = PARAM_2_VALUE;
    elseif strcmp(PARAM_2, 'population size')
        NIND = PARAM_2_VALUE;
    end

    for PARAM_3_VALUE=PARAM_3_DATA
        %create one figure that will be continously updated
        
        if strcmp(PARAM_3, 'crossover rate')
            PR_CROSS = PARAM_3_VALUE;
        elseif strcmp(PARAM_3, 'mutation rate')
            PR_MUT = PARAM_3_VALUE;
        elseif strcmp(PARAM_3, 'population size')
            NIND = PARAM_3_VALUE;
        end

        % Variables to keep track of indices
        data_num = 1;
        pr_num = 1;

        %iterate through primary parameter
        for data_name = data_names
            % load dataset
            data = load(strcat(DATASET_PATH,data_name{1},'.tsp'));

            if SCALING
              x=data(:,1)/max([data(:,1);data(:,2)]);
              y=data(:,2)/max([data(:,1);data(:,2)]);
            else
              x=data(:,1);
              y=data(:,2);
            end

            NVAR=size(data,1);
            Dist=zeros(NVAR,NVAR);
            for i=1:size(x,1)
                for j=1:size(y,1)
                    Dist(i,j)=sqrt((x(i)-x(j))^2+(y(i)-y(j))^2);
                end
            end
            % TODO: Change this to a general method which can accept different
            % parameters (mutation, individuals, ..etc) and iterate through them
            for PARAM = CHOSEN_PARAM_DATA
                disp(strcat(CHOSEN_PARAM,'=',num2str(PARAM),', ',PARAM_2,'=',num2str(PARAM_2_VALUE),', ',PARAM_3,'=',num2str(PARAM_3_VALUE),',  ',data_name{1}));
                avg_dist = 0;
                for run = 1:NUM_RUNS
                    % We have to do these string checks to get the param in the
                    % correct argument for the run_ga function
                    tic;
                    if strcmp(CHOSEN_PARAM, 'crossover rate')
                        [path, dist, nr_gens, best_fits, mean_fits, worst_fits] = run_ga2(x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PARAM, PR_MUT, CROSSOVER, LOCALLOOP,PARENT_SELECTION,MUTATION, Dist, MU_LAMBDA);
                        toc;
                    elseif strcmp(CHOSEN_PARAM, 'mutation rate')
                        [path, dist, nr_gens, best_fits, mean_fits, worst_fits] = run_ga2(x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PARAM, CROSSOVER, LOCALLOOP,PARENT_SELECTION,MUTATION, Dist, MU_LAMBDA);
                        toc;
                    elseif strcmp(CHOSEN_PARAM, 'population size')
                        [path, dist, nr_gens, best_fits, mean_fits, worst_fits] = run_ga2(x, y, PARAM, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, LOCALLOOP,PARENT_SELECTION,MUTATION,Dist, MU_LAMBDA);
                        toc;
                    else
                        msg = 'Must specify either crossover, mutation or population as chosen parameter!';
                        error(msg)
                    end 
                    %avg_dist = avg_dist + dist;
                    
                    if LOCAL_SEARCH
                        %tic;
                        path = localsearch2(path,0,Dist);
                        disp('doing local search');
                        %toc;
                        dist = tspfun(path2adj(path),Dist);
                    end
                    
                    avg_dist = avg_dist + dist;

                    if PLOT_TOURS 
                        tour_plot_name = char(strcat(PLOT_FILENAME,'tour_',data_name,'_',num2str(run)));
                        plotTour(x,y, path, dist,tour_plot_name, '');
                    end
                end
                DISTANCE(data_num, pr_num) = avg_dist / NUM_RUNS;
                PERFORMANCE(data_num, pr_num) = 1.0 / DISTANCE(data_num, pr_num);
                pr_num = pr_num + 1;
            end
            pr_num = 1;
            data_num = data_num + 1;
        end

        %plotting
        plot_fig = figure;
        clf;
        figure(plot_fig);
        
        if strcmp(MODE, 'benchmarking')
            x = 1 : length(data_names);
            barColorMap = lines(length(data_names));
            for b = 1 : length(data_names)
                handleBarSeries(b) = bar(x(b), PERFORMANCE(b), 'BarWidth', 0.9);
                set(handleBarSeries(b), 'FaceColor', barColorMap(b,:));
                legends(b) = strcat(data_names(b),' (avg.dist.=',num2str(round(DISTANCE(b),2)),')');
                hold on;
            end
            hold off;
            
            xlabel('problem');
            ylabel('performance');
            legend(legends, 'Location','southeast');
            set(gca, 'XTickMode', 'auto');
            
            saveas(plot_fig, char(PLOT_FILENAME), 'png');
            save(char(strcat(PLOT_FILENAME,'_','data.mat')),'MODE','BENCH_POP_SIZE', 'BENCH_MUT_RATE','BENCH_CROSS_RATE','PARENT_SELECTION', 'MUTATION', 'CROSSOVER','data_names', 'STOP_PERCENTAGE','LOCALLOOP','MU_LAMBDA', 'PERFORMANCE');

        elseif strcmp(MODE, 'parameter tuning')
            %set(plot_fig, 'Visible', 'off');
            for i = 1:length(data_names)
                if strcmp(CHOSEN_PARAM, 'population size')
                    plot3(POP_SIZE,repmat(i, length(POP_SIZE), 1),PERFORMANCE(i, :), '-o','DisplayName',data_names{i});
                elseif strcmp(CHOSEN_PARAM, 'mutation rate')
                    plot3(PR_MUTS,repmat(i, length(PR_MUTS), 1),PERFORMANCE(i, :), '-o','DisplayName',data_names{i});
                elseif strcmp(CHOSEN_PARAM, 'crossover rate')
                    plot3(PR_CROSSES,repmat(i, length(PR_CROSSES), 1),PERFORMANCE(i, :), '-o','DisplayName',data_names{i});
                end
                grid on;
                hold on;
            end
            hold off;
            xlabel(CHOSEN_PARAM);
            ylabel('problem');
            zlabel('performance');

            PARAM_3_PRINT_VAL = PARAM_3_VALUE;
            if strcmp(CHOSEN_PARAM, 'crossover rate')
                PARAM_2_PRINT_VAL = PARAM_2_VALUE *100;
                title_end = strcat('mut.rate =', num2str(PR_MUT),', pop.size=',num2str(NIND));
            elseif strcmp(CHOSEN_PARAM, 'mutation rate')
                PARAM_2_PRINT_VAL = PARAM_2_VALUE *100;
                title_end = strcat('cross.rate =', num2str(PR_CROSS),', pop.size=',num2str(NIND));
            elseif strcmp(CHOSEN_PARAM, 'population size')
                PARAM_2_PRINT_VAL = PARAM_2_VALUE *100;
                PARAM_3_PRINT_VAL = PARAM_3_VALUE *100;
                title_end = strcat('mut.rate =', num2str(PR_MUT),', cross.rate=',num2str(PR_CROSS));
            else
                msg = 'Must specify either crossover, mutation or population as chosen parameter!';
                error(msg)
            end 
            title(strcat('',title_end));
            legend('show');
            %view(3);
            %PLOT_FILENAME = char(strcat(PLOT_NAME_PREFIX,'_',MUTATION,'_',CROSSOVER,'_',PARENT_SELECTION,'_loop=',num2str(LOCALLOOP),'_elit=',num2str(ELITIST),'_var_',strrep(CHOSEN_PARAM,' ','_'),'_',num2str(NUM_PRS),'_',strrep(PARAM_2,' ','_'),'=',num2str(PARAM_2_PRINT_VAL),'_',strrep(PARAM_3,' ','_'),'=',num2str(PARAM_3_PRINT_VAL)));
            %saveas(plot_fig,char(strcat(PLOT_FILENAME,'_','3d')), 'png');
            %figure(plot_fig);
            az=0; el = 0; view(az, el);
            saveas(plot_fig, char(strcat(PLOT_FILENAME,'_','2d')), 'png');
            save(char(strcat(PLOT_FILENAME,'_','data.mat')),'MODE','CHOSEN_PARAM', 'CHOSEN_PARAM_DATA','PARENT_SELECTION', 'MUTATION', 'CROSSOVER','PARAM_2','PARAM_2_DATA','PARAM_3', 'PARAM_3_DATA','data_names', 'STOP_PERCENTAGE','LOCALLOOP','MU_LAMBDA', 'PERFORMANCE');
        end
        display('image and data saved');
    end
end


