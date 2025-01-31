classdef OOPSSettings < handle
% OOPSSETTINGS  Settings class for Object-Oriented Polarization Software (OOPS)
%
%   An instance of this class loads, stores, and/or determines various
%   settings for a single run of the OOPS GUI.
%
%   See also OOPS, OOPSProject, OOPSGroup, OOPSImage, OOPSObject
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

    properties

        % zoom settings used by ZoomToCursor
        Zoom = struct('XRange',0,...
            'YRange',0,...
            'ZRange',0,...
            'XDist',0,...
            'YDist',0,...
            'OldXLim',[0 1],...
            'OldYLim',[0 1],...
            'pct',0.5,...
            'ZoomLevels',[1/20 1/15 1/10 1/5 1/3 1/2 1/1.5 1/1.25 1],...
            'ZoomLevelIdx',6,...
            'OldWindowButtonMotionFcn','',...
            'OldImageButtonDownFcn','',...
            'Active',false,...
            'Freeze',false,...
            'Restore',false,...
            'RestoreProps',[],...
            'CurrentButton',[],...
            'StaticAxes',[],...
            'StaticImage',[],...
            'DynamicAxes',[],...
            'DynamicAxesParent',[],...
            'ActiveObjectIdx',NaN);

        % most recently accessed directory
        LastDirectory = pwd;

        % path to directory containing OOPS.m
        MainPath char

        % the type of currently displayed summary table
        SummaryDisplayType = 'Project';
        
        % currently selected 'tab' in the OOPS GUI
        CurrentTab = 'Files';
        % previously selected 'tab' in the OOPS GUI
        PreviousTab = 'Files';
        
        % drawable size of the main display (to set main window Position property)
        ScreenSize

        % themes and colors for GUI display
        GUITheme = 'Dark';
        
        % colormaps settings
        Colormaps struct
        ColormapsSettings struct

        % palettes settings
        Palettes struct
        PalettesSettings struct
        
        % azimuth display settings
        AzimuthDisplaySettings struct
        
        % scatter plot settings
        ScatterPlotSettings struct

        % swarm plot settings
        SwarmPlotSettings struct

        % polar histogram settings
        PolarHistogramSettings struct

        % object intensity profile settings
        ObjectIntensityProfileSettings struct

        % object azimuth display settings
        ObjectAzimuthDisplaySettings struct

        % object selection settings
        ObjectSelectionSettings struct

        % k-means clustering settings
        ClusterSettings struct

        % mask settings
        MaskSettings struct

        % GUI settings
        GUISettings struct

        % variables for object plots (swarm and scatter plots for now)
        ObjectPlotVariables cell

        % variables for object polar plots
        ObjectPolarPlotVariables cell

        % object labeling
        ObjectLabels OOPSLabel
        
        % default font used in most graphics objects (excluding plots)
        DefaultFont (1,:) char
        % default font used in plots
        DefaultPlotFont (1,:) char = 'Arial';
        
        % real world size of each input pixel (default = 1 um/px)
        % PixelSize = 0.1083;
        PixelSize = 1;
        
        % custom mask schemes
        CustomSchemes CustomMask
        SchemeNames cell
        SchemePaths cell

        % user-defined custom output statistics
        CustomStatistics CustomFPMStatistic
        CustomStatisticFileNames cell
        CustomStatisticPaths cell
        CustomStatisticNames cell

    end

    properties (Dependent = true)

        %% azimuth display settings
        AzimuthLineAlpha
        AzimuthLineWidth
        AzimuthLineScale
        AzimuthScaleDownFactor
        AzimuthColorMode
        AzimuthObjectMask

        % scatterplot settings
        ScatterPlotXVariable
        ScatterPlotYVariable
        ScatterPlotGroupingType
        ScatterPlotMarkerMode
        ScatterPlotMarkerSize
        ScatterPlotColorMode
        ScatterPlotMarkerFaceAlpha
        ScatterPlotMarkerEdgeColor
        ScatterPlotMarkerEdgeColorMode
        ScatterPlotMarkerEdgeAlpha
        ScatterPlotBackgroundColor
        ScatterPlotForegroundColor
        ScatterPlotLegendVisible
        ScatterPlotHullVisible
        ScatterPlotHullType
        ScatterPlotHullLineWidth
        ScatterPlotHullFaceColor
        ScatterPlotHullFaceColorMode
        ScatterPlotHullFaceAlpha
        ScatterPlotHullEdgeColor
        ScatterPlotHullEdgeAlpha
        ScatterPlotHullEdgeColorMode

        % swarmplot settings
        SwarmPlotYVariable
        SwarmPlotGroupingType
        SwarmPlotColorMode
        SwarmPlotBackgroundColor
        SwarmPlotForegroundColor
        SwarmPlotErrorBarsColor
        SwarmPlotMarkerFaceAlpha
        SwarmPlotMarkerSize
        SwarmPlotErrorBarsVisible

        % new swarmplot settings in development
        SwarmPlotPointsVisible
        SwarmPlotMarkerEdgeColorMode
        SwarmPlotMarkerEdgeColor
        SwarmPlotXJitterWidth
        SwarmPlotViolinOutlinesVisible
        SwarmPlotViolinEdgeColorMode
        SwarmPlotViolinEdgeColor
        SwarmPlotViolinFaceColorMode
        SwarmPlotViolinFaceColor
        SwarmPlotErrorBarsColorMode
        
        % polar histogram settings
        PolarHistogramnBins
        PolarHistogramWedgeFaceAlpha
        PolarHistogramCircleBackgroundColor
        PolarHistogramWedgeFaceColor
        PolarHistogramWedgeEdgeColorMode
        PolarHistogramWedgeLineWidth
        PolarHistogramWedgeEdgeColor
        PolarHistogramGridlinesColor
        PolarHistogramLabelsColor
        PolarHistogramCircleColor
        PolarHistogramGridlinesLineWidth
        PolarHistogramBackgroundColor
        PolarHistogramVariable

        % ObjectIntensityProfileSettings
        ObjectIntensityProfileFitLineColor
        ObjectIntensityProfilePixelLinesColor
        ObjectIntensityProfileBackgroundColor
        ObjectIntensityProfileForegroundColor
        ObjectIntensityProfileAnnotationsColor
        ObjectIntensityProfileAzimuthLinesColor

        % ObjectAzimuthDisplaySettings
        ObjectAzimuthLineAlpha
        ObjectAzimuthLineWidth
        ObjectAzimuthLineScale
        ObjectAzimuthScaleDownFactor
        ObjectAzimuthColorMode

        % ObjectSelectionSettings
        ObjectSelectionBoxType
        ObjectSelectionColorMode
        ObjectSelectionColor
        ObjectSelectionLineWidth
        ObjectSelectionSelectedLineWidth

        % ClusterSettings
        ClusterVariableList
        ClusternClustersMode
        ClusternClusters
        ClusterCriterion
        ClusterDistanceMetric
        ClusterNormalizationMethod
        ClusterDisplayEvaluation

        % GUISettings
        GUIBackgroundColor
        GUIForegroundColor
        GUIHighlightColor
        GUIFontSize

        % MaskSettings
        MaskType
        MaskName

        % Object variables "long" names
        ObjectPlotVariablesLong
        ObjectPolarPlotVariablesLong

        % for adding/deleting/adjusting labels
        nLabels
        LabelColors
        LabelNames
        DefaultLabel

        % selected colormaps for different image types
        % must be 256x3 double with values in the range [0 1]
        IntensityColormap double
        OrderColormap double
        ReferenceColormap double
        AzimuthColormap double

        % Palettes
        GroupPalette double
        LabelPalette double

        % custom mask schemes
        ActiveCustomScheme

        % custom FPM statistics
        CustomStatisticDisplayNames cell

    end
    
    methods
        
