classdef ViolinPlot < handle

    properties(Dependent = true, AbortSet = true)
        % data
        XData (1,:) double
        YData (1,:) double

        % marker appearance (color, transparency, jitter, size, etc.)
        PointsVisible (1,1) matlab.lang.OnOffSwitchState        
        XJitterWidth (1,1) double {mustBeInRange(XJitterWidth,0,1,"exclude-lower")}
        XJitter (1,:) char {mustBeMember(XJitter,{'density','none'})}
        MarkerEdgeColor
        MarkerSize
        MarkerFaceColorMode
        MarkerFaceAlpha (1,1) double {mustBeInRange(MarkerFaceAlpha,0,1)}
        CData

        % marker datatip info
        DataTipCell (1,2) cell

        % violin outline properties
        ViolinOutlinesVisible (1,1) matlab.lang.OnOffSwitchState
        ViolinLineWidth (1,1) double
        ViolinFaceColor (1,3) double
        ViolinEdgeColor (1,3) double
        ViolinFaceAlpha (1,1) double {mustBeInRange(ViolinFaceAlpha,0,1)}

        % error bars properties
        ErrorBarsVisible (1,1) matlab.lang.OnOffSwitchState
        ErrorBarsLineWidth (1,1) double
        ErrorBarsColor (1,3) double
    end

    properties(Access = private,Dependent = true)
        DensityData (2,:) double
    end

    properties(Access = private,Transient,NonCopyable)
        violinOutlines (1,1) matlab.graphics.primitive.Patch
        violinPoints (1,1) matlab.graphics.chart.primitive.Scatter
        errorBars (1,1) matlab.graphics.primitive.Patch
    end

    methods

        function obj = ViolinPlot(Parent,NameValuePairs)

            % input argument validation
            arguments
                Parent (1,1) matlab.ui.control.UIAxes
                NameValuePairs.XData (1,:) double = NaN
                NameValuePairs.YData (1,:) double = NaN
                NameValuePairs.XJitter (1,:) char {mustBeMember(NameValuePairs.XJitter,{'none','density'})} = 'density'
                NameValuePairs.XJitterWidth (1,1) double {mustBeInRange(NameValuePairs.XJitterWidth,0,1,"exclude-lower")} = 0.9
                NameValuePairs.DataTipCell (1,2) cell = {{},{}};

                NameValuePairs.MarkerEdgeColor = [0 0 0]
                NameValuePairs.MarkerSize = 50
                NameValuePairs.MarkerFaceColorMode = 'flat'
                NameValuePairs.CData = [0 0 0]
                NameValuePairs.PointsVisible (1,1) matlab.lang.OnOffSwitchState = "on"
                NameValuePairs.MarkerFaceAlpha (1,1) double {mustBeInRange(NameValuePairs.MarkerFaceAlpha,0,1)} = 0.5

                NameValuePairs.ViolinOutlinesVisible (1,1) matlab.lang.OnOffSwitchState = "on"
                NameValuePairs.ViolinLineWidth (1,1) double = 1
                NameValuePairs.ViolinFaceColor (1,3) double = [1 1 1]
                NameValuePairs.ViolinEdgeColor (1,3) double = [0 0 0]
                NameValuePairs.ViolinFaceAlpha (1,1) double {mustBeInRange(NameValuePairs.ViolinFaceAlpha,0,1)} = 0.5

                NameValuePairs.ErrorBarsVisible (1,1) matlab.lang.OnOffSwitchState = "on"
                NameValuePairs.ErrorBarsLineWidth (1,1) double = 1
                NameValuePairs.ErrorBarsColor (1,3) double = [0 0 0]
            end

            % primitive patch to form the violin outlines
            obj.violinOutlines  = patch(Parent,...
                'XData',NaN,...
                'YData',NaN,...
                'HitTest','off',...
                'PickableParts','none');
            obj.ViolinOutlinesVisible = NameValuePairs.ViolinOutlinesVisible;
            obj.ViolinLineWidth = NameValuePairs.ViolinLineWidth;
            obj.ViolinFaceColor = NameValuePairs.ViolinFaceColor;
            obj.ViolinEdgeColor = NameValuePairs.ViolinEdgeColor;
            obj.ViolinFaceAlpha = NameValuePairs.ViolinFaceAlpha;

            % primitive scatter to form the violin points
            obj.violinPoints = scatter(Parent,NaN,NaN);
            obj.PointsVisible = NameValuePairs.PointsVisible;
            obj.XData = NameValuePairs.XData;
            obj.YData = NameValuePairs.YData;
            obj.XJitter = NameValuePairs.XJitter;
            obj.XJitterWidth = NameValuePairs.XJitterWidth;

            obj.MarkerEdgeColor = NameValuePairs.MarkerEdgeColor;
            obj.MarkerSize = NameValuePairs.MarkerSize;
            obj.MarkerFaceColorMode = NameValuePairs.MarkerFaceColorMode;
            obj.CData = NameValuePairs.CData;
            obj.MarkerFaceAlpha = NameValuePairs.MarkerFaceAlpha;

            obj.DataTipCell = NameValuePairs.DataTipCell;

            % primitive line to form the error bars
            % obj.errorBars = line(Parent,'XData',NaN,'YData',NaN);
            obj.errorBars  = patch(Parent,...
                'XData',NaN,...
                'YData',NaN,...
                'HitTest','off',...
                'PickableParts','none');

            obj.ErrorBarsVisible = NameValuePairs.ErrorBarsVisible;
            obj.ErrorBarsLineWidth = NameValuePairs.ErrorBarsLineWidth;


        end

        function delete(obj)

            delete(obj.violinPoints);
            delete(obj.violinOutlines);
            delete(obj.errorBars);

        end

    end


    %% Set and Get methods for public properties controlling violin points appearance
    methods
        %% PointsVisible

        function set.PointsVisible(obj,val)
            obj.violinPoints.Visible = val;
        end

        function PointsVisible = get.PointsVisible(obj)
            PointsVisible = obj.violinPoints.Visible;
        end

        %% XData

        function set.XData(obj,val)
            % set XData of the violinPoints scatter
            obj.violinPoints.XData = val;
            % update violinOutlines patch
            obj.updateViolinOutlines();
            % update error bars line
            obj.updateErrorBars();
        end

        function XData = get.XData(obj)
            XData = obj.violinPoints.XData;
        end

        %% YData

        function set.YData(obj,val)
            % set YData of the violinPoints scatter
            obj.violinPoints.YData = val;
            % update violinOutlines patch
            obj.updateViolinOutlines();
            % update error bars line
            obj.updateErrorBars();
        end

        function YData = get.YData(obj)
            YData = obj.violinPoints.YData;
        end

        %% XJitter

        function set.XJitter(obj,val)
            obj.violinPoints.XJitter = val;
        end

        function XJitter = get.XJitter(obj)
            XJitter = obj.violinPoints.XJitter;
        end

        %% XJitterWidth

        function set.XJitterWidth(obj,val)
            % set XJitterWidth of the violinPoints scatter
            obj.violinPoints.XJitterWidth = val;
            % update violinOutlines patch
            obj.updateViolinOutlines();
            % update error bars line
            obj.updateErrorBars();
        end

        function XJitterWidth = get.XJitterWidth(obj)
            XJitterWidth = obj.violinPoints.XJitterWidth;
        end

        %% MarkerEdgeColor

        function set.MarkerEdgeColor(obj,val)
            obj.violinPoints.MarkerEdgeColor = val;
        end

        function MarkerEdgeColor = get.MarkerEdgeColor(obj)
            MarkerEdgeColor = obj.violinPoints.MarkerEdgeColor;
        end

        %% MarkerSize

        function set.MarkerSize(obj,val)
            obj.violinPoints.SizeData = val;
        end

        function MarkerSize = get.MarkerSize(obj)
            MarkerSize = obj.violinPoints.SizeData;
        end

        %% MarkerFaceColorMode

        function set.MarkerFaceColorMode(obj,val)
            obj.violinPoints.MarkerFaceColor = val;
        end

        function MarkerFaceColorMode = get.MarkerFaceColorMode(obj)
            MarkerFaceColorMode = obj.violinPoints.MarkerFaceColor;
        end

        %% MarkerFaceAlpha

        function set.MarkerFaceAlpha(obj,val)
            obj.violinPoints.MarkerFaceAlpha = val;
        end

        function MarkerFaceAlpha = get.MarkerFaceAlpha(obj)
            MarkerFaceAlpha = obj.violinPoints.MarkerFaceAlpha;
        end        

        %% CData

        function set.CData(obj,val)
            obj.violinPoints.CData = val;
        end

        function CData = get.CData(obj)
            % CData = obj.violinPoints.CData;
            CData = [];
        end

        %% DataTipCell

        function set.DataTipCell(obj,val)
            if any(cellfun(@(x) isempty(x),val))
                % number of datatiprows in the plot
                nDataTipRows = numel(obj.violinPoints.DataTipTemplate.DataTipRows);
                % clear out default datatiprows
                for i = nDataTipRows:-1:2
                    obj.violinPoints.DataTipTemplate.DataTipRows(i) = [];
                end

                return
            else
                dtNames = val{1};
                dtData = val{2};
                for i = 1:numel(dtNames)
                    obj.violinPoints.DataTipTemplate.DataTipRows(i) = dataTipTextRow(dtNames{i},dtData{i});
                end
            end
        end

        function DataTipCell = get.DataTipCell(obj)
            % array of datatip rows for this violin
            dtRows = obj.violinPoints.DataTipTemplate.DataTipRows;
            % names and values for each datatip
            dtNames = arrayfun(@(x) x.Label,dtRows','UniformOutput',false);
            dtData = arrayfun(@(x) x.Value,dtRows','UniformOutput',false);
            % cell array of cell arrays with datatip info in violinPoints
            DataTipCell = {dtNames,dtData};
        end

    end

    %% Set and Get methods for public properties controlling violin outlines appearance
    methods
        %% ViolinOutlinesVisible

        function set.ViolinOutlinesVisible(obj,val)
            obj.violinOutlines.Visible = val;
        end

        function ViolinOutlinesVisible = get.ViolinOutlinesVisible(obj)
            ViolinOutlinesVisible = obj.violinOutlines.Visible;
        end

        %% ViolinLineWidth

        function set.ViolinLineWidth(obj,val)
            obj.violinOutlines.LineWidth = val;
        end

        function ViolinLineWidth = get.ViolinLineWidth(obj)
            ViolinLineWidth = obj.violinOutlines.LineWidth;
        end

        %% ViolinFaceColor

        function set.ViolinFaceColor(obj,val)
            obj.violinOutlines.FaceColor = val;
        end

        function ViolinFaceColor = get.ViolinFaceColor(obj)
            ViolinFaceColor = obj.violinOutlines.FaceColor;
        end

        %% ViolinEdgeColor

        function set.ViolinEdgeColor(obj,val)
            obj.violinOutlines.EdgeColor = val;
        end

        function ViolinEdgeColor = get.ViolinEdgeColor(obj)
            ViolinEdgeColor = obj.violinOutlines.EdgeColor;
        end

        %% ViolinFaceAlpha

        function set.ViolinFaceAlpha(obj,val)
            obj.violinOutlines.FaceAlpha = val;
        end

        function ViolinFaceAlpha = get.ViolinFaceAlpha(obj)
            ViolinFaceAlpha = obj.violinOutlines.FaceAlpha;
        end

    end

    %% Set and Get methods for public properties controlling violin error bars appearance
    methods
        %% ErrorBarsVisible

        function set.ErrorBarsVisible(obj,val)
            obj.errorBars.Visible = val;
        end

        function ErrorBarsVisible = get.ErrorBarsVisible(obj)
            ErrorBarsVisible = obj.errorBars.Visible;
        end
        
        %% ErrorBarsLineWidth

        function set.ErrorBarsLineWidth(obj,val)
            obj.errorBars.LineWidth = val;
        end

        function ErrorBarsLineWidth = get.ErrorBarsLineWidth(obj)
            ErrorBarsLineWidth = obj.errorBars.LineWidth;
        end

        %% ErrorBarsColor

        function set.ErrorBarsColor(obj,val)
            obj.errorBars.EdgeColor = val;
        end

        function ErrorBarsColor = get.ErrorBarsColor(obj)
            ErrorBarsColor = obj.errorBars.EdgeColor;
        end


    end

    % density methods
    methods

        function DensityData = get.DensityData(obj)

            if any(isnan(obj.YData)) || numel(obj.YData) < 2
                DensityData = [NaN;NaN];
                return
            end

            % get the density data with ksdensity, xDensity = horizontal spread, yDensity = y locations to evaluate xDensity
            [xDensity,yDensity] = ksdensity(obj.YData);

            densityIdxsInDataRange = yDensity >= min(obj.YData) & yDensity <= max(obj.YData);

            xDensity = xDensity(densityIdxsInDataRange);
            yDensity = yDensity(densityIdxsInDataRange);

            % check if empty (happens when all data points have the same value)
            if isempty(xDensity) || isempty(yDensity)
                DensityData = [NaN;NaN];
                return
            end

            % make sure first and last values are min and max, respectively
            yDensity(1) = min(obj.YData);
            yDensity(end) = max(obj.YData);
            
            % add flanking points in case we only have one data point
            yDensity = [yDensity(1)*(1-1E-5), yDensity, yDensity(end)*(1+1E-5)];
            xDensity = [0, xDensity, 0];

            % rescale the density data to match the x jitter width of the scatter points
            xDensity = rescale(xDensity,min(xDensity),obj.XJitterWidth/2);
            % get the x position of the violin on its axes
            xPosition = obj.XData(1);
            % concatenate with flipped copy to form both sides of the violin
            xDensity = [xPosition+xDensity,xPosition-fliplr(xDensity)];
            yDensity = [yDensity,fliplr(yDensity)];

            % % concatenate along first dimension to form the final output
            DensityData = [xDensity;yDensity];

        end

    end

    % private, hidden methods for various internal purposes
    methods (Access = private,Hidden = true)

        function updateViolinOutlines(obj)
            % set X and YData of the violinOutlines patch
            densityData = obj.DensityData;
            set(obj.violinOutlines,'XData',densityData(1,:),'YData',densityData(2,:));
        end

        function updateErrorBars(obj)

            % get the data for this group
            groupData = obj.YData;
            % get the x position of the violin on its axes
            xPosition = obj.XData(1);
            % get the halved jitter width
            xJitter = 0.5*obj.XJitterWidth;
            % width of the major (middle) bar
            majorWidth = 0.75*xJitter;
            % % width of the minor (upper and lower) bars
            minorWidth = 0.25*xJitter;

            % find the mean and SD
            groupMean = mean(groupData);
            groupStd = std(groupData);

            % calculate X and YData for each line of the error bar, separate by NaNs
            errorXData = [...
                xPosition-minorWidth, xPosition+minorWidth;...
                NaN, NaN;...
                xPosition-majorWidth, xPosition+majorWidth;...
                NaN, NaN;...
                xPosition-minorWidth, xPosition+minorWidth;...
                NaN, NaN;...
                xPosition, xPosition];

            errorYData = [...
                groupMean+groupStd, groupMean+groupStd;...
                NaN, NaN;...
                groupMean, groupMean;...
                NaN, NaN;...
                groupMean-groupStd, groupMean-groupStd;...
                NaN, NaN;...
                groupMean+groupStd, groupMean-groupStd];

            % set X and YData of the error bar line object
            set(obj.errorBars,'XData',errorXData','YData',errorYData');
        end

    end

end