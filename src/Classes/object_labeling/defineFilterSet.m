function filterSetOut = defineFilterSet(vars,varsLong)
% opens a figure for the user to define a set of property filters (see propertyFilterSet.m)
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

latexStyle = uistyle("Interpreter","latex");

filterSetOut = [];

%% set up main figure and its grids

    fH_defineFilterSet = uifigure("WindowStyle","alwaysontop",...
        "Name","Define property filters",...
        "Units","pixels",...
        "Position",[100 100 500 300],...
        "Visible","off",...
        "CloseRequestFcn",@CloseAndCancel,...
        "Color",[0 0 0]);

    mainGrid = uigridlayout(fH_defineFilterSet,[2,1],...
        "Padding",[5 5 5 5],...
        "RowHeight",{'1x',20},...
        "ColumnWidth",{'1x'},...
        "RowSpacing",5,...
        "BackgroundColor",[0 0 0]);

    filterModulePanel = uipanel(mainGrid,...
        "Title","Filters",...
        "BackgroundColor",[0 0 0],...
        "BorderColor",[1 1 1],...
        "HighlightColor",[1 1 1],...
        "ForegroundColor",[1 1 1]);

    filterModuleGrid = uigridlayout(filterModulePanel,[1,5],...
        "Padding",[5 5 5 5],...
        "RowSpacing",5,...
        "Scrollable","on",...
        "RowHeight",{20},...
        "ColumnWidth",{'1x',60,'0.5x',20,20},...
        "BackgroundColor",[0 0 0]);

    exitOptionsGrid = uigridlayout(mainGrid,[1,2],...
        "Padding",[0 0 0 0],...
        "RowHeight",{20},...
        "ColumnWidth",{'1x','1x'},...
        "BackgroundColor",[0 0 0]);

    nFilters = 1;

%% set up first filter module

    propDropdown(1) = uidropdown(filterModuleGrid,...
        "Items",varsLong,...
        "ItemsData",vars);

    propRelationshipDropdown(1) = uidropdown(filterModuleGrid,...
        "Items",{'$$>$$','$$>=$$','$$=$$','$$<=$$','$$<$$'},...
        "ItemsData",{'>','>=','==','<=','<'});
    addStyle(propRelationshipDropdown(1),latexStyle);

    propValueEditfield(1) = uieditfield(filterModuleGrid,"numeric");

    addFilterButton = uibutton(filterModuleGrid,...
        "Text","",...
        "Icon","PlusSymbolIcon.png",...
        "IconAlignment","center",...
        "ButtonPushedFcn",@addFilterModule);

    deleteFilterButton = uibutton(filterModuleGrid,...
        "Text","",...
        "Icon","MinusSymbolIcon.png",...
        "IconAlignment","center",...
        "ButtonPushedFcn",@deleteFilterModule,...
        "Enable","off");

%% set up exit buttons

    cancelButton = uibutton(exitOptionsGrid,...
        "Text","Cancel",...
        "ButtonPushedFcn",@CloseAndCancel);
    cancelButton.Layout.Row = 1;
    cancelButton.Layout.Column = 1;

    continueButton = uibutton(exitOptionsGrid,...
        "Text","Continue",...
        "ButtonPushedFcn",@CloseAndContinue);
    continueButton.Layout.Row = 1;
    continueButton.Layout.Column = 2;

%% move window to center and make it visible

    movegui(fH_defineFilterSet,'center')
    fH_defineFilterSet.Visible = 'On';

    % wait until the window is closed to return
    waitfor(fH_defineFilterSet);

%% nested callbacks

    function addFilterModule(~,~)
        % increment filter counter
        nFilters = nFilters + 1;
        % add a row to the filter module grid
        filterModuleGrid.RowHeight = num2cell(repmat(20,1,nFilters));
        % components for the new filter module
        propDropdown(nFilters) = uidropdown(filterModuleGrid,...
        "Items",varsLong,...
        "ItemsData",vars);
        propRelationshipDropdown(nFilters) = uidropdown(filterModuleGrid,...
            "Items",{'$$>$$','$$>=$$','$$=$$','$$<=$$','$$<$$'},...
            "ItemsData",{'>','>=','==','<=','<'});
        addStyle(propRelationshipDropdown(nFilters),latexStyle);
        propValueEditfield(nFilters) = uieditfield(filterModuleGrid,"numeric");
        % move plus and minus buttons to the last row
        addFilterButton.Layout.Row = nFilters;
        deleteFilterButton.Layout.Row = nFilters;
        % enable/disable the deleteFilterButton based on nFilters
        deleteFilterButton.Enable = nFilters > 1;
    end

    function deleteFilterModule(~,~)
        % delete components for the filter module in the last row
        delete(propDropdown(nFilters));
        delete(propRelationshipDropdown(nFilters));
        delete(propValueEditfield(nFilters));
        % decrement filter counter
        nFilters = nFilters - 1;
        % move plus and minus buttons to the last row
        addFilterButton.Layout.Row = nFilters;
        deleteFilterButton.Layout.Row = nFilters;
        % remove the last row from the filter module grid
        filterModuleGrid.RowHeight = num2cell(repmat(20,1,nFilters));
        % enable/disable the deleteFilterButton based on nFilters
        deleteFilterButton.Enable = nFilters > 1;
    end

    function CloseAndCancel(~,~)
        filterSetOut = [];
        delete(fH_defineFilterSet);
    end

    function CloseAndContinue(~,~)
        % create an empty property filter set
        filterSetOut = propertyFilterSet();
        % add a new filter for each filter module row defined by the user
        for i = 1:nFilters
            propRealName = propDropdown(i).Value;
            propFullName = varsLong(ismember(vars,propRealName));
            propFullName = propFullName{1};
            propRelationship = propRelationshipDropdown(i).Value;
            propValue = propValueEditfield(i).Value;

            filterSetOut.addFilter(...
                propFullName,...
                propRealName,...
                propRelationship,...
                propValue...
                );
        end
        % delete the figure window
        delete(fH_defineFilterSet);
    end

end