function UpdateObjectListBox(source)
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

OOPSData = guidata(source);

if OOPSData.nGroups>=1
    CurrentGroup = OOPSData.CurrentGroup;
else
    OOPSData.Handles.ObjectSelector.Items = {};
    OOPSData.Handles.ObjectSelector.Enable = 0;
    return
end

Replicate = CurrentGroup.CurrentImage;

% if the number of currently selected images is 1
if length(Replicate) == 1
    % and at least one object has been detected
    if Replicate.nObjects >= 1
        % enable/update object selection
        OOPSData.Handles.ObjectSelector.Enable = 1;
        OOPSData.Handles.ObjectSelector.Items = Replicate.ObjectNames;
        OOPSData.Handles.ObjectSelector.ItemsData = 1:Replicate.nObjects;
        OOPSData.Handles.ObjectSelector.Value = Replicate.CurrentObjectIdx;
        scroll(OOPSData.Handles.ObjectSelector,OOPSData.Handles.ObjectSelector.Value);
        % % testing below - adding object label color icons to each list item
        % % first remove all styles
        % removeStyle(OOPSData.Handles.ObjectSelector);
        % % preallocate our styles
        % objectIconStyles = matlab.ui.style.Style;
        % objectIconStyles = repmat(objectIconStyles,Replicate.nObjects,1);
        % % get label color icons for each object
        % labelColors = cell(Replicate.nObjects,1);
        % [labelColors{1:end,1}] = deal(Replicate.Object.LabelColorSquare);
        % % deal the icons into our preallocated styles array
        % [objectIconStyles(:).Icon] = deal([labelColors{1:end,1}]);
        % % add the styles to each list item
        % for i = 1:Replicate.nObjects
        %     addStyle(OOPSData.Handles.ObjectSelector,objectIconStyles(i),'item',i);
        % end
        % % end testing
        return
    end
end

% if the above conditions are unmet, clear and disable the listbox
OOPSData.Handles.ObjectSelector.Items = {};
OOPSData.Handles.ObjectSelector.Enable = 0;

end