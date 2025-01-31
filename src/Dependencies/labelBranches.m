function [branchesLabeled,dilatedL] = labelBranches(I)
%%  LABELBRANCHES labels individual branches in binary image, I
%   
%   
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

    % skeletonize the binary image (works "better" if we thin first)
    binarySkeleton = bwmorph(I,"thin",inf);
    binarySkeleton = bwskel(binarySkeleton);
    % get the branchpoints from the skeletonized binary image
    branchPoints = bwmorph(binarySkeleton,'branchpoints');
    % remove branchpoints so we are left with only branches
    branches = imsubtract(binarySkeleton,branchPoints);
    % label the individual 8-connected branches (this is the first output)
    branchesLabeled = bwlabel(branches);
    % create an image where every unlabeled pixel = NaN
    nanL = branchesLabeled;
    nanL(nanL==0) = NaN;
    % preallocate the output image which will hold our full label image
    dilatedL = zeros(size(nanL));
    % preallocate mask image of just the branches
    branchMask = false(size(branchesLabeled));
    % set branch pixels to true
    branchMask(branchesLabeled>0) = 1;
    % get the linear pixel idx list for each 8-connected object in the input binary image
    props = regionprops(I,{'PixelIdxList'});
    % cell array of labels for each pixel in the mask
    pixelLabels = cell(length(props),1);
    % cell array of linear idxs for each pixel in the mask
    pixelLinearIdxs = cell(length(props),1);
    % the number of 8-connected objects in the input mask
    nObjects = length(props);

    % for each object
    parfor i = 1:nObjects
        % initialize array of NaNs, same size as input
        objectnanL = nan(size(nanL));
        % get the list of linear idxs for each pixel in the object
        objectPixels = props(i).PixelIdxList;
        % get the branch labels for this object
        objectnanL(objectPixels) = nanL(objectPixels);
        % get the unique labels in the object
        labelsInObject = unique(objectnanL(~isnan(objectnanL)));
        % add the object pixel idxs to our cell array
        pixelLinearIdxs{i,1} = objectPixels;
        % if only one unique label
        if numel(labelsInObject)==1
            % add labels to the cell array of pixel labels
            pixelLabels{i,1} = repmat(labelsInObject,numel(objectPixels),1);
        else
            % get the mask of just this object
            objectMask = false(size(I));
            objectMask(objectPixels) = 1;
            % the mask representing missing pixels we want to fill with fillmissing2()
            objectMissingMask = objectMask & ~branchMask;
            % get the label image for this object
            objectDilatedL = fillmissing2(objectnanL,"nearest","MissingLocations",objectMissingMask);
            % add labels to the cell array of pixel labels
            pixelLabels{i,1} = objectDilatedL(objectPixels);
        end

    end

    % concatenate cell arrays of pixel idxs and labels into column vectors
    pixelLinearIdxsVec = cat(1,pixelLinearIdxs{:});
    pixelLabelsVec = cat(1,pixelLabels{:});
    % add the labels to their corresponding pixels
    dilatedL(pixelLinearIdxsVec) = pixelLabelsVec;
end