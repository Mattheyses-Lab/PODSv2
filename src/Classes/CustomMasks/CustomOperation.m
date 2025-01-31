classdef CustomOperation < handle
%%  CUSTOMOPERATION Defines individual processing steps in a CustomMask  
%
%   See also CustomMask, CustomMaskMaker, CustomImage
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

        % type of operation
        OperationType = 'Morphological';
        % the name of this Operation ('TopHat' by default)
        OperationName = 'TopHat';

        OperationParams

        ParamsMap

        % structuring element
        SE

        % Images(s) that this operation will target on obj.Execute()
        Target CustomImage
       
    end
    
    methods
        
        % constructor method
        function obj = CustomOperation(OperationType,OperationName,Target,OperationParams,varargin)
            obj.Target = Target;
            obj.OperationType = OperationType;
            obj.OperationName = OperationName;
            obj.OperationParams = OperationParams;

            %NamedParams = varargin{1,1};

            if iseven(numel(varargin))
                if numel(varargin)==0
                    return
                else
                    obj.ParamsMap = containers.Map;
                    for i = 1:2:numel(varargin)
                        obj.ParamsMap(varargin{i}) = varargin{i+1};
                    end
                end
            end
        end

        function delete(obj)
            delete(obj);
        end
        
        function OutputImage = Execute(obj)

                switch obj.OperationType
                    case 'Empty'
                        OutputImage = obj.Target.ImageData;
                    case 'Morphological'
                        switch obj.OperationName
                            case 'TopHat'
                                OutputImage = imtophat(obj.Target.ImageData,obj.OperationParams{1});
                            case 'BottomHat'
                                OutputImage = imbothat(obj.Target.ImageData,obj.OperationParams{1});
                            case 'Erode'
                                OutputImage = imerode(obj.Target.ImageData,obj.OperationParams{1});
                            case 'Dilate'
                                OutputImage = imdilate(obj.Target.ImageData,obj.OperationParams{1});
                            case 'Open'
                                OutputImage = imopen(obj.Target.ImageData,obj.OperationParams{1});
                            case 'Close'
                                OutputImage = imclose(obj.Target.ImageData,obj.OperationParams{1});
                            case 'OpenByReconstruction'
                                Ie = imerode(obj.Target.ImageData,obj.OperationParams{1});
                                OutputImage = imreconstruct(Ie,obj.Target.ImageData);
                        end
                    case 'Binarize'
                        switch obj.OperationName
                            case 'Adaptive'
                                % OperationParams = {sensitivity, neighborhood size, statistic}
                                T = adaptthresh(obj.Target.ImageData,obj.OperationParams{1},...
                                    "NeighborhoodSize",obj.OperationParams{2},...
                                    "Statistic",obj.OperationParams{3});
                                OutputImage = imbinarize(obj.Target.ImageData,T);
                            case 'Otsu'
                                OutputImage = imbinarize(obj.Target.ImageData,graythresh(obj.Target.ImageData));
                        end
                    case 'ImageFilter'
                        FilterSize = obj.OperationParams{1};
                        I = obj.Target.ImageData;
                        switch obj.OperationName
                            case 'Median'
                                OutputImage = medfilt2(obj.Target.ImageData,[FilterSize FilterSize]);
                            case 'Average'
                                OutputImage = imfilter(obj.Target.ImageData,fspecial('average',FilterSize));
                            case 'Gaussian'
                                Sigma = obj.OperationParams{2};
                                OutputImage = imgaussfilt(obj.Target.ImageData,...
                                    Sigma,...
                                    'FilterSize',FilterSize,...
                                    'FilterDomain','spatial');
                            case 'Wiener'
                                OutputImage = wiener2(obj.Target.ImageData,FilterSize);
                            case 'Bilateral'
                                DegreeOfSmoothing = 0.01*diff(getrangefromclass(I)).^2;
                                SpatialSigma = obj.OperationParams{2};
                                OutputImage = imbilatfilt(obj.Target.ImageData,...
                                    DegreeOfSmoothing,...
                                    SpatialSigma,...
                                    'NeighborhoodSize',FilterSize);
                            case 'LaplacianOfGaussian'
                                Sigma = obj.OperationParams{2};
                                logFilter=fspecial('log',[FilterSize FilterSize],Sigma); 
                                OutputImage=imfilter(I,logFilter,'replicate');
                            case 'NonLocalMeans'
                                DegreeOfSmoothing = obj.OperationParams{1};
                                SearchWindowSize = obj.OperationParams{2};
                                ComparisonWindowSize = obj.OperationParams{3};
                                OutputImage = imnlmfilt(I,...
                                    "DegreeOfSmoothing",DegreeOfSmoothing,...
                                    "SearchWindowSize",SearchWindowSize,...
                                    "ComparisonWindowSize",ComparisonWindowSize);
                        end
                    case 'ContrastEnhancement'
                        switch obj.OperationName
                            case 'EnhanceFibers'
                                FiberWidth = obj.OperationParams{1};
                                ObjectPolarity = "Bright";
                                C = maxhessiannorm(obj.Target.ImageData,FiberWidth);
                                OutputImage = fibermetric(obj.Target.ImageData,FiberWidth,...
                                    "ObjectPolarity",ObjectPolarity,"StructureSensitivity",0.5*C);
                            case 'LocalBrighten'
                                OutputImage = imlocalbrighten(obj.Target.ImageData);
                            case 'AdaptiveHistogramEqualization'
                                OutputImage = adapthisteq(obj.Target.ImageData);
                            case 'Sharpen'
                                OutputImage = imsharpen(obj.Target.ImageData);
                            case 'AdjustContrast'
                                OutputImage = imadjust(obj.Target.ImageData);
                            case 'LocalContrast'
                                I = im2uint8(obj.Target.ImageData);
                                OutputImage = localcontrast(I);
                                OutputImage = im2double(OutputImage);
                            case 'Flatfield'
                                Sigma = obj.OperationParams{1};
                                FilterSize = obj.OperationParams{2};
                                OutputImage = imflatfield(obj.Target.ImageData,...
                                    Sigma,...
                                    'FilterSize',FilterSize);
                            case 'ReduceHaze'
                                OutputImage = imreducehaze(obj.Target.ImageData);
                            case 'Scale0To1'
                                I = obj.Target.ImageData;
                                OutputImage = rescale(I,0,1);
                        end
                    case 'Special'
                        switch obj.OperationName
                            case 'RotatingMaxOpen'
                                RotatingLineLength = obj.OperationParams{1};
                                I = obj.Target.ImageData;
                                % initialize super open image
                                I_superopen = zeros(size(I),'like',I);
                                % max opening with rotating line segment
                                for phi = 1:180
                                    str_el = strel('line',RotatingLineLength,phi);
                                    I_superopen = max(I_superopen,imopen(I,str_el));
                                end
                                OutputImage = I_superopen;
                            case 'BWRotatingMaxOpenAndClose'
                                RotatingLineLength = obj.OperationParams{1};
                                bw = obj.Target.ImageData;
                                BWempty = false(size(bw));
                                for k = 1:1:180
                                    SEline = strel('line',RotatingLineLength,k);
                                    SEline2 = strel('line',RotatingLineLength,k);
                                    BWtemp = imopen(bw,SEline);
                                    BWtemp = imclose(BWtemp,SEline2);
                                    BWempty = BWempty+BWtemp;
                                end
                                OutputImage = logical(BWempty);
                            case 'BWRotatingMaxOpen'
                                RotatingLineLength = obj.OperationParams{1};
                                bw = obj.Target.ImageData;
                                bw2 = false(size(bw));
                                for k = 1:1:180
                                    bw2 = bw2 + imopen(bw,strel('line',RotatingLineLength,k));
                                end
                                OutputImage = logical(bw2);
                            case 'LineFilterTransform'
                                I = obj.Target.ImageData;
                                [~,LFT,~] = LFT_OFT_loopless(I,10,20);
                                OutputImage = LFT;
                            case 'OrientationFilterTransform'
                                I = obj.Target.ImageData;
                                [OFT,~,~] = LFT_OFT_loopless(I,10,20);
                                OutputImage = OFT;
                            case 'BlindDeconvolution'
                                I = obj.Target.ImageData;
                                FilterSize = obj.OperationParams{1};
                                OutputImage = deconvblind(I,ones(3),FilterSize);
                            case 'Test'
                                I = obj.Target.ImageData;
                                %% Test code for new operations
                                % ex: I = some_image_operation(I)
                                %% End test code
                                RotatingLineLength = 20;
                                bw = obj.Target.ImageData;
                                bw2 = false(size(bw));
                                for k = 1:1:180
                                    bwtophat = imtophat(bw,strel('line',RotatingLineLength,k));
                                    bwdetectedline = bw-bwtophat;
                                    bw2 = bw2 + bwdetectedline;
                                end
                                OutputImage = logical(bw2);
