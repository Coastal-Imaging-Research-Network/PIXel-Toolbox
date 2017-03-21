function miniR = loadDataAboutStack( fn )

% function miniR = loadDataAboutStack( filename )
%
%   retrieve the appropriate bits of the 'r' struct involved with the stack
%   given by 'filename', when 'filename' is the name of the .mat file in
%   the 'cx' data areas. 
%
%   appropriate bits are:
%       r.sortBy  -- sort order in pixel build
%       r.cams    -- array of camera data about cameras
%       r.ip      -- IP data for cameras
%       r.geoms   -- geometry data used to build stack
%       r.currentGeoms -- current geometries for those cameras
%
%  r.cams will have the names, UV, etc removed to save space. if you want
%  it all, load the 'r' file.


if ~ischar(fn)
    error('filename must be string');
    return;
end

%%

% get filename bits
pn = parseFilename( fn );

% ask the database about this stack! shortcut to finding 'r'
sd = DBGetTableEntry('stack', 'epoch', pn.time );

if isempty(sd)
    error(['I cannot find stack data from database for ' pn.time ' at ' ...
        pn.station ]);
    return;
end

%%

% get the r.
rname = ['/ftp/pub/' sd(1).station '/collects/' ...
        num2str(sd(1).aoiEpoch) '.mat' ];
newR = load(rname);


%% 

% pass on the old bits to the new
miniR.sortBy = newR.r.sortBy;
cams = rmfield( newR.r.cams, {'Uraw','Vraw','namesRaw','flags','U','V','names','types','XYZ'} );
miniR.cams = cams;
miniR.ip = newR.r.ip;
miniR.geoms = newR.r.geoms;

%clear newR;

%%

% find the new geometeries for the cameras.
for ii = 1:length(miniR.geoms)
    
    ng = DBGetCurrentGeom( miniR.cams(ii).id, pn.time );  % auto ok
    if ~isempty(ng)
        miniR.currentGeoms(ii) = ng;
    else
        miniR.currentGeoms(ii) = [];
    end
    
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

