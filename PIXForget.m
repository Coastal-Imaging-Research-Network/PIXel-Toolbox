function PIXForget()

% PIXForget()
%
% forget all the changes to station data. Simply forget it was modified
% and then load the station again.

global PIXPackages;
global PIXInstruments;
global PIXCoords;
global PIXStation;
global PIXModified;

PIXModified = 0;

PIXSetStation(PIXStation);

% 

%
% $Id: PIXForget.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXForget.m,v $
% Revision 1.2  1904/03/26 11:20:03  stanley
% auto insert keywords
%
%
%key pixel pixelDesign 
%comment  Clear all local station data changes (like init) 
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

