%Evaluation script for EA on TSP 

%todo: how to turn off scaling?
%todo: which measures are important when we want to compute means over
%multiple subsequent runs?
%todo: when questions are answered, implement structure for multiple runs

NIND=50;		% Number of individuals
MAXGEN=100;		% Maximum no. of generations
PRECI=1;		% Precision of variables
ELITIST=0.05;    % percentage of the elite population
GGAP=1-ELITIST;		% Generation gap
STOP_PERCENTAGE=.95;    % percentage of equal fitness individuals for stopping
PR_CROSS=0.95;     % probability of crossover
PR_MUT=0.05;       % probability of mutation
LOCALLOOP=0;      % local loop removal
CROSSOVER = 'xalt_edges';  %crossover operator
DATASET_PATH = 'datasets/'; %subfolder that contains the datasets
DATASET = 'rondrit070'; %name of dataset
SAVE_PLOTS = 1;
DISPLAY_PLOTS = 1; 
PLOT_PATH = 'plots/'; %subfolder for saving the plots
PLOT_SPECIFICATION = 'test'; %explenation of the plot
PLOT_FILENAME = strcat(PLOT_PATH,DATASET,'_',PLOT_SPECIFICATION);

%add toolbox to path (only relative so it implies the working dir is
%'template'
addpath('../gatbx');

%create folder if non-existing
%mkdir(PLOT_PATH);


NUM_PRS = 10; % Number of parameter values (linearly spaced between 0 and 1 for probabilities) 
PR_CROSSES = linspace(0, 1, NUM_PRS);
PR_MUTS = linspace(0, 1, NUM_PRS);
POP_SIZE = linspace(5, 2500, NUM_PRS);
NUM_RUNS = 10; % Number of times we evaluate each parameter setting 
data_names = {'rondrit016' 'rondrit048' 'rondrit070' 'rondrit100' 'rondrit127'};
data_space = linspace(1, 3, length(data_names));
PERFORMANCE = zeros(length(data_names),NUM_PRS);
CHOSEN_PARAM = 'mutation'; 
KEYSET = {'crossover', 'mutation', 'population'};
VALUES = {PR_CROSSES, PR_MUTS, POP_SIZE};
PARAMETER_MAP = containers.Map(KEYSET, VALUES);
CHOSEN_PARAM_DATA = PARAMETER_MAP(CHOSEN_PARAM);


% Variables to keep track of indices
data_num = 1;
pr_num = 1;

for data_name = data_names
    % load dataset
    data = load(strcat(DATASET_PATH,data_name{1},'.tsp'));
    x=data(:,1)/max([data(:,1);data(:,2)]);
    y=data(:,2)/max([data(:,1);data(:,2)]);
    NVAR=size(data,1);
    % TODO: Change this to a general method which can accept different
    % parameters (mutation, individuals, ..etc) and iterate through them
    for PARAM = CHOSEN_PARAM_DATA
        avg_dist = 0;
        for run = 1:NUM_RUNS
            % We have to do these string checks to get the param in the
            % correct argument for the run_ga function
            if strcmp(CHOSEN_PARAM, 'crossover')
                [path, dist, nr_gens, best_fits, mean_fits, worst_fits] = run_ga2(x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PARAM, PR_MUT, CROSSOVER, LOCALLOOP);
                avg_dist = avg_dist + dist;
            elseif strcmp(CHOSEN_PARAM, 'mutation')
                [path, dist, nr_gens, best_fits, mean_fits, worst_fits] = run_ga2(x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PARAM, CROSSOVER, LOCALLOOP);
                avg_dist = avg_dist + dist;
            elseif strcmp(CHOSEN_PARAM, 'population')
                [path, dist, nr_gens, best_fits, mean_fits, worst_fits] = run_ga2(x, y, PARAM, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, LOCALLOOP);
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

[X,Y] = meshgrid(PR_CROSSES, data_space);
%[X, Y, Z] = meshgrid(data, PR_CROSSES, P);
for i = 1:length(data_names)
    disp(size(PR_CROSSES))
    disp(size(repmat(i, length(data_names), 1)))
    disp(size(PERFORMANCE(i, :)))
    plot3(PR_CROSSES,repmat(i, length(PR_CROSSES), 1),PERFORMANCE(i, :), '-o');
    grid on;
    hold on;
end
hold off;