% 
%                                 OutputImage = I;
                            case 'Complement'
                                I = obj.Target.ImageData;
                                 OutputImage = imcomplement(I);
                            case 'ZerocrossEdgesFilled'
                                I = obj.Target.ImageData;
                                % clear border
                                I = ClearImageBorder(I,10);
                                %% Detect edges
                                IEdges = edge(I,'zerocross',0);
                                % mask is the edge pixels
                                bw = sparse(IEdges);
                                %% uncomment below to fill in mask
                                % BUILD 8-CONNECTED LABEL MATRIX
                                L = sparse(bwlabel(full(bw),8));
                                % fill in outlines and recreate mask
                                bwtemp = zeros(size(bw));
                                bwempty = zeros(size(bw));
                                props = regionprops(full(L),full(bw),...
                                    {'FilledImage',...
                                    'SubarrayIdx'});
                                for obj_idx = 1:max(max(full(L)))
                                    bwempty(props(obj_idx).SubarrayIdx{:}) = props(obj_idx).FilledImage;
                                    bwtemp = bwtemp | bwempty;
                                    bwempty(:) = 0;
                                end

                                OutputImage = logical(bwtemp);

                            case 'CellDetection'
                                I = obj.Target.ImageData;
                                [~,threshold] = edge(I,'sobel');
                                fudgeFactor = 0.5;
                                BWs = edge(I,'sobel',threshold * fudgeFactor);
                                se90 = strel('line',3,90);
                                se0 = strel('line',3,0);
                                BWsdil = imdilate(BWs,[se90 se0]);
                                BWdfill = imfill(BWsdil,'holes');
                                seD = strel('diamond',1);
                                BWfinal = imerode(BWdfill,seD);
                                BWfinal = imerode(BWfinal,seD);
                                OutputImage = BWfinal;
                            case 'BWAreaOpen'
                                BWArea = obj.OperationParams{1};
                                I = obj.Target.ImageData;
                                Inew = bwareaopen(I,BWArea,4);
                                OutputImage = Inew;
                            case 'SobelGradient'
                                [OutputImage,~] = imgradient(obj.Target.ImageData,'sobel');
                            case 'stdfiltBackgroundSubtraction'
                                I = obj.Target.ImageData;
                                Istd = stdfilt(I);
                                %BGMask = Istd <= 0.01;
                                OutputImage = max(I - mean(I(Istd <= 0.01)),0);
                        end

                    case 'Arithmetic'

                        switch obj.OperationName
                            case '+'
                                OutputImage = obj.Target(1).ImageData + obj.Target(2).ImageData;
                            case '-'
                                OutputImage = obj.Target(1).ImageData - obj.Target(2).ImageData;
                            case '*'
                                OutputImage = obj.Target(1).ImageData .* obj.Target(2).ImageData;
                            case '÷'
                                OutputImage = obj.Target(1).ImageData ./ obj.Target(2).ImageData;
                        end

                    case 'EdgeDetection'

                        switch obj.OperationName
                            case 'Sobel'
                                OutputImage = edge(obj.Target.ImageData,"sobel");
                            case 'Prewitt'
                                OutputImage = edge(obj.Target.ImageData,"prewitt");
                            case 'Canny'
                                OutputImage = edge(obj.Target.ImageData,"canny");
                            case 'Roberts'
                                OutputImage = edge(obj.Target.ImageData,"roberts");
                            case 'log'
                                OutputImage = edge(obj.Target.ImageData,"log");
                            case 'zerocross'
                                OutputImage = edge(obj.Target.ImageData,"zerocross");
                        end

                    case 'bwmorph'
                        I = obj.Target.ImageData;
                        if ~isa(I,"logical")
                            error("Target image type must be logical")
                        end
                        
                        n = obj.OperationParams{1};
                        OutputImage = bwmorph(I,obj.OperationName,n);
                end

        end

    end


end
