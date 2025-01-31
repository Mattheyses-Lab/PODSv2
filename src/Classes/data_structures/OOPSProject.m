classdef OOPSProject < handle
% OOPSPROJECT  Project-level of OOPS data hierarchy
%
%   An instance of this class stores all graphics 
%   handles and data associated with a single run 
%   of the OOPS GUI.
%
%   See also OOPS, OOPSGroup, OOPSImage, OOPSObject, OOPSSettings
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

    % experimental groups class
    properties
        % name of the project
        ProjectName = 'Untitled';
        % array of OOPSGroup objects
        Group OOPSGroup
        % indicates to the currently selected group in the GUI
        CurrentGroupIndex double
        % handles to all gui components
        Handles struct
        % handle to the main OOPSSettings object (shared across multiple objects)
        Settings OOPSSettings
        % whether a valid project has been started/loaded
        GUIProjectStarted (1,1) logical = false
    end

    properties (Dependent = true)
        % number of groups in the project
        nGroups double
        % currently selected group in the GUI
        CurrentGroup OOPSGroup
        % currently selected image(s) in the GUI
        CurrentImage OOPSImage
        % currently selected object in the GUI
        CurrentObject OOPSObject
        % names of each group
        GroupNames (:,1) cell
        % colors of each group
        GroupColors (:,3) double
        % project summary display table for summary panel
        ProjectSummaryDisplayTable
        % total number of images across all groups
        nImages
        % total number of objects across all groups
        nObjects (1,1) uint16
        % array of all objects in the project
        allObjects
        % number of objects currently selected
        nSelected
        % nGroups x nLabels array of the number of objects with each label in this project
        labelCounts
        % status flag indicating whether FFC stacks have been loaded for all groups
        FFCAllLoaded logical
        % status flag indicating whether flat-field correction has been performed for all images
        FFCAllDone logical
        % status flag indicating whether the all images have been segmented
        MaskAllDone logical
        % status flag indicating whether objects have been detected for all images
        ObjectDetectionAllDone logical        
        % status flag indicating whether FPM stats have been computed for all images 
        FPMStatsAllDone logical
        % status flag indicating whether local S/B has been detected for all images
        LocalSBAllDone logical
    end

    methods

        % constructor method
        function obj = OOPSProject(settings)
            if nargin > 0
                obj.Settings = settings;
            else
                obj.Settings = OOPSSettings;
            end
        end

        % destructor method
        function delete(obj)
            obj.deleteGroups()
        end

        % delete all groups in this project
        function deleteGroups(obj)
            % collect and delete the groups in this project
            Groups = obj.Group;
            delete(Groups);
            % clear the placeholders
            clear Groups
            % reinitialize the obj.Group vector
            obj.Group = OOPSGroup.empty();
        end

        % save method, for saving the project to continue later
        function proj = saveobj(obj)

            proj.ProjectName = obj.ProjectName;
            
            % save the settings
            proj.Settings = obj.Settings.saveobj();

            proj.CurrentGroupIndex = obj.CurrentGroupIndex;
            proj.Handles = [];

            if obj.nGroups==0
                proj.Group = [];
            else
                for i = 1:obj.nGroups
                    disp('calling saveobj(Group)')
                    % save each OOPSGroup
                    proj.Group(i,1) = obj.Group(i,1).saveobj();
                end
            end
        end