%% constructor

        function obj = OOPSSettings()
            % constructor
            % size of main monitor
            obj.ScreenSize = GetMaximizedScreenSize();
            % % optimum font size
            % obj.FontSize = max(ceil(obj.ScreenSize(4)*.01),11);
            % set up default object label (OOPSLabel object)
            obj.ObjectLabels(1) = OOPSLabel('Default',[1 1 0],obj);
            % get list of supported fonts
            FontList = listfonts();
            % check if 'Consolas' is in list of supported fonts
            if ismember('Consolas',FontList)
                obj.DefaultFont = 'Consolas';   % if so, make it default
            else
                obj.DefaultFont = 'Courier New';  % otherwise, use 'Courier New'
            end

            % get the main path (path to OOPS.m)
            obj.MainPath = obj.getMainPath;

            % load colormaps
            obj.Colormaps = obj.reloadColormaps();

            settingsFiles = {...
                'ObjectPlotVariables.mat',...
                'ColormapsSettings.mat',...
                'Palettes.mat',...
                'PalettesSettings.mat',...
                'ScatterPlotSettings.mat',...
                'SwarmPlotSettings.mat',...
                'AzimuthDisplaySettings.mat',...
                'PolarHistogramSettings.mat',...
                'ObjectPolarPlotVariables.mat',...
                'ObjectIntensityProfileSettings.mat',...
                'ObjectAzimuthDisplaySettings.mat',...
                'ObjectSelectionSettings.mat',...
                'ClusterSettings.mat',...
                'MaskSettings.mat',...
                'GUISettings.mat'};

            obj.updateSettingsFromFiles(settingsFiles);

            try 
                obj.LoadCustomMaskSchemes();
            catch
                warning('Unable to load custom mask schemes...')
            end

            try 
                obj.LoadCustomStatistics();
            catch
                warning('Unable to load custom outputs...')
            end

            % testing below
            obj.UpdateLabelColors();

        end

%% saveobj method

        function settings = saveobj(obj)
            % saves an instance of this class to a .mat file

            settings.SummaryDisplayType = obj.SummaryDisplayType;

            % current and previous tabs selected in GUI
            settings.CurrentTab = obj.CurrentTab;
            settings.PreviousTab = obj.PreviousTab;

            % object labeling
            settings.ObjectLabels = obj.ObjectLabels;
        end

