function [distTransform,L] = labelBranches2(I)
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

%% separate the branches from each other

    % skeletonize the binary image (works better if we thin first)
    binarySkeleton = bwmorph(I,"thin",inf);
    binarySkeleton = bwskel(binarySkeleton);
    % get the branchpoints from the skeletonized binary image
    branchPoints = bwmorph(binarySkeleton,'branchpoints');
    % remove branchpoints so we are left with only branches
    branches = imsubtract(binarySkeleton,branchPoints);

%% compute distance transform of the branches to pass into watershed transform

    % compute binary distance transform
    distTransform = bwdist(branches);
    % negate all distances within the mask
    distTransform(I) = -distTransform(I);
    % negate all pixels in the image
    distTransform = -distTransform;
    
%% use watershed transform to build the branch labels

    % set all pixels outside mask to inf
    distTransform(~I) = inf;
    % compute watershed transform to construct the labels
    L = double(watershed(distTransform));
    % apply mask to the label image
    L( ~I ) = 0;

%% now fill in the gaps between branches

    % linear idxs to all pixels in the mask
    allObjectPixels = find(I);
    % linear idxs to all unlabeled pixels in the label matrix
    allMissingPixels = find(L==0);
    % linear idxs of all object pixels that are unlabeled in the label matrix
    missingObjectPixels = intersect(allObjectPixels,allMissingPixels);
    % set unlabeled object pixels to NaN
    L(allMissingPixels) = NaN;
    % create a mask identifying the missing, unlabeled object pixels
    missingMask = false(size(I));
    missingMask(missingObjectPixels) = 1;

    % fill any NaN values with the nearest non-NaN
    L = fillmissing2(L,"nearest","MissingLocations",missingMask);

    % set any remaining NaNs to 0
    L(isnan(L)) = 0;
end