%% manipulate objects

        % delete all objects with Label:Label
        function DeleteObjectsByLabel(obj,Label)
            for i = 1:obj.nGroups
                obj.Group(i).DeleteObjectsByLabel(Label);
            end
        end

        % find all objects with the Label:OldLabel and replace it with NewLabel
        function SwapObjectLabels(obj,OldLabel,NewLabel)
            % get all of the objects with the old label
            ObjectsWithOldLabel = obj.getObjectsByLabel(OldLabel);
            % add the new label to each of the objects
            [ObjectsWithOldLabel(:).Label] = deal(NewLabel);
        end

        % select all objects with OOPSLabel:Label
        function SelectObjectsByLabel(obj,Label)
            ObjectsToSelect = obj.getObjectsByLabel(Label);
            [ObjectsToSelect.Selected] = deal(true);
        end

        % returns an array of all objects in this project
        function allObjects = get.allObjects(obj)
            % allObjects = [];
            % for i = 1:obj.nGroups
            %     allObjects = [allObjects,obj.Group(i).allObjects];
            % end
            allObjects = cat(1,obj.Group(:).allObjects);
        end

        % select object by property using one or more property filters
        function selectObjectsByProperty(obj,filterSet)
            Objects = obj.allObjects;
            TF = filterSet.checkMatch(Objects);
            [Objects(TF).Selected] = deal(true);
        end

         % apply the specified OOPSLabel to all selected objects in project
        function LabelSelectedObjects(obj,Label)
            for i = 1:obj.nGroups
                obj.Group(i).LabelSelectedObjects(Label);
            end
        end

        % return the active OOPSObject in GUI
        function CurrentObject = get.CurrentObject(obj)
            % get the current image
            cImage = obj.CurrentImage;
            % if the image is not empty
            if ~isempty(cImage)
                CurrentObject = obj.CurrentImage(1).CurrentObject;
            else
                CurrentObject = OOPSObject.empty();
            end
        end

        % return all objects with the specified OOPSLabel
        function Objects = getObjectsByLabel(obj,Label)
            Objects = OOPSObject.empty();
            if obj.nGroups >= 1
                for i = 1:obj.nGroups
                    TotalObjsCounted = numel(Objects);
                    tempObjects = obj.Group(i).getObjectsByLabel(Label);
                    ObjsFound = numel(tempObjects);
                    Objects(TotalObjsCounted+1:TotalObjsCounted+ObjsFound,1) = tempObjects;
                end
            else
                Objects = [];
            end
        end

        % delete all selected objects in this project
        function DeleteSelectedObjects(obj)
            for i = 1:obj.nGroups
                obj.Group(i).DeleteSelectedObjects();
            end
        end

        % clear selection status of all objects in this project
        function ClearSelection(obj)
            for i = 1:obj.nGroups
                obj.Group(i).ClearSelection();
            end
        end

%% retrieve object data

        % total number of objects across all groups
        function nObjects = get.nObjects(obj)
            nObjects = 0;
            for i = 1:obj.nGroups
                nObjects = nObjects + obj.Group(i).TotalObjects;
            end
        end

        % number of objects selected across all groups
        function nSelected = get.nSelected(obj)
            objList = obj.allObjects;
            nSelected = numel(objList([objList.Selected]));
        end

        % return Var2Get data for each object, grouped by object group and label
        function ObjectDataByLabel = GetObjectDataByLabel(obj,Var2Get)
            % get nGroups x nLabels cell array of Var2Get (see GetObjectDataByGroupAndLabel())
            ObjectDataByGroupAndLabel = obj.GetObjectDataByGroupAndLabel(Var2Get);
            % 'flatten' the cell array along first dimension so the data are grouped by label only
            %ObjectDataByLabel = cellfun(@(c) horzcat(c{:}), num2cell(ObjectDataByGroupAndLabel, 1), 'UniformOutput', false);

            ObjectDataByLabel = cellfun(@(c) vertcat(c{:}), num2cell(ObjectDataByGroupAndLabel, 1), 'UniformOutput', false);

            % transpose so that the dimensions of the final cell array are nLabels x 1
            ObjectDataByLabel = ObjectDataByLabel';
        end

        % return Var2Get data for each object, grouped by object group and label
        function ObjectDataByGroupAndLabel = GetObjectDataByGroupAndLabel(obj,Var2Get)
            nLabels = length(obj.Settings.ObjectLabels);

            % cell array to hold all object data for the project, split by group and label
            %   each row is one group, each column is a unique label
            ObjectDataByGroupAndLabel = cell(obj.nGroups,nLabels);

            for i = 1:obj.nGroups
                % cell array of ObjectDataByGroupAndLabel for one group
                % each cell is a vector of values for one label in one group
                ObjectDataByGroupAndLabel(i,:) = obj.Group(i).GetObjectDataByLabel(Var2Get);
            end
        end        

        % return Var2Get data for each object, grouped by object group
        function ObjectDataByGroup = GetObjectDataByGroup(obj,Var2Get)
            % cell array to hold all object data for the project, split by group
            %   each row is one group
            ObjectDataByGroup = cell(obj.nGroups,1);

            for i = 1:obj.nGroups
                ObjectDataByGroup{i,:} = obj.Group(i).GetAllObjectData(Var2Get);
            end
        end

        % get array of object data with one column for each specified variable in the list, vars
        function objectData = getConcatenatedObjectData(obj,vars)
            % vars is a cell array of char vectors, each specifying an object data variable
            % note, we could also retrieve all the objects first then access the data at the object level
            % will test that in the future
            % the number of distinct object variables we are retrieving
            nVariables = numel(vars);
            % cell array to hold the object data for each group
            objectData = cell(obj.nGroups,1);
            % for each group in the project
            for groupIdx = 1:obj.nGroups
                % preallocate array of object data for this group
                objectData{groupIdx} = zeros(obj.Group(groupIdx).TotalObjects,nVariables);
                % for each variable
                for varIdx = 1:numel(vars)
                    % get all object data for this variable in this group
                    objectData{groupIdx}(:,varIdx) = obj.Group(groupIdx).GetAllObjectData(vars{varIdx});
                end
            end
            % finally concatenate the data and return a single array of objects 
            objectData = cell2mat(objectData);
        end

