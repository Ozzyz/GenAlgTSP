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
PR_CROSS=.95;     % probability of crossover
PR_MUT=.05;       % probability of mutation
LOCALLOOP=0;      % local loop removal
CROSSOVER = 'xalt_edges';  %crossover operator
DATASET_PATH = 'datasets/'; %subfolder that contains the datasets
DATASET = 'rondrit016'; %name of dataset
SAVE_PLOTS = 1;
DISPLAY_PLOTS = 1; 
PLOT_PATH = 'plots/'; %subfolder for saving the plots
PLOT_SPECIFICATION = 'test'; %explenation of the plot
PLOT_FILENAME = strcat(PLOT_PATH,DATASET,'_',PLOT_SPECIFICATION);

%add toolbox to path (only relative so it implies the working dir is
%'template'
addpath('../gatbx');

%create folder if non-existing
mkdir(PLOT_PATH);

% load dataset
data = load(strcat(DATASET_PATH,DATASET,'.tsp'));
x=data(:,1)/max([data(:,1);data(:,2)]);
y=data(:,2)/max([data(:,1);data(:,2)]);
NVAR=size(data,1);

[path, dist, nr_gens, best_fits, mean_fits, worst_fits] = run_ga2(x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, LOCALLOOP);

plotSingleTSP(x,y,path, dist, nr_gens, best_fits, mean_fits, worst_fits,SAVE_PLOTS,DISPLAY_PLOTS,PLOT_FILENAME);
