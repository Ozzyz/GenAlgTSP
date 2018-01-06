function plotTour(X,Y, Path, TotalDist,filename, spec_name)
%   plotTSP saves a plot for a tour on a TSP
%   
%   X,Y: coordinates of the cities in the TSP
%   Path: the resulting path from the EA
%   TotalDist: restulting total distance
%   filename: filename for the plots

  path_fig = figure;
  set(path_fig,'Visible', 'off');
  
  %plot the map with the path
  figure(path_fig);
  plot(X(Path),Y(Path), 'ko-','MarkerFaceColor','Black');
  hold on;
  plot([X(Path(length(Path))) X(Path(1))],[Y(Path(length(Path))) Y(Path(1))], 'ko-','MarkerFaceColor','Black');
  title(strcat('Path Map -> Total Distance: ',num2str(TotalDist),' ',spec_name));
  xlabel('x');
  ylabel('y');
  hold off;
  saveas(path_fig,strcat(filename,'_','path','.png'));

end
