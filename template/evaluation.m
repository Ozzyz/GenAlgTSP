%Evaluation script for EA on TSP 

%add other performance measures from the book (chapter 9)
%todo: how to turn off scaling? (for comparison with benchmark problems)

%add toolbox to path (only relative so it implies the working dir is
%'template'
addpath('../gatbx');
%create folder if non-existing
%mkdir(PLOT_PATH);

%default values (will normally not be used)
NIND=50;		        % Number of individuals
PR_CROSS=0.95;          % probability of crossover
PR_MUT=0.05;            % probability of mutation

%file configurations
DATASET_PATH = 'datasets/';   %subfolder that contains the datasets
PLOT_PATH = 'plots/';         %subfolder for saving the plots
PLOT_SPECIFICATION = 'test1';  %explenation of the plot
PLOT_NAME_PREFIX = strcat(PLOT_PATH,PLOT_SPECIFICATION);

%general configurations
CROSSOVER = 'xalt_edges';       %crossover operator
PARENT_SELECTION = 'sus';       %parent selection operator
MUTATION = 'inversion';%'scramble';%'insertion';         %mutation operator
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
    
%PRIMARY parameter tuning (the parameter we want to iterate through)
CHOSEN_PARAM = 'population size'; 
NUM_PRS = 15;                    % Number of parameter values (linearly spaced between min and max)  if 1 -> max
NUM_RUNS = 5;                   % Number of times we evaluate each parameter setting 
data_names = {'rondrit048', 'rondrit100', 'xqf131' };
PRIM_MIN_POP_SIZE = 5;
PRIM_MAX_POP_SIZE = 1000;
PRIM_MIN_MUT_RATE = 0.00;
PRIM_MAX_MUT_RATE = 1.00;
PRIM_MIN_CROSS_RATE=0.00;
PRIM_MAX_CROSS_RATE=1.00;

%SECONDARY parameter tuning (the parameters that are only changed sparsely)
NUM_SECONDARY_PRS = 1;  % Number of parameter values for each parameter
MIN_POP_SIZE = 10;
MAX_POP_SIZE = 1000;
MIN_MUT_RATE = 0.05;
MAX_MUT_RATE = 0.95;
MIN_CROSS_RATE=0.05;
MAX_CROSS_RATE=0.95;

%---------------------------------------------------------------------------------------------

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

%create one figure that will be continously updated
fig_3d = figure;

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
            x=data(:,1)/max([data(:,1);data(:,2)]);
            y=data(:,2)/max([data(:,1);data(:,2)]);
             %x=data(:,1);
             %y=data(:,2);
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
                disp(strcat(CHOSEN_PARAM,'=',num2str(PARAM),', ',PARAM_2,'=',num2str(PARAM_2_VALUE),', ',PARAM_3,'=',num2str(PARAM_3_VALUE)));
                avg_dist = 0;
                for run = 1:NUM_RUNS
                    % We have to do these string checks to get the param in the
                    % correct argument for the run_ga function
                    if strcmp(CHOSEN_PARAM, 'crossover rate')
                        [path, dist, nr_gens, best_fits, mean_fits, worst_fits] = run_ga2(x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PARAM, PR_MUT, CROSSOVER, LOCALLOOP,PARENT_SELECTION,MUTATION, Dist, MU_LAMBDA);
                        avg_dist = avg_dist + dist;
                    elseif strcmp(CHOSEN_PARAM, 'mutation rate')
                        [path, dist, nr_gens, best_fits, mean_fits, worst_fits] = run_ga2(x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PARAM, CROSSOVER, LOCALLOOP,PARENT_SELECTION,MUTATION, Dist, MU_LAMBDA);
                        avg_dist = avg_dist + dist;
                    elseif strcmp(CHOSEN_PARAM, 'population size')
                        [path, dist, nr_gens, best_fits, mean_fits, worst_fits] = run_ga2(x, y, PARAM, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, LOCALLOOP,PARENT_SELECTION,MUTATION,Dist, MU_LAMBDA);
                        avg_dist = avg_dist + dist;
                    else
                        msg = 'Must specify either crossover, mutation or population as chosen parameter!';
                        error(msg)
                    end 
                end
                PERFORMANCE(data_num, pr_num) = avg_dist / NUM_RUNS;
                pr_num = pr_num + 1;
            end
            pr_num = 1;
            data_num = data_num + 1;
        end

        %plotting
        clf;
        figure(fig_3d);
        %set(fig_3d, 'Visible', 'off');
        for i = 1:length(data_names)
            plot3(PR_CROSSES,repmat(i, length(PR_CROSSES), 1),PERFORMANCE(i, :), '-o','DisplayName',data_names{i});
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
        view(3);
        PLOT_FILENAME = char(strcat(PLOT_NAME_PREFIX,'_',MUTATION,'_',CROSSOVER,'_',PARENT_SELECTION,'_loop=',num2str(LOCALLOOP),'_elit=',num2str(ELITIST),'_var_',strrep(CHOSEN_PARAM,' ','_'),'_',num2str(NUM_PRS),'_',strrep(PARAM_2,' ','_'),'=',num2str(PARAM_2_PRINT_VAL),'_',strrep(PARAM_3,' ','_'),'=',num2str(PARAM_3_PRINT_VAL)));
        saveas(fig_3d,char(strcat(PLOT_FILENAME,'_','3d')), 'png');
        %figure(fig_3d);
        az=0; el = 0; view(az, el);
        text = char(strcat(PLOT_FILENAME,'_','2d'));
        saveas(fig_3d, text, 'png');
        display('image saved');
    end
end


