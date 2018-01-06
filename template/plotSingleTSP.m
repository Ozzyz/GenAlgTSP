function plotSingleTSP(X,Y, Path, TotalDist, gen, best_fits, mean_fits, worst_fits,save_plot,display_plot,filename,spec_name)
%   plotTSP plots results of one single EA run for TSP
%   at the moment only two plots, further plots will be added
%   
%   X,Y: coordinates of the cities in the TSP
%   Path: the resulting path from the EA
%   TotalDist: restulting total distance
%   gen: number of generations used
%   best_fits: best fitness value for each generation
%   mean_fits: mean fitness value for each generation
%   worst_fits: worst fitness value for each generation
%   save_plot, display_plot:
%   filename: filename for the plots

  path_fig = figure;
  %evol_fig = figure;
  %hist_fig = figure;
  if display_plot == 0
      set(path_fig,'Visible', 'off');
      set(evol_fig,'Visible', 'off');
      set(hist_fig,'Visible', 'off');
  end
  
  %plot the map with the path
  figure(path_fig);
  plot(X(Path),Y(Path), 'ko-','MarkerFaceColor','Black');
  hold on;
  plot([X(Path(length(Path))) X(Path(1))],[Y(Path(length(Path))) Y(Path(1))], 'ko-','MarkerFaceColor','Black');
  title(strcat('Path Map -> Total Distance: ',num2str(TotalDist),' ',spec_name));
  xlabel('x');
  ylabel('y');
  
%   %plot the evolution of the fitness values over the generations
%   figure(evol_fig);
%   plot([0:gen],best_fits(1:gen+1),'r-','DisplayName','best');
%   hold on
%   plot([0:gen],mean_fits(1:gen+1),'b-','DisplayName','mean');
%   hold on
%   plot([0:gen],worst_fits(1:gen+1),'g-','DisplayName','worst');
%   xlabel('Generation');
%   ylabel('Distance');
%   legend('show');
%   
  %plot histogram of distances
  %figure(hist_fig);
  %todo
  
  if save_plot == 1
      saveas(path_fig,strcat(filename,'_','path','.png'));
      saveas(evol_fig,strcat(filename,'_','evolution','.png'));
      %saveas(hist_fig,strcat(filename,'_','hist','.png'));
  end
end
