function id = PIXAddPoints( instrumentID, x, y, z, name, isPoly )

% id = PIXAddPoints( instrumentID, x, y, z, name );
%
%  add the points at meatspace (x,y,z) to the instrument referred to by
%  instrumentID. Optionally, tag this point with a name. x,y,and z can
%  be an Nx1 array of values, as long as they are all the same length.
%

% hidden parameter 'isPoly', means this is a polygon and not a normal
% set of points. will cause this to be unexpanded in PIXBuildCollect
% but added as a poly struct to the 'r' struct for processing later in
% PIXRebuildCollect. Do not care what value, just if the param is there.
% note: must have 'name' in call for poly. 

global PIXInstruments;
global PIXCoords;
global PIXModified;

if (nargin < 4) 
	error('not enough arguments');
end;

i = PIXGetInstrumentByID( instrumentID );
if isempty(i)
	error(['No instrument with id ' num2str(instrumentID) ]);
end;

if( length(x) ~= length(y) ) 
	error( 'x and y not same length');
end
if( length(x) ~= length(z) )
	error( 'x and z are not same length' );
end

if nargin > 4
	c.name = name;
else
	c.name = '';
end;

c.x1 = x(:)';
c.y1 = y(:)'; 
c.x2 = 0; 
c.y2 = 0; 
c.z = z(:)';
c.dx = 0; 
c.dy = 0;

% flag a polygon
if nargin > 5
    c.dx = -1;
    c.dy = -1;
end

id = PIXNewCoords(c);

% and add to the intstrument
inst = find( [PIXInstruments(:).id] == instrumentID );
PIXInstruments(inst).coords(length(PIXInstruments(inst).coords)+1) = id;
PIXModified = 1;

% 

%
% $Id: PIXAddPoints.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXAddPoints.m,v $
% Revision 1.4  2013/09/27 01:59:06  stanley
% added poly flag
%
% Revision 1.3  1904/08/11 12:15:51  stanley
% *** empty log message ***
%
%
%key pixel pixelDesign 
%comment  Add more points to an instrument 
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

