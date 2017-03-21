function i = PIXGetInstrumentByID( id )

% i = PIXGetInstrumentByID( id )
%
%  returns the instrument data for the instrument with the associated id.
%
%  this mucks through the coord data to send back an array of coord structs
%  that correspond to the ids in the instrument data. the element of i
%  that has this data is called 'c'.
% 

global PIXInstruments;
global PIXCoords;

j = find( [PIXInstruments(:).id] == id );

if isempty(j) 
	warning( 'No instrument matches that id.' );
	return;
end;

i = PIXInstruments(j);

% find coord structs 
if isempty(i.coords)
	i.x = [];
else

	[ci,ia,ib] = intersect( i.coords, [PIXCoords(:).id] );
	% ib has indexes of i.coords into PIXCoords array
	i.c = PIXCoords(ib);

end

% 

%
% $Id: PIXGetInstrumentByID.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXGetInstrumentByID.m,v $
% Revision 1.2  1904/03/26 11:20:04  stanley
% auto insert keywords
%
%
%key internal pixel pixelDesign 
%comment  Load a specific instrument 
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

