function [colormapsStruct,colorPalettesStruct] = ColorBrewerHelper()
%%  ColorBrewerHelper returns a struct containing MATLAB format colormaps from 
%   Cynthia Brewer's sequential and divergent ColorBrewer color schemes
%
%   also returns a struct containing a list of colors from the qualitative
%   ColorBrewer color schemes
%
%----------------------------------------------------------------------------------------------------------------------------
%
%   Object-Oriented Polarization Software (OOPS)
%   Copyright (C) 2023  William Dean
% 
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see https://www.gnu.org/licenses/.
%
%----------------------------------------------------------------------------------------------------------------------------

colormapsStruct = struct();

colorPalettesStruct = struct();

sequantialColormaps = {...
    'Blues'; ...
    'BuGn'; ...
    'BuPu'; ...
    'GnBu'; ...
    'Greens'; ...
    'Greys'; ...
    'Oranges'; ...
    'OrRd'; ...
    'PuBu'; ...
    'PuBuGn'; ...
    'PuRd'; ...
    'Purples'; ...
    'RdPu'; ...
    'Reds'; ...
    'YlGn'; ...
    'YlGnBu'; ...
    'YlOrBr'; ...
    'YlOrRd'};

for i = 1:numel(sequantialColormaps)
    colormapsStruct.(sequantialColormaps{i}) = brewermap(256,sequantialColormaps{i});
end

% divergent colormaps
divergentColormaps = {...
    'BrBG'; ...     
    'PiYG'; ...     
    'PRGn'; ...     
    'PuOr'; ...     
    'RdBu'; ...     
    'RdGy'; ...     
    'RdYlBu'; ...   
    'RdYlGn'; ... 	
    'Spectral'};

for i = 1:numel(divergentColormaps)
    colormapsStruct.(divergentColormaps{i}) = brewermap(256,divergentColormaps{i});
end
    
% qualitative colormaps
qualitativeColormaps = {...
    'Accent'; ...   
    'Dark2'; ...    
    'Paired'; ...   
    'Pastel1'; ...  
    'Pastel2'; ...  
    'Set1'; ...     
    'Set2'; ...     
    'Set3'};

nNodes = [8,8,12,9,8,9,8,12];

for i = 1:numel(qualitativeColormaps)
    colorPalettesStruct.(qualitativeColormaps{i}) = brewermap(nNodes(i),qualitativeColormaps{i});
end

end