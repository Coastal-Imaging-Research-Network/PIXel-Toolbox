function r = PIXCreateR( pid, epoch, tide, sortBy )

% r = PIXCreateR( pid, epoch, tide, sortby )
%
%  Build a pixel collection for the package with id pid.
%
%   epoch is the epoch time for collection
%   tide is the tide level
%   sortby is an  optional array of how to sort cams
%     special value: fov means use narrowest camera first.
%         or 'none', means no sort, keep all pixels.
%
% returns a whole slew of stuff. everything that went in comes out.
% plus full arrays of raw U, V; x,y,z; camera id, cam#, instrument name.
%

global PIXStation;

% deal with 'epoch'. If string, convert to number. if array, convert to epoch. 
if ischar( epoch )
	epoch = str2num(epoch);
elseif (length(epoch) == 6)
	epoch = matlab2Epoch(epoch);
elseif (length(epoch) == 1)
	% do nothing
else
	% error in time input
	error('Unrecognized input epoch time format');
end

if (nargin == 3 )
	sortBy = 'fov';
end

% following check removed for CIRN sanitization
% check for collect already scheduled at this time for this station
% prevent overwriting active collection with this new one.
%testFile = [ '/ftp/pub/' PIXStation '/collects/' num2str(epoch) '.mat' ];
%if( exist(testFile) ) 
%	error(['Collect already scheduled for ' num2str(epoch) ' at ' PIXStation ]);
%end

% pass inputs back to output
r.pid = pid;
r.epoch = epoch;
r.tide = tide;
r.sortBy = sortBy;
r.station = PIXStation;
r.poly = [];

% now, get package
package = PIXGetPackageByID( pid );
if isempty(package)
	error(['no package with id ' num2str(id) ]);
end

if isempty(package.instrumentList)
	error(['No instruments in package' package.name]);
end

% muck up an xyz list, with names.
r.origx=[]; r.origy=[]; r.origz=[]; r.names={}; r.f = []; r.types = {};

% for each instrument --
il = package.instrumentList;
for i = 1:length(il),
    in = PIXGetInstrumentByID( il(i) );
    disp(['Expanding instrument ' num2str(i) ': ' ...
        char(package.instrumentNames(i))]);
    
    % and then each coord in an instrument
    for j = 1:length(in.c),
        
        if (in.c(j).dx == -1) % I am a POLYGON, can't build yet.
            if( isempty(r.poly) )
                r.poly=in;   % save entire instrument definition
            else
                r.poly(length(r.poly)+1) = in;
            end
        else
            
            [ix,iy,iz] = PIXExpandCoord(in.c(j));
            if (~bitand(in.flags,PIXFixedZ))
                iz = tide * ones( size(ix) );
            end
            
            r.origx = [r.origx ix];
            r.origy = [r.origy iy];
            r.origz = [r.origz iz];
            % save flags for use later for interp/fixedXY
            r.f = [r.f ones(size(ix))*in.flags];
            
            namesLength = length(r.names);
            [r.names{namesLength+1:namesLength+length(ix)}] = ...
                deal(char(package.instrumentNames{i}));
            namesLength = length(r.types);
            [r.types{namesLength+1:namesLength+length(ix)}] = ...
                deal(in.type);
        end;
    end;
    
end

return;


%
% $Id: PIXCreateR.m 265 2017-03-20 23:04:23Z stanley $
%
% $Log: PIXBuildCollect.m,v $
% Revision 1.11  2016/02/11 22:08:33  stanley
% poly added
%
% Revision 1.10  2006/07/28 18:30:11  stanley
% removed numeric code from exist
%
% Revision 1.9  2005/01/27 23:44:05  stanley
% changed to two part operation -- get xyzs, then REbuild collect.
%
% Revision 1.8  1904/08/11 12:14:35  stanley
% ticked Z into findXYZ
%
%
%key pixel pixelDesign 
%comment  % Builds collection for a package at a time  
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

