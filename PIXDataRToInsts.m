function so = PIXDataRToInsts( data, r )

% function stackOut = PIXDataRToInsts( data, r )
%
%  convert an NxM array of pixel data collected using the 'r' struct
%  and embedded UV pairs/names into an array of structs with the appropriate
%  data fields to match the .mat format for stacks at CIL. 
%
%  NOTE: at this time, we assume ONE CAMERA collection. I.e., r.cams has one
%  element, and data is NxMx1. Some of the output from this function is
%  extraneous, but is included for compatibility with other CIL routines that
%  use the .mat data files.
%
%  stackOut will be an array of structs with the fields:
%    name  -- instrument name
%    data  -- data for that instrucment, with fields:
%       XYZ   -- xyz location of pixels
%       RAW   -- pixel data uncorrected 
%       CORRECTED -- corrected pixel data (duplicate of RAW since there
%      is no correction information (shutter or gain) in r or data
%       T     -- time generated from r.epoch, assuming 0.5 sec sampling.
%       CAM   -- array of cameraNumber from r.cams(1)

% get all the unique names from r

uname = unique( r.cams(1).names );

% encoded UV for find.
UVencoded = r.cams(1).U + r.cams(1).V * 10000;

% one T for all data. but what is it? ASSUME -- starts at r.epoch and
% increments by 0.5 seconds. USER?
T = 0:size(data,1)-1;
T = T .* 0.5;   %%% assumption!!!!
T = T + r.epoch;

for ii = 1:length(uname)

    % empty data
        XYZ = []; RAW = []; CAM = [];
        SHUTTER = []; CORRECTED = [];
        GAIN = [];
        WARNING = '';

        nind = strmatch( uname{ii}, r.cams(1).names, 'exact' );

        XYZ = r.cams(1).XYZ(nind,:);
        RAW = data(:,nind);

        CAM = ones(length(nind),1) * r.cams(1).cameraNumber;

        CORRECTED = RAW;

        tmp.RAW = RAW;
        tmp.CORRECTED = CORRECTED;
        tmp.T = T;
        tmp.CAM = CAM;
        tmp.XYZ = XYZ;

        so(ii).name = uname{ii};
        so(ii).data = tmp;
        
end





%
%   Copyright (C) 2017  Coastal Imaging Research Network
%                       and Oregon State University

%    This program is free software: you can redistribute it and/or
%    modify it under the terms of the GNU General Public License as
%    published by the Free Software Foundation, version 3 of the
%    License.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see
%                                <http://www.gnu.org/licenses/>.

% CIRN: https://coastal-imaging-research-network.github.io/
% CIL:  http://cil-www.coas.oregonstate.edu
%

