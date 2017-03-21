function id = PIXAddLine( instrumentID, x1, y1, x2, y2, z, dx, name )

% id = PIXAddLine( instrumentID, x1, y1, x2, y2, z, dx, name );
%
%  add the points in meatspace from (x1,y1) to (x2,y2) with spacing dx to
%  instrumentID. Optionally, tag this point with a name.

global PIXInstruments;
global PIXCoords;
global PIXModified;

i = PIXGetInstrumentByID( instrumentID );
if isempty(i)
	error(['No instrument with id ' num2str(instrumentID) ]);
end;

if nargin == 8
	c.name = name;
else
	c.name = '';
end;

c.x1 = x1; 
c.y1 = y1; 
c.x2 = x2; 
c.y2 = y2; 
c.z = z;
c.dx = dx; 
c.dy = 0;

id = PIXNewCoords(c);

% and add to the intstrument
inst = find( [PIXInstruments(:).id] == instrumentID );
PIXInstruments(inst).coords(length(PIXInstruments(inst).coords)+1) = id;
PIXModified = 1;

% 

%
% $Id: PIXAddLine.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXAddLine.m,v $
% Revision 1.3  2013/09/27 01:36:25  stanley
% fixed nargin check!
%
% Revision 1.2  1904/03/26 11:20:01  stanley
% auto insert keywords
%
%
%key pixel pixelDesign 
%comment  Add a line to an instrument, defined by endpoints 
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