%% manipulate groups

        % add a new group with only group name as input
        function AddNewGroup(obj,GroupName)
            NewColor = obj.getUniqueGroupColor();
            obj.Group(end+1,1) = OOPSGroup(GroupName,obj);
            obj.Group(end).Color = NewColor;
        end

        % find unique group color based on existing group colors
        function NewColor = getUniqueGroupColor(obj)

            groupPalette = obj.Settings.GroupPalette;
            nPaletteColors = size(groupPalette,1);

            if obj.nGroups >= nPaletteColors
                CurrentColors = obj.GroupColors;
                BGColors = [1 1 1;0 0 0];
                NewColor = distinguishable_colors(1,[CurrentColors;BGColors]);
            else
                NewColor = groupPalette(obj.nGroups+1,:);
            end
        end

        function UpdateGroupColors(obj)

            groupPalette = obj.Settings.GroupPalette;
            nPaletteColors = size(groupPalette,1);

            if obj.nGroups > nPaletteColors
                nExtraColors = obj.nGroups-nPaletteColors;
                extraColors = distinguishable_colors(nExtraColors,[groupPalette;1 1 1]);
                NewGroupColors = [groupPalette;extraColors];
            else
                NewGroupColors = groupPalette(1:obj.nGroups,:);
            end

            for groupIdx = 1:obj.nGroups
                obj.Group(groupIdx).Color = NewGroupColors(groupIdx,:);
            end
        end

        % delete the OOPSGroup indicated by input:Group
        function DeleteGroup(obj,Group)
            Group2Delete = Group;
            GroupIdx = Group2Delete.SelfIdx;
            if GroupIdx == 1
                if obj.nGroups > 1
                    obj.Group = obj.Group(2:end);
                else
                    obj.Group = OOPSGroup.empty();
                end
            elseif GroupIdx == obj.nGroups
                obj.Group = obj.Group(1:end-1);
            else
                obj.Group = [obj.Group(1:GroupIdx-1);obj.Group(GroupIdx+1:end)];
            end
            delete(Group2Delete);
            if obj.CurrentGroupIndex>obj.nGroups
                obj.CurrentGroupIndex = obj.nGroups;
            end
        end

%% retrieve group data

        % return list of group names
        function GroupNames = get.GroupNames(obj)
            GroupNames = cell(obj.nGroups,1);
            for i = 1:obj.nGroups
                GroupNames{i} = obj.Group(i).GroupName;
            end
        end

        function GroupColors = get.GroupColors(obj)
            % initialize label colors array
            GroupColors = zeros(obj.nGroups,3);
            % add the colors from each label
            for i = 1:obj.nGroups
                GroupColors(i,:) = obj.Group(i).Color;
            end
        end

        % get the number of groups in this project
        function nGroups = get.nGroups(obj)
            if isvalid(obj.Group)
                nGroups = numel(obj.Group);
            else
                nGroups = 0;
            end
        end

        % return currently selected OOPSGroup in GUI
        function CurrentGroup = get.CurrentGroup(obj)
            try
                CurrentGroup = obj.Group(obj.CurrentGroupIndex);
            catch
                CurrentGroup = OOPSGroup.empty();
            end
        end

        function labelCounts = get.labelCounts(obj)
            % preallocate our array of label counts
            labelCounts = zeros(obj.nGroups,obj.Settings.nLabels);
            % get the counts for each group in the project
            for gIdx = 1:obj.nGroups
                % for each group, get the label counts by summing the label counts for each image
                labelCounts(gIdx,:) = sum(obj.Group(gIdx).labelCounts,1);
            end
        end

%% retrieve image data

        % return the currently selected OOPSImage in GUI
        function CurrentImage = get.CurrentImage(obj)
            % get the currently selected group
            cGroup = obj.CurrentGroup;
            % if the group is not empty
            if ~isempty(cGroup) 
                % get its current image
                CurrentImage = cGroup.CurrentImage; 
            else
                % otherwise, return empty
                CurrentImage = OOPSImage.empty();
            end
        end

        % total number of images in the project
        function nImages = get.nImages(obj)
            nImages = sum([obj.Group(:).nReplicates]);
        end

