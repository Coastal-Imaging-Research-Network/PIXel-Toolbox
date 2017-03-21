function [newData, newR] = PIXInterpStack( data, R )

% Interp stack data for given stack data and r
%
%  [newData, newR] = PIXInterpStack( oldData, oldR )
%
%   where oldData is the old stack data and oldR is the CAMERA struct
%   for the camera the data came from out of R. E.g., r.cams(3), not
%   just 'r'. 
%

% note: this is not done as part of loadStack because loadStack doesn't
% have the 'r' struct to know which pixels are interped. Also note, this
%  function depends on the fact that interped instruments are always
% last in the list, so all pixels past the first interped pixel are also
% interped. 

%  find first interped pixel in r list. Pass all interped pixels on
% to PIXInterp.

isIn = find(bitand(R.flags, PIXInterpUV));

% handle "no interpolated pixels"
if isempty(isIn)
	newData = data;
	newR = R;
	return;
end

starts = min(isIn);
ends = max(isIn);

newR = R;
newU = [R.U(1:starts-1); R.Uraw(starts:ends)];
newV = [R.V(1:starts-1); R.Vraw(starts:ends)];
newR.U = newU;
newR.V = newV;
newR.names = []; newR.types = [];
for( kk=1:ends )
	newR.names{kk} = R.names{kk};
	newR.types{kk} = R.types{kk};
end

newData = data(:,1:ends);
newData(:,starts:ends) = ...
    PIXInterp( data(:,starts:end),  ...
        [R.Uraw(starts:end) R.Vraw(starts:end)] );

% 

%
% $Id: PIXInterpStack.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXInterpStack.m,v $
% Revision 1.2  2011/04/15 21:58:56  stanley
% no interp pixels
%
% Revision 1.1  2010/09/10 17:32:00  stanley
% Initial revision
%
%
%
%key pixel pixelExtract 
%comment  Interpolates bracketing pixels to rawUV locations 
%

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

