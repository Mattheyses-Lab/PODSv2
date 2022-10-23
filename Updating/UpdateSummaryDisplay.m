function [] = UpdateSummaryDisplay(source,varargin)

    PODSData = guidata(source);

    % check if we really need to update to prevent unnecessary overhead
    % (varargin{1} = {'Project','Image',...}
    if ~isempty(varargin)
        % if no choices match currently selected display type, don't update
        if ~any(ismember(varargin{1},PODSData.Settings.SummaryDisplayType))
            return
        end
    end

    switch PODSData.Settings.SummaryDisplayType
        case 'Project'
            PODSData.Handles.ProjectDataTable.Text = {['<b>Project: </b>',PODSData.ProjectName];...
                                             ['Number of Groups:     ', num2str(PODSData.nGroups)];...
                                             ['Input File Type:      ', PODSData.Settings.InputFileType];...
                                             ['Current Tab:          ', PODSData.Settings.CurrentTab];...
                                             ['Previous Tab:         ', PODSData.Settings.PreviousTab]};

        case 'Group'
            cGroup = PODSData.CurrentGroup;

            if isempty(cGroup)
                PODSData.Handles.ProjectDataTable.Text = {'No groups found...'};
            else
                PODSData.Handles.ProjectDataTable.Text = {['<b>Group: </b>',cGroup.GroupName];...
                    ['Number of Replicates: ', num2str(cGroup.nReplicates)];...
                    ['Group Image Avg OF:   ', num2str(cGroup.OFAvg)];...
                    ['Total Objects:        ', num2str(cGroup.TotalObjects)]};
            end

        case 'Image'
            % in case no images exist for current group
            try
                cReplicate = PODSData.CurrentImage(1);
            catch
                PODSData.Handles.ProjectDataTable.Text = {'Load FFC and FPM data first...'};
                return
            end

            PODSData.Handles.ProjectDataTable.Text = {['<b>Image: </b>',cReplicate.pol_shortname];...
                ['Dimensions:           ', cReplicate.Dimensions];...
                ['<b>Masking</b>'];...
                ['Mask Threshold:       ', num2str(cReplicate.level)];...
                ['Threshold Adjusted:   ', Logical2String(cReplicate.ThresholdAdjusted)];...
                ['Number of Objects:    ', num2str(cReplicate.nObjects)];...
                ['<b>Order Factor Results</b>'];...
                ['Avg Pixel OF:         ', num2str(cReplicate.OFAvg)];...
                ['<b>Status</b>'];...
                ['Files Loaded:         ', Logical2String(cReplicate.FilesLoaded)];...
                ['FFC Performed:        ', Logical2String(cReplicate.FFCDone)];...
                ['Mask Generated:       ', Logical2String(cReplicate.MaskDone)];...
                ['Objects Detected:     ', Logical2String(cReplicate.ObjectDetectionDone)];...
                ['OF Calculated:        ', Logical2String(cReplicate.OFDone)];...
                ['Local SB Calculated:  ', Logical2String(cReplicate.LocalSBDone)]};


        case 'Object'
            % in case no images exist for current group
            try
                cReplicate = PODSData.CurrentImage(1);
            catch
                PODSData.Handles.ProjectDataTable.Text = {'Load FFC and FPM data first...'};
                return
            end

            try
                cObject = cReplicate.CurrentObject;
            catch
                PODSData.Handles.ProjectDataTable.Text = {'No objects found for this image...'};
            end

            PODSData.Handles.ProjectDataTable.Text = {['<b>Object Summary</b>'];...
                [cObject.Name];...
                ['Average OF:           ', num2str(cObject.OFAvg)];...
                ['Pixel Area:           ', num2str(cObject.Area)];...
                ['Permieter:            ', num2str(cObject.Perimeter)];...
                ['Average Signal:       ', num2str(cObject.SignalAverage)];...
                ['Background Average:   ', num2str(cObject.BGAverage)];...
                ['Signal-Background:    ', num2str(cObject.SBRatio)];...
                ['Original Idx:         ', num2str(cObject.OriginalIdx)];...
                ['Azimuth Average:      ', num2str(cObject.AzimuthAverage)];...
                ['Azimuth Std. Dev.:    ', num2str(cObject.AzimuthStd)];...
                ['Circularity:          ', num2str(cObject.Circularity)];...
                ['Eccentricity:         ', num2str(cObject.Eccentricity)]};

    end

end