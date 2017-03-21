function r = PIXFindCollect( stackfile, collect )

% PIXFindCollect  -- find the data for the collection that took a specified
%    stack. Optionally specify the collect name to override the default.
%
%    r = PIXFindCollect( stackfile )  will load the information from
%    the stackfile and then load the collection structure that created
%    the pixlist for the stack.
%
%    PIXFindCollect( stackfile, collect ) will use the name specified in 
%    'collect' to find the source data for the stack. This mode is intended
%    for testing only.
%

if ~ischar( stackfile ) 
	error('stack file is not a string!');
end

p = parseFilename( stackfile ); 

i = loadStack( stackfile, 'info' );
if isempty(i)
	error(['Could not load stack ' stackfile] );
end

if nargin == 2
	aoi = collect;
else
	aoi = i.aoifile;
end

% the name of the mat file with 'r' is the base storage area name
% (/ftp/pub) with the station appended, and then the root name of
% the aoifile. E.g. /ftp/pub/argus00/collects/987654321.mat
dots = find(aoi=='.');
file = ['/ftp/pub/' p.station '/collects/' aoi(1:dots(end-1))];

load(file);

% 

%
% $Id: PIXFindCollect.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXFindCollect.m,v $
% Revision 1.3  1904/03/26 11:20:02  stanley
% auto insert keywords
%
%
%key pixel pixelExtract 
%comment  Load the collection structure for a stack 
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