%% load user settings/schemes/custom statistics

        function updateSettingsFromFiles(obj,fileNames)
            % generalized function to update various settings by loading the indicated file(s)
            % fileNames is a cell array of char vectors with names of settings mat files
            for fileIdx = 1:numel(fileNames)
                try
                    % load the mat file indicated by fileNames{fileIdx} as a struct
                    file = load(fileNames{fileIdx});
                    % get the filedName of the loaded struct, not hardcoded in case it changes or we add more settings
                    fieldName = fieldnames(file);
                    % store the settings in the associated class property
                    obj.(fieldName{1}) = file.(fieldName{1});
                catch ME
                    warning(['Error loading file "',fileNames{fileIdx},'": ',ME.getReport]);
                end
            end
        end

        % load custom mask schemes
        function LoadCustomMaskSchemes(obj)
            if ismac || isunix
                SchemeFilesList = dir(fullfile([obj.MainPath,'/assets/segmentation_schemes'],'*.mat'));
            elseif ispc
                SchemeFilesList = dir(fullfile([obj.MainPath,'\assets\segmentation_schemes'],'*.mat'));
            end

            for i = 1:numel(SchemeFilesList)
                SplitName = strsplit(SchemeFilesList(i).name,'.');
                obj.SchemeNames{i} = SplitName{1};
                if ismac || isunix
                    obj.SchemePaths{i} = [SchemeFilesList(i).folder,'/',SchemeFilesList(i).name];
                elseif ispc
                    obj.SchemePaths{i} = [SchemeFilesList(i).folder,'\',SchemeFilesList(i).name];
                end

                % load the scheme into struct, S
                S = load(obj.SchemePaths{i});
                % extract the scheme from the struct into CustomSchemes
                obj.CustomSchemes(i) = S.(obj.SchemeNames{i});
            end
        end

        % load custom statistics
        function LoadCustomStatistics(obj)
            if ismac || isunix
                CustomStatisticFilesList = dir(fullfile([obj.MainPath,'/assets/custom_statistics'],'*.mat'));
            elseif ispc
                CustomStatisticFilesList = dir(fullfile([obj.MainPath,'\assets\custom_statistics'],'*.mat'));
            end

            for i = 1:numel(CustomStatisticFilesList)
                SplitName = strsplit(CustomStatisticFilesList(i).name,'.');
                obj.CustomStatisticFileNames{i} = SplitName{1};
                if ismac || isunix
                    obj.CustomStatisticPaths{i} = [CustomStatisticFilesList(i).folder,'/',CustomStatisticFilesList(i).name];
                elseif ispc
                    obj.CustomStatisticPaths{i} = [CustomStatisticFilesList(i).folder,'\',CustomStatisticFilesList(i).name];
                end

                % load the scheme into struct, S
                S = load(obj.CustomStatisticPaths{i});
                % extract the scheme from the struct into CustomSchemes
                obj.CustomStatistics(i) = S.(obj.CustomStatisticFileNames{i});

                % add a new (dynamic) object variable to the list
                obj.ObjectPlotVariables{end+1} = obj.CustomStatistics(i).StatisticName;
                % add the name of each statistic to CustomStatisticNames
                obj.CustomStatisticNames{end+1} = obj.CustomStatistics(i).StatisticName;
            end
        end

%% custom schemes

        function ActiveCustomScheme = get.ActiveCustomScheme(obj)
            % if MaskType=='CustomScheme', return the active scheme, otherwise return empty scheme
            if strcmp(obj.MaskType,'CustomScheme')
                ActiveCustomScheme = obj.CustomSchemes(ismember(obj.SchemeNames,obj.MaskName));
            else
                ActiveCustomScheme = CustomMask.empty();
            end
        end

%% custom statistics

        function TF = isCustomStatistic(obj,variableToCheck)
            % check whether a given variable is a custom statistic
            TF = ismember(variableToCheck,obj.CustomStatisticNames);
        end

        function CustomStatisticDisplayNames = get.CustomStatisticDisplayNames(obj)
            % preallocate cell array to hold custom statistic display names
            CustomStatisticDisplayNames = cell(size(obj.CustomStatistics));
            % for each custom statistic
            for statIdx = 1:numel(obj.CustomStatistics)
                % add its display name to the cell
                CustomStatisticDisplayNames{statIdx} = obj.CustomStatistics(statIdx).StatisticDisplayName;
            end
        end


%% object label management
    
        function AddNewObjectLabel(obj,labelName,labelColor)
            % add a new OOPSLabel to the project

            % get a unique color for the new label
            if isempty(labelColor)
                labelColor = obj.getUniqueLabelColor;
            end
            % create a default name for the new label if none was given
            if isempty(labelName)
                labelName = obj.getUniqueLabelName;
            end
            % add the OOPSLabel object to ObjectLabels
            obj.ObjectLabels(end+1,1) = OOPSLabel(labelName,labelColor,obj);
            % reorder the object labels so the names/numbers make sense
            obj.reorderObjectLabels;
        end

        function labelName = getUniqueLabelName(obj)
            for i = 2:obj.nLabels+2
                labelName = ['Label ',num2str(i)];
                if ~ismember(labelName,obj.LabelNames)
                    return
                end
            end
        end

        function reorderObjectLabels(obj)
            % prealocate array of idxs for reordering
            labelIdxs = zeros(obj.nLabels,1);
            % true if the default label exists
            %defaultExists = false;

            for i = 1:obj.nLabels
                % find the location of the next auto-named label (if it exists)
                nextIdx = find(ismember(obj.LabelNames,['Label ',num2str(i+1)]));
                % if label found, add its idx to the next position
                if ~isempty(nextIdx)
                    labelIdxs(i) = nextIdx;
                end
            end

            % find location of 'Default' label (if it exists)
            defaultIdx = find(ismember(obj.LabelNames,'Default'));

            % remove any elements == 0
            labelIdxs(labelIdxs==0) = [];

            % add any missing idxs (for user-named labels)
            if numel(labelIdxs) < obj.nLabels
                userIdxs = setdiff((1:obj.nLabels).',[defaultIdx;labelIdxs]);
                sortedIdxs = [defaultIdx;userIdxs;labelIdxs];
            else
                sortedIdxs = [defaultIdx;labelIdxs];
            end

            % reorder the labels
            obj.ObjectLabels = obj.ObjectLabels(sortedIdxs);
        end
   
        function NewColor = getUniqueLabelColor(obj)
            % find unique label color based on existing label colors

            % get the active label palette
            labelPalette = obj.LabelPalette;
            % number of colors in the palette
            nPaletteColors = size(labelPalette,1);
            % if more labels than colors, automatically assign unique color
            if obj.nLabels >= nPaletteColors
                CurrentColors = obj.LabelColors;
                BGColors = [1 1 1;0 0 0];
                NewColor = distinguishable_colors(1,[CurrentColors;BGColors]);
            else
                NewColor = labelPalette(obj.nLabels+1,:);
            end
        end

        function UpdateLabelColors(obj)

            labelPalette = obj.LabelPalette;
            nPaletteColors = size(labelPalette,1);

            if obj.nLabels > nPaletteColors
                nExtraColors = obj.nLabels-nPaletteColors;
                extraColors = distinguishable_colors(nExtraColors,[labelPalette;1 1 1]);
                NewLabelColors = [labelPalette;extraColors];
            else
                NewLabelColors = labelPalette(1:obj.nLabels,:);
            end

            for labelIdx = 1:obj.nLabels
                obj.ObjectLabels(labelIdx).Color = NewLabelColors(labelIdx,:);
            end
        end

        function DeleteObjectLabel(obj,label2Delete)

            if obj.nLabels > 1
                obj.ObjectLabels = obj.ObjectLabels(setdiff((1:obj.nLabels).',label2Delete.SelfIdx));
            else
                obj.ObjectLabels = OOPSLabel.empty();
            end

            delete(label2Delete);

        end

        function restoreDefaultLabel(obj)
        % restore the label 'Default'

            % if 'Default' label does not exist
            if ~ismember('Default',obj.LabelNames)
                % create it
                obj.AddNewObjectLabel('Default',[]);
                % then update the label colors
                obj.UpdateLabelColors();
            end

        end

%% object plot variables

        function ObjectPlotVariablesLong = get.ObjectPlotVariablesLong(obj)
            ObjectPlotVariablesLong = cell(size(obj.ObjectPlotVariables));
            for varIdx = 1:numel(obj.ObjectPlotVariables)
                ObjectPlotVariablesLong{varIdx} = obj.expandVariableName(obj.ObjectPlotVariables{varIdx});
            end
        end

        function ObjectPolarPlotVariablesLong = get.ObjectPolarPlotVariablesLong(obj)
            ObjectPolarPlotVariablesLong = cell(size(obj.ObjectPolarPlotVariables));
            for varIdx = 1:numel(obj.ObjectPolarPlotVariables)
                ObjectPolarPlotVariablesLong{varIdx} = obj.expandVariableName(obj.ObjectPolarPlotVariables{varIdx});
            end
        end

%% colormap settings

        function IntensityColormap = get.IntensityColormap(obj)
            IntensityColormap = obj.ColormapsSettings.Intensity.Map;
        end

        function OrderColormap = get.OrderColormap(obj)
            OrderColormap = obj.ColormapsSettings.Order.Map;
        end

        function ReferenceColormap = get.ReferenceColormap(obj)
            ReferenceColormap = obj.ColormapsSettings.Reference.Map;
        end

        function AzimuthColormap = get.AzimuthColormap(obj)
            AzimuthColormap = obj.ColormapsSettings.Azimuth.Map;
        end

%% palette settings

        function GroupPalette = get.GroupPalette(obj)
            GroupPalette = obj.PalettesSettings.Group.Colors;
        end

        function LabelPalette = get.LabelPalette(obj)
            LabelPalette = obj.PalettesSettings.Label.Colors;
        end

%% azimuth display settings

        function AzimuthLineAlpha = get.AzimuthLineAlpha(obj)
            AzimuthLineAlpha = obj.AzimuthDisplaySettings.LineAlpha;
        end

        function AzimuthLineWidth = get.AzimuthLineWidth(obj)
            AzimuthLineWidth = obj.AzimuthDisplaySettings.LineWidth;
        end

        function AzimuthLineScale = get.AzimuthLineScale(obj)
            AzimuthLineScale = obj.AzimuthDisplaySettings.LineScale;
        end

        function AzimuthScaleDownFactor = get.AzimuthScaleDownFactor(obj)
            AzimuthScaleDownFactor = obj.AzimuthDisplaySettings.ScaleDownFactor;
        end

        function AzimuthColorMode = get.AzimuthColorMode(obj)
            AzimuthColorMode = obj.AzimuthDisplaySettings.ColorMode;
        end

        function AzimuthObjectMask = get.AzimuthObjectMask(obj)
            AzimuthObjectMask = obj.AzimuthDisplaySettings.ObjectMask;
        end

%% scatter plot settings        

        function ScatterPlotXVariable = get.ScatterPlotXVariable(obj)
            ScatterPlotXVariable = obj.ScatterPlotSettings.XVariable;
        end

        function ScatterPlotYVariable = get.ScatterPlotYVariable(obj)
            ScatterPlotYVariable = obj.ScatterPlotSettings.YVariable;
        end

        function ScatterPlotGroupingType = get.ScatterPlotGroupingType(obj)
            ScatterPlotGroupingType = obj.ScatterPlotSettings.GroupingType;
        end

        function ScatterPlotMarkerMode = get.ScatterPlotMarkerMode(obj)
            ScatterPlotMarkerMode = obj.ScatterPlotSettings.MarkerMode;
        end

        function ScatterPlotMarkerSize = get.ScatterPlotMarkerSize(obj)
            ScatterPlotMarkerSize = obj.ScatterPlotSettings.MarkerSize;
        end

        function ScatterPlotColorMode = get.ScatterPlotColorMode(obj)
            ScatterPlotColorMode = obj.ScatterPlotSettings.ColorMode;
        end

        function ScatterPlotMarkerFaceAlpha = get.ScatterPlotMarkerFaceAlpha(obj)
            ScatterPlotMarkerFaceAlpha = obj.ScatterPlotSettings.MarkerFaceAlpha;
        end

        function ScatterPlotBackgroundColor = get.ScatterPlotBackgroundColor(obj)
            ScatterPlotBackgroundColor = obj.ScatterPlotSettings.BackgroundColor;
        end

        function ScatterPlotForegroundColor = get.ScatterPlotForegroundColor(obj)
            ScatterPlotForegroundColor = obj.ScatterPlotSettings.ForegroundColor;
        end

        function ScatterPlotLegendVisible = get.ScatterPlotLegendVisible(obj)
            ScatterPlotLegendVisible = obj.ScatterPlotSettings.LegendVisible;
        end

        function ScatterPlotHullLineWidth = get.ScatterPlotHullLineWidth(obj)
            ScatterPlotHullLineWidth = obj.ScatterPlotSettings.HullLineWidth;
        end

        function ScatterPlotHullFaceColor = get.ScatterPlotHullFaceColor(obj)
            ScatterPlotHullFaceColor = obj.ScatterPlotSettings.HullFaceColor;
        end

        function ScatterPlotHullFaceAlpha = get.ScatterPlotHullFaceAlpha(obj)
            ScatterPlotHullFaceAlpha = obj.ScatterPlotSettings.HullFaceAlpha;
        end

        function ScatterPlotMarkerEdgeColorMode = get.ScatterPlotMarkerEdgeColorMode(obj)
            ScatterPlotMarkerEdgeColorMode = obj.ScatterPlotSettings.MarkerEdgeColorMode;
        end

        function ScatterPlotHullFaceColorMode = get.ScatterPlotHullFaceColorMode(obj)
            ScatterPlotHullFaceColorMode = obj.ScatterPlotSettings.HullFaceColorMode;
        end

        function ScatterPlotHullEdgeColorMode = get.ScatterPlotHullEdgeColorMode(obj)
            ScatterPlotHullEdgeColorMode = obj.ScatterPlotSettings.HullEdgeColorMode;
        end

        function ScatterPlotHullEdgeColor = get.ScatterPlotHullEdgeColor(obj)
            ScatterPlotHullEdgeColor = obj.ScatterPlotSettings.HullEdgeColor;
        end

        function ScatterPlotMarkerEdgeAlpha = get.ScatterPlotMarkerEdgeAlpha(obj)
            ScatterPlotMarkerEdgeAlpha = obj.ScatterPlotSettings.MarkerEdgeAlpha;
        end

        function ScatterPlotMarkerEdgeColor = get.ScatterPlotMarkerEdgeColor(obj)
            ScatterPlotMarkerEdgeColor = obj.ScatterPlotSettings.MarkerEdgeColor;
        end

        function ScatterPlotHullVisible = get.ScatterPlotHullVisible(obj)
            ScatterPlotHullVisible = obj.ScatterPlotSettings.HullVisible;
        end

        function ScatterPlotHullEdgeAlpha = get.ScatterPlotHullEdgeAlpha(obj)
            ScatterPlotHullEdgeAlpha = obj.ScatterPlotSettings.HullEdgeAlpha;
        end

        function ScatterPlotHullType = get.ScatterPlotHullType(obj)
            ScatterPlotHullType = obj.ScatterPlotSettings.HullType;
        end

%% swarm plot settings

        function SwarmPlotYVariable = get.SwarmPlotYVariable(obj)
            SwarmPlotYVariable = obj.SwarmPlotSettings.YVariable;
        end

        function SwarmPlotColorMode = get.SwarmPlotColorMode(obj)
            SwarmPlotColorMode = obj.SwarmPlotSettings.ColorMode;
        end

        function SwarmPlotGroupingType = get.SwarmPlotGroupingType(obj)
            SwarmPlotGroupingType = obj.SwarmPlotSettings.GroupingType;
        end

        function SwarmPlotBackgroundColor = get.SwarmPlotBackgroundColor(obj)
            SwarmPlotBackgroundColor = obj.SwarmPlotSettings.BackgroundColor;
        end

        function SwarmPlotForegroundColor = get.SwarmPlotForegroundColor(obj)
            SwarmPlotForegroundColor = obj.SwarmPlotSettings.ForegroundColor;
        end

        function SwarmPlotErrorBarsColor = get.SwarmPlotErrorBarsColor(obj)
            SwarmPlotErrorBarsColor = obj.SwarmPlotSettings.ErrorBarsColor;
        end

        function SwarmPlotMarkerFaceAlpha = get.SwarmPlotMarkerFaceAlpha(obj)
            SwarmPlotMarkerFaceAlpha = obj.SwarmPlotSettings.MarkerFaceAlpha;
        end

        function SwarmPlotMarkerSize = get.SwarmPlotMarkerSize(obj)
            SwarmPlotMarkerSize = obj.SwarmPlotSettings.MarkerSize;
        end

        function SwarmPlotErrorBarsVisible = get.SwarmPlotErrorBarsVisible(obj)
            SwarmPlotErrorBarsVisible = obj.SwarmPlotSettings.ErrorBarsVisible;
        end

        function SwarmPlotPointsVisible = get.SwarmPlotPointsVisible(obj)
            SwarmPlotPointsVisible = obj.SwarmPlotSettings.PointsVisible;
        end

        function SwarmPlotMarkerEdgeColorMode = get.SwarmPlotMarkerEdgeColorMode(obj)
            SwarmPlotMarkerEdgeColorMode = obj.SwarmPlotSettings.MarkerEdgeColorMode;
        end

        function SwarmPlotMarkerEdgeColor = get.SwarmPlotMarkerEdgeColor(obj)
            SwarmPlotMarkerEdgeColor = obj.SwarmPlotSettings.MarkerEdgeColor;
        end

        function SwarmPlotXJitterWidth = get.SwarmPlotXJitterWidth(obj)
            SwarmPlotXJitterWidth = obj.SwarmPlotSettings.XJitterWidth;
        end        

        function SwarmPlotViolinOutlinesVisible = get.SwarmPlotViolinOutlinesVisible(obj)
            SwarmPlotViolinOutlinesVisible = obj.SwarmPlotSettings.ViolinOutlinesVisible;
        end

        function SwarmPlotViolinEdgeColorMode = get.SwarmPlotViolinEdgeColorMode(obj)
            SwarmPlotViolinEdgeColorMode = obj.SwarmPlotSettings.ViolinEdgeColorMode;
        end

        function SwarmPlotViolinEdgeColor = get.SwarmPlotViolinEdgeColor(obj)
            SwarmPlotViolinEdgeColor = obj.SwarmPlotSettings.ViolinEdgeColor;
        end

        function SwarmPlotViolinFaceColorMode = get.SwarmPlotViolinFaceColorMode(obj)
            SwarmPlotViolinFaceColorMode = obj.SwarmPlotSettings.ViolinFaceColorMode;
        end

        function SwarmPlotViolinFaceColor = get.SwarmPlotViolinFaceColor(obj)
            SwarmPlotViolinFaceColor = obj.SwarmPlotSettings.ViolinFaceColor;
        end

        function SwarmPlotErrorBarsColorMode = get.SwarmPlotErrorBarsColorMode(obj)
            SwarmPlotErrorBarsColorMode = obj.SwarmPlotSettings.ErrorBarsColorMode;
        end

%% polar histogram settings        

        function PolarHistogramnBins = get.PolarHistogramnBins(obj)
            PolarHistogramnBins = obj.PolarHistogramSettings.nBins;
        end

        function PolarHistogramWedgeFaceAlpha = get.PolarHistogramWedgeFaceAlpha(obj)
            PolarHistogramWedgeFaceAlpha = obj.PolarHistogramSettings.WedgeFaceAlpha;
        end

        function PolarHistogramCircleBackgroundColor = get.PolarHistogramCircleBackgroundColor(obj)
            PolarHistogramCircleBackgroundColor = obj.PolarHistogramSettings.CircleBackgroundColor;
        end

        function PolarHistogramWedgeFaceColor = get.PolarHistogramWedgeFaceColor(obj)
            PolarHistogramWedgeFaceColor = obj.PolarHistogramSettings.WedgeFaceColor;
        end

        function PolarHistogramWedgeEdgeColorMode = get.PolarHistogramWedgeEdgeColorMode(obj)
            PolarHistogramWedgeEdgeColorMode = obj.PolarHistogramSettings.WedgeEdgeColorMode;
        end

        function PolarHistogramWedgeLineWidth = get.PolarHistogramWedgeLineWidth(obj)
            PolarHistogramWedgeLineWidth = obj.PolarHistogramSettings.WedgeLineWidth;
        end

        function PolarHistogramWedgeEdgeColor = get.PolarHistogramWedgeEdgeColor(obj)
            PolarHistogramWedgeEdgeColor = obj.PolarHistogramSettings.WedgeEdgeColor;
        end

        function PolarHistogramGridlinesColor = get.PolarHistogramGridlinesColor(obj)
            PolarHistogramGridlinesColor = obj.PolarHistogramSettings.GridlinesColor;
        end

        function PolarHistogramLabelsColor = get.PolarHistogramLabelsColor(obj)
            PolarHistogramLabelsColor = obj.PolarHistogramSettings.LabelsColor;
        end

        function PolarHistogramCircleColor = get.PolarHistogramCircleColor(obj)
            PolarHistogramCircleColor = obj.PolarHistogramSettings.CircleColor;
        end

        function PolarHistogramGridlinesLineWidth = get.PolarHistogramGridlinesLineWidth(obj)
            PolarHistogramGridlinesLineWidth = obj.PolarHistogramSettings.GridlinesLineWidth;
        end

        function PolarHistogramBackgroundColor = get.PolarHistogramBackgroundColor(obj)
            PolarHistogramBackgroundColor = obj.PolarHistogramSettings.BackgroundColor;
        end

        function PolarHistogramVariable = get.PolarHistogramVariable(obj)
            PolarHistogramVariable = obj.PolarHistogramSettings.Variable;
        end

%% object intensity profile settings

        function ObjectIntensityProfileFitLineColor = get.ObjectIntensityProfileFitLineColor(obj)
            ObjectIntensityProfileFitLineColor = obj.ObjectIntensityProfileSettings.FitLineColor;
        end

        function ObjectIntensityProfilePixelLinesColor = get.ObjectIntensityProfilePixelLinesColor(obj)
            ObjectIntensityProfilePixelLinesColor = obj.ObjectIntensityProfileSettings.PixelLinesColor;
        end

        function ObjectIntensityProfileBackgroundColor = get.ObjectIntensityProfileBackgroundColor(obj)
            ObjectIntensityProfileBackgroundColor = obj.ObjectIntensityProfileSettings.BackgroundColor;
        end

        function ObjectIntensityProfileForegroundColor = get.ObjectIntensityProfileForegroundColor(obj)
            ObjectIntensityProfileForegroundColor = obj.ObjectIntensityProfileSettings.ForegroundColor;
        end

        function ObjectIntensityProfileAnnotationsColor = get.ObjectIntensityProfileAnnotationsColor(obj)
            ObjectIntensityProfileAnnotationsColor = obj.ObjectIntensityProfileSettings.AnnotationsColor;
        end

        function ObjectIntensityProfileAzimuthLinesColor = get.ObjectIntensityProfileAzimuthLinesColor(obj)
            ObjectIntensityProfileAzimuthLinesColor = obj.ObjectIntensityProfileSettings.AzimuthLinesColor;
        end

%% object azimuth display settings

        function ObjectAzimuthLineAlpha = get.ObjectAzimuthLineAlpha(obj)
            ObjectAzimuthLineAlpha = obj.ObjectAzimuthDisplaySettings.LineAlpha;
        end

        function ObjectAzimuthLineWidth = get.ObjectAzimuthLineWidth(obj)
            ObjectAzimuthLineWidth = obj.ObjectAzimuthDisplaySettings.LineWidth;
        end

        function ObjectAzimuthLineScale = get.ObjectAzimuthLineScale(obj)
            ObjectAzimuthLineScale = obj.ObjectAzimuthDisplaySettings.LineScale;
        end

        function ObjectAzimuthScaleDownFactor = get.ObjectAzimuthScaleDownFactor(obj)
            ObjectAzimuthScaleDownFactor = obj.ObjectAzimuthDisplaySettings.ScaleDownFactor;
        end

        function ObjectAzimuthColorMode = get.ObjectAzimuthColorMode(obj)
            ObjectAzimuthColorMode = obj.ObjectAzimuthDisplaySettings.ColorMode;
        end

%% object selection settings

        function ObjectSelectionBoxType = get.ObjectSelectionBoxType(obj)
            ObjectSelectionBoxType = obj.ObjectSelectionSettings.BoxType;
        end
        
        function ObjectSelectionColorMode = get.ObjectSelectionColorMode(obj)
            ObjectSelectionColorMode = obj.ObjectSelectionSettings.ColorMode;
        end
        
        function ObjectSelectionColor = get.ObjectSelectionColor(obj)
            ObjectSelectionColor = obj.ObjectSelectionSettings.Color;
        end
        
        function ObjectSelectionLineWidth = get.ObjectSelectionLineWidth(obj)
            ObjectSelectionLineWidth = obj.ObjectSelectionSettings.LineWidth;
        end
        
        function ObjectSelectionSelectedLineWidth = get.ObjectSelectionSelectedLineWidth(obj)
            ObjectSelectionSelectedLineWidth = obj.ObjectSelectionSettings.SelectedLineWidth;
        end

%% object labels settings

        function nLabels = get.nLabels(obj)
            % find number of unique object labels
            nLabels = numel(obj.ObjectLabels);
        end

        function LabelColors = get.LabelColors(obj)
            % initialize label colors array
            LabelColors = zeros(obj.nLabels,3);
            % add the colors from each label
            for i = 1:obj.nLabels
                LabelColors(i,:) = obj.ObjectLabels(i).Color;
            end
        end

        function LabelNames = get.LabelNames(obj)
            LabelNames = arrayfun(@(lbl) lbl.Name,obj.ObjectLabels,'UniformOutput',false);
        end

        function DefaultLabel = get.DefaultLabel(obj)
            % return the default label
            DefaultLabel = obj.ObjectLabels(find(ismember(obj.LabelNames,'Default')));
        end



%% k-means clustering settings

        function ClusterVariableList = get.ClusterVariableList(obj)
            ClusterVariableList = obj.ClusterSettings.VariableList;
        end

        function ClusternClustersMode = get.ClusternClustersMode(obj)
            ClusternClustersMode = obj.ClusterSettings.nClustersMode;
        end

        function ClusternClusters = get.ClusternClusters(obj)
            ClusternClusters = obj.ClusterSettings.nClusters;
        end

        function ClusterCriterion = get.ClusterCriterion(obj)
            ClusterCriterion = obj.ClusterSettings.Criterion;
        end

        function ClusterDistanceMetric = get.ClusterDistanceMetric(obj)
            ClusterDistanceMetric = obj.ClusterSettings.DistanceMetric;
        end

        function ClusterNormalizationMethod = get.ClusterNormalizationMethod(obj)
            ClusterNormalizationMethod = obj.ClusterSettings.NormalizationMethod;
        end

        function ClusterDisplayEvaluation = get.ClusterDisplayEvaluation(obj)
            ClusterDisplayEvaluation = obj.ClusterSettings.DisplayEvaluation;
        end

%% Mask settings

        function MaskType = get.MaskType(obj)
            MaskType = obj.MaskSettings.MaskType;
        end

        function MaskName = get.MaskName(obj)
            MaskName = obj.MaskSettings.MaskName;
        end

%% GUI settings

        function GUIBackgroundColor = get.GUIBackgroundColor(obj)
            GUIBackgroundColor = obj.GUISettings.BackgroundColor;
        end

        function GUIForegroundColor = get.GUIForegroundColor(obj)
            GUIForegroundColor = obj.GUISettings.ForegroundColor;
        end

        function GUIHighlightColor = get.GUIHighlightColor(obj)
            GUIHighlightColor = obj.GUISettings.HighlightColor;
        end

        function GUIFontSize = get.GUIFontSize(obj)
            GUIFontSize = obj.GUISettings.FontSize;
        end

%% variable names settings

        function NameOut = expandVariableName(obj,NameIn)
            switch NameIn
                case 'OrderAvg'
                    NameOut = 'Mean Order';
                case 'OrderStd'
                    NameOut = 'Order Standard Deviation';
                case 'SBRatio'
                    NameOut = 'Local S/B';
                case 'Area'
                    NameOut = 'Area';
                case 'Perimeter'
                    NameOut = 'Perimeter';
                case 'Circularity'
                    NameOut = 'Circularity';
                case 'SignalAverage'
                    NameOut = 'Mean Raw Intensity';
                case 'MaxFeretDiameter'
                    NameOut = 'Maximum Feret Diameter';
                case 'MinFeretDiameter'
                    NameOut = 'Minimum Feret Diameter';
                case 'MajorAxisLength'
                    NameOut = 'Major Axis Length';
                case 'MinorAxisLength'
                    NameOut = 'Minor Axis Length';
                case 'Eccentricity'
                    NameOut = 'Eccentricity';
                case 'BGAverage'
                    NameOut = 'Mean BG Intensity';
                case 'AzimuthAverage'
                    NameOut = 'Mean Azimuth';
                case 'AzimuthStd'
                    NameOut = 'Azimuth Circular Standard Deviation';
                case 'Orientation'
                    NameOut = 'Orientation';
                case 'EquivDiameter'
                    NameOut = 'Equivalent Diameter';
                case 'ConvexArea'
                    NameOut = 'Convex Area';
                case 'MidlineRelativeAzimuth'
                    NameOut = 'Mean Azimuth (Midline)';
                case 'NormalRelativeAzimuth'
                    NameOut = 'Mean Azimuth (Midline Normal)';
                case 'MidlineLength'
                    NameOut = 'Midline Length';
                case 'AzimuthAngularDeviation'
                    NameOut = 'Azimuth Angular Deviation';
                case 'CurvatureAverage'
                    NameOut = 'Mean Curvature';
                otherwise
                    % check if the input is a custom statistic
                    if obj.isCustomStatistic(NameIn)
                        % if so, find the matching CustomFPMStatistic object
                        thisStatistic = obj.CustomStatistics(ismember(NameIn,obj.CustomStatisticNames));
                        % then get the corresponding display name
                        NameOut = thisStatistic.StatisticDisplayName;
                    else
                        % otherwise just return the input
                        NameOut = NameIn;
                    end
            end
        end

    end

    methods (Static)

        function obj = loadobj(settings)
            % load and construct an instance of this class from a .mat file

            % create the default settings object, to which we will add our saved settings
            obj = OOPSSettings();

            obj.SummaryDisplayType = settings.SummaryDisplayType;

            % monitor tab switching
            obj.CurrentTab = settings.CurrentTab;
            obj.PreviousTab = settings.PreviousTab;

            % object labeling
            obj.ObjectLabels = settings.ObjectLabels;

            % make sure to add this settings object to each of the labels
            for LabelIdx = 1:numel(obj.ObjectLabels)
                obj.ObjectLabels(LabelIdx).Settings = obj;
            end

        end


        function colormapsStruct = reloadColormaps()

            colormapsStruct = struct();

            mainPath = OOPSSettings.getMainPath();
            % get correct path separator based on OS
            if ismac || isunix
                pathSep = '/';
            elseif ispc
                pathSep = '\';
            end
            % build path to folder holding the different colormaps
            colormapsPath = strjoin({mainPath,'assets','colormaps'},pathSep);
            % get cell array of colormaps folders (categories)
            colormapTypes = getFolderNames(colormapsPath);
            % loop through each category
            for typeIdx = 1:numel(colormapTypes)
                % the current category
                thisType = colormapTypes{typeIdx};
                % path to the category folder
                thisTypePath = strjoin({colormapsPath,thisType},pathSep);
                % info for all .mat files in the folder
                thisTypeItems = dir([thisTypePath,pathSep,'*.mat']);
                % cell array of colormap filenames
                colormapFileNames = {thisTypeItems.name};
                % loop through each colormap file
                for cmapIdx = 1:numel(colormapFileNames)
                    % the filename without path
                    cmapFileName = colormapFileNames{cmapIdx};
                    % split on the delimeter, '.'
                    cmapFileNameSplit = split(cmapFileName,'.');
                    % get short name with no extension
                    cmapName = cmapFileNameSplit{1};
                    % load the map
                    cmapFile = load([thisTypePath,pathSep,cmapName],cmapName);
                    % construct a customColormap object and add it to the struct
                    colormapsStruct.(cmapName) = customColormap(...
                        "Map",cmapFile.(cmapName),...
                        "Name",cmapName,...
                        "Source",thisType);
                end
            end
        end

        function mainPath = getMainPath()

            if ismac || isunix
                % get the path to this .m file (two levels below the directory we want)
                CurrentPathSplit = strsplit(mfilename("fullpath"),'/');
                % get the "MainPath" (path to OOPS.m)
                mainPath = strjoin(CurrentPathSplit(1:end-4),'/');
            elseif ispc
                CurrentPathSplit = strsplit(mfilename("fullpath"),'\');
                mainPath = strjoin(CurrentPathSplit(1:end-4),'\');
            end

        end

    end
end

