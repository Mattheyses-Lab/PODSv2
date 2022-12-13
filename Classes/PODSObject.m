classdef PODSObject < handle
    % Object parameters class
    properties
        
        % parent image
        Parent PODSImage
        
        Area
        BoundingBox
        Centroid
        Circularity
        ConvexArea
        ConvexHull
        ConvexImage
        Eccentricity
        EquivDiameter
        Extent
        Extrema
        FilledArea
        Image
        MajorAxisLength
        MinorAxisLength
        Orientation
        Perimeter
        Solidity
        MaxFeretDiameter
        MinFeretDiameter
        
        % linear pixel indices to object pixels in full-sized image
        PixelIdxList
        
        % pixel indices
        PixelList
        
        % index to the subimage such that L(idx{:}) extracts the elements
        SubarrayIdx

        % coordinates to trace object boundary
        Boundary
        
        % name of parent group
        GroupName
        
        % S/B properties
        BGIdxList
        BufferIdxList
        SignalAverage
        BGAverage
        SBRatio
        
        % Selection and labeling
        Label PODSLabel
        Selected = false

        % object azimuth stats
        % (currently somewhat slow to calculate, so store them in memory)
        AzimuthAverage
        AzimuthStd

    end % end properties
    
    properties(Dependent = true)
        % various output values, object properties, and object images that
        % are too costly to store in memory, but quick to calculate if needed

        % list of values, average, and standard dev. of object azimuths
        AzimuthPixelValues

        % various object images
        OFSubImage 
        PaddedOFSubImage
        MaskedOFSubImage
        PaddedFFCIntensitySubImage
        PaddedMaskSubImage
        RestrictedPaddedMaskSubImage        
        PaddedAnalysisChannelSubImage
        PaddedColocNorm2MaxSubImage
        PaddedAzimuthSubImage
        
        CentroidX
        CentroidY

        % depends on selection status
        SelectionBoxLineWidth
        
        % OF properties of this object, dependent on OF image of Parent
        OFAvg
        OFMin
        OFMax
        OFPixelValues
        
        % need to make some dependent properties for object labels so
        % we can search for objects by the properties of their labels
        LabelIdx
        LabelName
        
        % Reference channel properties
        AvgReferenceChannelIntensity
        IntegratedReferenceChannelIntensity

        % index of this object in its parent 'Object' property
        SelfIdx

        % object name, based on SelfIdx
        Name

        % simplified boundary (may store in memory if becomes useful)
        SimplifiedBoundary
        
    end

    methods
        
        % constructor method
        function obj = PODSObject(ObjectProps,ParentImage,Label)
            
            if isempty(ObjectProps)
                return
            end

            if ~isempty(ParentImage)
                % Parent of PODSObject obj is the PODSImage obj that detected it
                obj.Parent = ParentImage;
            else
                obj.Parent = PODSImage.empty();
            end

            % properties from ObjectProps struct (from regionprops() using image mask)
            obj.Area = ObjectProps.Area;
            obj.BoundingBox = ObjectProps.BoundingBox;
            obj.Centroid = ObjectProps.Centroid;
            obj.Circularity = ObjectProps.Circularity;
            obj.ConvexArea = ObjectProps.ConvexArea;
            obj.ConvexHull = ObjectProps.ConvexHull;
            obj.ConvexImage = ObjectProps.ConvexImage;
            obj.Eccentricity = ObjectProps.Eccentricity;
            obj.Extrema = ObjectProps.Extrema;
            obj.EquivDiameter = ObjectProps.EquivDiameter;
            obj.Extent = ObjectProps.Extent;
            obj.FilledArea = ObjectProps.FilledArea;
            obj.Image = ObjectProps.Image;
            obj.MajorAxisLength = ObjectProps.MajorAxisLength;
            obj.MinorAxisLength = ObjectProps.MinorAxisLength;
            obj.Orientation = ObjectProps.Orientation;
            obj.Perimeter = ObjectProps.Perimeter;
            obj.PixelIdxList = ObjectProps.PixelIdxList;
            obj.PixelList = ObjectProps.PixelList;
            obj.SubarrayIdx = ObjectProps.SubarrayIdx;
            obj.Solidity = ObjectProps.Solidity;
            obj.MaxFeretDiameter = ObjectProps.MaxFeretDiameter;
            obj.MinFeretDiameter = ObjectProps.MinFeretDiameter;

            % calculated 8-connected boundary coordinates for ObjectBoxes
            obj.Boundary = ObjectProps.BWBoundary;
            
            % set default object label
            obj.Label = Label;

        end % end constructor method

        % class destructor – simple, any reindexing will be handled by higher level classes (PODSImage, PODSGroup)
        function delete(obj)
            delete(obj);
        end

        function object = saveobj(obj)

            object.Area = obj.Area;
            object.BoundingBox = obj.BoundingBox;
            object.Centroid = obj.Centroid;
            object.Circularity = obj.Circularity;
            object.ConvexArea = obj.ConvexArea;
            object.ConvexHull = obj.ConvexHull;
            object.ConvexImage = obj.ConvexImage;
            object.Eccentricity = obj.Eccentricity;
            object.EquivDiameter = obj.EquivDiameter;
            object.Extent = obj.Extent;
            object.Extrema = obj.Extrema;
            object.FilledArea = obj.FilledArea;
            object.Image = obj.Image;
            object.MajorAxisLength = obj.MajorAxisLength;
            object.MinorAxisLength = obj.MinorAxisLength;
            object.Orientation = obj.Orientation;
            object.Perimeter = obj.Perimeter;
            object.Solidity = obj.Solidity;
            object.MaxFeretDiameter = obj.MaxFeretDiameter;
            object.MinFeretDiameter = obj.MinFeretDiameter;

            % linear pixel indices to object pixels in full-sized image
            object.PixelIdxList = obj.PixelIdxList;

            % pixel indices
            object.PixelList = obj.PixelList;

            % index to the subimage such that L(idx{:}) extracts the elements
            object.SubarrayIdx = obj.SubarrayIdx;

            % coordinates to trace object boundary
            object.Boundary = obj.Boundary;

            % name of parent group
            object.GroupName = obj.GroupName;

            % S:B properties
            object.BGIdxList = obj.BGIdxList;
            object.BufferIdxList = obj.BufferIdxList;
            object.SignalAverage = obj.SignalAverage;
            object.BGAverage = obj.BGAverage;
            object.SBRatio = obj.SBRatio;

            % Selection and labeling
            object.Label = obj.Label;
            object.Selected = obj.Selected;

            % object azimuth stats
            object.AzimuthAverage = obj.AzimuthAverage;
            object.AzimuthStd = obj.AzimuthStd;

        end

        function SelfIdx = get.SelfIdx(obj)
            SelfIdx = find(obj.Parent.Object==obj);
        end

        function InvertSelection(obj)
            NewSelectionStatus = ~[obj(:).Selected];
            NewSelectionStatus = num2cell(NewSelectionStatus.');
            [obj(:).Selected] = deal(NewSelectionStatus{:});
        end

        %% Dependent 'get' methods

        function Name = get.Name(obj)
            Name = ['Object ',num2str(obj.SelfIdx)];
        end

        function SimplifiedBoundary = get.SimplifiedBoundary(obj)
            x = obj.Boundary(:,2);
            y = obj.Boundary(:,1);
            temp_poly = polyshape(x,y,"Simplify",false,"KeepCollinearPoints",false);
            SimplifiedBoundary = [temp_poly.Vertices(:,2) temp_poly.Vertices(:,1)];
        end

        function OFAvg = get.OFAvg(obj)
            % average OF of all pixels identified by the mask
            try
                OFAvg = mean(obj.Parent.OF_image(obj.PixelIdxList));
            catch
                OFAvg = NaN;
            end
        end
        
        function OFMax = get.OFMax(obj)
            % max OF of all pixels identified by the mask
            try
                OFMax = max(obj.Parent.OF_image(obj.PixelIdxList));
            catch
                OFMax = NaN;
            end
        end
        
        function OFMin = get.OFMin(obj)
            % min OF of all object pixels
            try
                OFMin = min(obj.Parent.OF_image(obj.PixelIdxList));
            catch
                OFMin = NaN;
            end
        end
        
        function AvgReferenceChannelIntensity = get.AvgReferenceChannelIntensity(obj)
            try
                AvgReferenceChannelIntensity = mean(obj.Parent.ReferenceImage(obj.PixelIdxList));
            catch
                AvgReferenceChannelIntensity = NaN;
            end
        end
        
        function IntegratedReferenceChannelIntensity = get.IntegratedReferenceChannelIntensity(obj)
            try
                IntegratedReferenceChannelIntensity = sum(obj.Parent.ReferenceImage(obj.PixelIdxList));
            catch
                IntegratedReferenceChannelIntensity = NaN;
            end
        end        
        
        function LabelIdx = get.LabelIdx(obj)
            LabelIdx = obj.Label.SelfIdx;
        end
        
        function LabelName = get.LabelName(obj)
            LabelName = obj.Label.Name;
        end
        
        function GroupName = get.GroupName(obj)
            % get the name of the group this object belongs to
            obj.GroupName = obj.Parent.Parent.GroupName;
        end

        function OFPixelValues = get.OFPixelValues(obj)
            % list of OF in all object pixels
            try
                OFPixelValues = obj.Parent.OF_image(obj.PixelIdxList);
            catch
                OFPixelValues = NaN;
            end
        end        

        function AzimuthPixelValues = get.AzimuthPixelValues(obj)
            % list of Azimuth values for each object pixel
            try
                AzimuthPixelValues = obj.Parent.AzimuthImage(obj.PixelIdxList);
            catch
                AzimuthPixelValues = NaN;
            end
        end
      
        function OFSubImage = get.OFSubImage(obj)
            OFImage = obj.Parent.OF_image;
            PaddedSubarrayIdx = padSubarrayIdx(obj.SubarrayIdx,5);
            dim = [length(PaddedSubarrayIdx{1,1}) length(PaddedSubarrayIdx{1,2})];
            OFSubImage = zeros(dim);
            OFSubImage(:) = OFImage(PaddedSubarrayIdx{:});
        end
        
        function PaddedOFSubImage = get.PaddedOFSubImage(obj)
            OFImage = obj.Parent.OF_image;
            PaddedSubarrayIdx = padSubarrayIdx(obj.SubarrayIdx,5);
            dim = [length(PaddedSubarrayIdx{1,1}) length(PaddedSubarrayIdx{1,2})];
            PaddedOFSubImage = zeros(dim);
            PaddedOFSubImage(:) = OFImage(PaddedSubarrayIdx{:});
        end        

        function MaskedOFSubImage = get.MaskedOFSubImage(obj)
            OFImage = obj.Parent.OF_image;
            MaskedOFSubImage = zeros(size(obj.Image));
            % masked
            MaskedOFSubImage(obj.Image) = OFImage(obj.PixelIdxList);
        end

        function PaddedAzimuthSubImage = get.PaddedAzimuthSubImage(obj)
            % get Azimuth image
            AzimuthImage = obj.Parent.AzimuthImage;
            % pad subarray and make square
            PaddedSubarrayIdx = padSubarrayIdx(obj.SubarrayIdx,5);
            % get size of subarray idx
            dim = [length(PaddedSubarrayIdx{1,1}) length(PaddedSubarrayIdx{1,2})];
            % initialize new subimage
            PaddedAzimuthSubImage = zeros(dim);
            % extract elements from main image into subimage
            PaddedAzimuthSubImage(:) = AzimuthImage(PaddedSubarrayIdx{:});
        end
        
        function PaddedFFCIntensitySubImage = get.PaddedFFCIntensitySubImage(obj)
            % get FFCIntensity image
            FFCIntensityImage = obj.Parent.I;
            % pad subarray and make square
            PaddedSubarrayIdx = padSubarrayIdx(obj.SubarrayIdx,5);
            % get size of subarray idx
            dim = [length(PaddedSubarrayIdx{1,1}) length(PaddedSubarrayIdx{1,2})];
            % initialize new subimage
            PaddedFFCIntensitySubImage = zeros(dim);
            % extract elements from main image into subimage
            PaddedFFCIntensitySubImage(:) = FFCIntensityImage(PaddedSubarrayIdx{:});
        end
        
        function PaddedMaskSubImage = get.PaddedMaskSubImage(obj)
            % get FFCIntensity image
            MaskImg = obj.Parent.bw;
            % pad subarray and make square
            PaddedSubarrayIdx = padSubarrayIdx(obj.SubarrayIdx,5);
            % get size of subarray idx
            dim = [length(PaddedSubarrayIdx{1,1}) length(PaddedSubarrayIdx{1,2})];
            % initialize new subimage
            PaddedMaskSubImage = false(dim);
            % extract elements from main image into subimage
            PaddedMaskSubImage(:) = MaskImg(PaddedSubarrayIdx{:});
        end
        
        function RestrictedPaddedMaskSubImage = get.RestrictedPaddedMaskSubImage(obj)
            % get full mask image
            FullSizedMaskImg = false(size(obj.Parent.bw));
            % set this object's pixels to on
            FullSizedMaskImg(obj.PixelIdxList) = true;
            % pad subarray and make square (if possible)
            PaddedSubarrayIdx = padSubarrayIdx(obj.SubarrayIdx,5);
            % get size of subarray idx
            dim = [length(PaddedSubarrayIdx{1,1}) length(PaddedSubarrayIdx{1,2})];
            % initialize new subimage
            RestrictedPaddedMaskSubImage = false(dim);
            % extract elements from main image into subimage
            RestrictedPaddedMaskSubImage(:) = FullSizedMaskImg(PaddedSubarrayIdx{:});
        end        

        function PaddedAnalysisChannelSubImage = get.PaddedAnalysisChannelSubImage(obj)
            AnalysisChannelImage = obj.Parent.ColocImage;
            PaddedSubarrayIdx = padSubarrayIdx(obj.SubarrayIdx,5);
            dim = [length(PaddedSubarrayIdx{1,1}) length(PaddedSubarrayIdx{1,2})];
            PaddedAnalysisChannelSubImage = zeros(dim);
            PaddedAnalysisChannelSubImage(:) = AnalysisChannelImage(PaddedSubarrayIdx{:});
        end
            
        function PaddedColocNorm2MaxSubImage = get.PaddedColocNorm2MaxSubImage(obj)
            ColocNorm2MaxImage = obj.Parent.ColocNormToMax;
            PaddedSubarrayIdx = padSubarrayIdx(obj.SubarrayIdx,5);
            dim = [length(PaddedSubarrayIdx{1,1}) length(PaddedSubarrayIdx{1,2})];
            PaddedColocNorm2MaxSubImage = zeros(dim);
            PaddedColocNorm2MaxSubImage(:) = ColocNorm2MaxImage(PaddedSubarrayIdx{:});
        end
        
        function SelectionBoxLineWidth = get.SelectionBoxLineWidth(obj)
            % set value of selection box linewidth depedning on object selection status
            switch obj.Selected
                case false
                    SelectionBoxLineWidth = 1;
                case true
                    SelectionBoxLineWidth = 2;
            end
        end
        
        function CentroidX = get.CentroidX(obj)
            CentroidX = obj.Centroid(1);
        end

        function CentroidY = get.CentroidY(obj)
            CentroidY = obj.Centroid(2);
        end        

    end % end methods
    
    methods (Static)
        function obj = loadobj(object)

            % build ObjectProps struct to call PODSObject constructor
            ObjectProps.Area = object.Area;
            ObjectProps.BoundingBox = object.BoundingBox;
            ObjectProps.Centroid = object.Centroid;
            ObjectProps.Circularity = object.Circularity;
            ObjectProps.ConvexArea = object.ConvexArea;
            ObjectProps.ConvexHull = object.ConvexHull;
            ObjectProps.ConvexImage = object.ConvexImage;
            ObjectProps.Eccentricity = object.Eccentricity;
            ObjectProps.Extrema = object.Extrema;

            ObjectProps.EquivDiameter = object.EquivDiameter;
            ObjectProps.Extent = object.Extent;

            ObjectProps.FilledArea = object.FilledArea;
            ObjectProps.Image = object.Image;
            ObjectProps.MajorAxisLength = object.MajorAxisLength;
            ObjectProps.MinorAxisLength = object.MinorAxisLength;
            ObjectProps.Orientation = object.Orientation;
            ObjectProps.Perimeter = object.Perimeter;
            ObjectProps.MaxFeretDiameter = object.MaxFeretDiameter;
            ObjectProps.MinFeretDiameter = object.MinFeretDiameter;

            ObjectProps.Solidity = object.Solidity;


            ObjectProps.BWBoundary = object.Boundary;

            ObjectProps.PixelIdxList = object.PixelIdxList;
            ObjectProps.PixelList = object.PixelList;
            ObjectProps.SubarrayIdx = object.SubarrayIdx;

            % get the object label (PODSLabel)
            ObjectLabel = object.Label;

            % create new instance of PODSObject
            obj = PODSObject(ObjectProps,PODSImage.empty(),ObjectLabel);

            obj.GroupName = object.GroupName;

            obj.BGIdxList = object.BGIdxList;
            obj.BufferIdxList = object.BufferIdxList;
            obj.SignalAverage = object.SignalAverage;
            obj.BGAverage = object.BGAverage;
            obj.SBRatio = object.SBRatio;

            obj.Selected = object.Selected;

            obj.AzimuthAverage = object.AzimuthAverage;
            obj.AzimuthStd = object.AzimuthStd;
        end
    end

end % end classdef