%% summary tables

        function ProjectSummaryDisplayTable = get.ProjectSummaryDisplayTable(obj)

            varNames = [...
                "Name",...
                "Total groups",...
                "Total images",...
                "Total objects",...
                "Current View",...
                "Previous View",...
                "Mask type",...
                "Mask name",...
                "GUI font size",...
                "FFC files loaded",...
                "FFC performed",...
                "Mask generated",...
                "FPM stats calculated",...
                "Objects detected",...
                "Local S/B calculated"];

            ProjectSummaryDisplayTable = table(...
                {obj.ProjectName},...
                {num2str(obj.nGroups)},...
                {num2str(obj.nImages)},...
                {num2str(obj.nObjects)},...
                {obj.Settings.CurrentTab},...
                {obj.Settings.PreviousTab},...
                {obj.Settings.MaskType},...
                {obj.Settings.MaskName},...
                {num2str(obj.Settings.GUIFontSize)},...
                {Logical2String(obj.FFCAllLoaded)},...
                {Logical2String(obj.FFCAllDone)},...
                {Logical2String(obj.MaskAllDone)},...
                {Logical2String(obj.FPMStatsAllDone)},...
                {Logical2String(obj.ObjectDetectionAllDone)},...
                {Logical2String(obj.LocalSBAllDone)},...
                'VariableNames',varNames,...
                'RowNames',"Project");

            ProjectSummaryDisplayTable = rows2vars(ProjectSummaryDisplayTable,"VariableNamingRule","preserve");

            ProjectSummaryDisplayTable.Properties.RowNames = varNames;
        end

        % return a struct containing the name and object data table of each group
        function stackedData = stackedObjectDataTable(obj)
            % preallocate the stacked data structure
            stackedData = repmat(struct('Group','','Data',[]), 1, obj.nGroups);
            % for each group in the project
            for i = 1:obj.nGroups
                % add the group name
                stackedData(i).Group = obj.Group(i).GroupName;
                % add the table data
                stackedData(i).Data = obj.Group(i).objectDataTableForExport();
            end
        end

%% project status tracking

        function FFCAllLoaded = get.FFCAllLoaded(obj)
            if obj.nGroups == 0
                FFCAllLoaded = false;
                return
            end
            
            for i = 1:obj.nGroups
                if ~obj.Group(i).FFCLoaded
                    FFCAllLoaded = false;
                    return
                end
            end
            FFCAllLoaded = true;
        end

        function FFCAllDone = get.FFCAllDone(obj)
            if obj.nGroups == 0
                FFCAllDone = false;
                return
            end
            
            for i = 1:obj.nGroups
                if ~obj.Group(i).FFCAllDone
                    FFCAllDone = false;
                    return
                end
            end
            FFCAllDone = true;
        end

        function MaskAllDone = get.MaskAllDone(obj)
            if obj.nGroups == 0
                MaskAllDone = false;
                return
            end
            
            for i = 1:obj.nGroups
                if ~obj.Group(i).MaskAllDone
                    MaskAllDone = false;
                    return
                end
            end
            MaskAllDone = true;
        end

        function ObjectDetectionAllDone = get.ObjectDetectionAllDone(obj)
            if obj.nGroups == 0
                ObjectDetectionAllDone = false;
                return
            end
            
            for i = 1:obj.nGroups
                if ~obj.Group(i).ObjectDetectionAllDone
                    ObjectDetectionAllDone = false;
                    return
                end
            end
            ObjectDetectionAllDone = true;
        end

        function LocalSBAllDone = get.LocalSBAllDone(obj)
            if obj.nGroups == 0
                LocalSBAllDone = false;
                return
            end
            
            for i = 1:obj.nGroups
                if ~obj.Group(i).LocalSBAllDone
                    LocalSBAllDone = false;
                    return
                end
            end
            LocalSBAllDone = true;
        end

        function FPMStatsAllDone = get.FPMStatsAllDone(obj)
            if obj.nGroups == 0
                FPMStatsAllDone = false;
                return
            end
            
            for i = 1:obj.nGroups
                if ~obj.Group(i).FPMStatsAllDone
                    FPMStatsAllDone = false;
                    return
                end
            end
            FPMStatsAllDone = true;
        end

    end

    methods (Static)
        function obj = loadobj(proj)

            obj = OOPSProject(OOPSSettings.loadobj(proj.Settings));

            obj.ProjectName = proj.ProjectName;
            %obj.Settings = proj.Settings;
            obj.CurrentGroupIndex = proj.CurrentGroupIndex;
            obj.Handles = proj.Handles;
            % for each group in the saved data structure
            for i = 1:length(proj.Group)
                % testing below - attach handle to project
                proj.Group(i,1).Parent = obj;
                % end testing

                % load the group
                obj.Group(i,1) = OOPSGroup.loadobj(proj.Group(i,1));
                % and set its parent project (this project)
                %obj.Group(i,1).Parent = obj;
                % % testing below
                obj.Group(i,1).updateMaskSchemes();
                % % end testing
            end
        end
    end

end