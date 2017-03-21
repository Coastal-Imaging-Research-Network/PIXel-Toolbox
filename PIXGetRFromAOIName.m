function r = PIXGetRFromAOIName( station, aoifile )

% PIXGetRFromAOIName  -- get the schedule collection data that produced
%    the specified AOIFile.
%
%    r = PIXGetRFromAOIName( station, aoifile ) returns the 'r' structure
%    for the stack schedules at the station which resulted in the aoifile
%    (pixel list) of that name. This function looks in the common data 
%    storage area for this information.
%
%    'station' is either the station name (e.g. 'argus00') or the name
%    of the stack file from which parseFilename can extract the station
%    name.
%
%    aoifile is the name of the aoifile used to create the stack,
%    including the camera identifier and .pix extension. This info
%    is included in the params returned by loadStack. OR is the epoch
%    time of the AOIFile as stored in the stack database under aoiEpoch.
%

global PGRFAN;

if ~isfield( PGRFAN, 'rname')
    PGRFAN.rname = '';
end
if ~isfield( PGRFAN, 'r')
    PGRFAN.r = [];
end

if ~ischar( station ) 
	error('Invalid format for station');
end

if ischar( aoifile )
    % ok
elseif isnumeric( aoifile )
        aoifile = [ num2str(aoifile) '.' ];
else
	error('Invalid format for aoifile');
end

% look for file name instead of station name
if length(station) > 10
	p = parseFilename(station);
	station = p.station;
end

% the name of the mat file with 'r' is the base storage area name
% (/ftp/pub) with the station appended, and then the root name of
% the aoifile. E.g. /ftp/pub/argus00/collects/987654321.mat
%
%  more cleanup, for cassy, some others, no ../. Let's just take 
%  first part of basename of pixfile. Should be ok
base = basename(aoifile);
base = base(1:min(find(base=='.')));
if(isempty(base)) 
	base = basename(aoifile);
end
file = ['/ftp/pub/' station '/collects/' base 'mat'];

if strcmp(file,PGRFAN.rname)
    r = PGRFAN.r;
else
    load(file);
    % now convert to new DB format
    r = DBUpdateR(r);
    PGRFAN.rname = file;
    PGRFAN.r = r;
end


% 

%
% $Id: PIXGetRFromAOIName.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXGetRFromAOIName.m,v $
% Revision 1.5  2013/11/08 20:15:34  stanley
% added cache of r, numeric epoch input
%
% Revision 1.4  2010/02/25 20:53:38  stanley
% add call to update R from old format (DB) to new
%
% Revision 1.3  2008/08/05 00:08:56  stanley
% cleanup up handling aoifile name, strip dirs and c's
%
% Revision 1.2  1904/03/26 11:20:04  stanley
% auto insert keywords
%
%
%key pixel pixelExtract 
%comment  Gets schedule collection data for AOIFile 
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

