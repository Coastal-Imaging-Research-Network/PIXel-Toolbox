function c = PIXGetCameraData( station, when )

% c = PIXGetCameraData( station, when )
%
%  where station is the station short name ('argus00', e.g.) and
%  when is the epoch time you want the data for.
%
%  c is an array of structs with camera data 
%
%  This is the argusDB version of this routine. The matlab databas
%  version will be different.

s = DBGetStationsByName( station, when );

if isempty(s)
	error('No stations by that name at that time');
end

c = DBGetCamerasByStation( s.id, when );

% 

%
% $Id: PIXGetCameraData.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXGetCameraData.m,v $
% Revision 1.2  1904/03/26 11:20:04  stanley
% auto insert keywords
%
%
%key internal pixel pixelDesign 
%comment  argusDB version to get camera data 
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

