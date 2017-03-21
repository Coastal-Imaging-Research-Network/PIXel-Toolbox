function r = PIXPrepareR( rin )

% r = PIXPrepareR( r-in )
%
% gets all the geometries, camera, IP data, then calls PIXParameterizeR
% to put it into r finally. This is stuff moved from PIXRebuildCollect
% normally flagged by 'keepOldGeoms'. Assume we always want new geoms.
%
% returns a whole slew of stuff. everything that went in comes out.
% plus full arrays of raw U, V; x,y,z; camera id, cam#, instrument name.
%

r = rin;

% must get camera and geometry data. link out to a replacable routine
%  so different DB routines can be used

% get camera data for cameras at time at station
cams = PIXGetCameraData( r.station, r.epoch );

% i need ip data for distort later
s = DBGetStationsByName( r.station, r.epoch );
if isempty(s)
    error( ['I do not know station ' r.station]);
end

for i = 1:length(cams),
    g = PIXGetGeometry( r.epoch, cams(i).id );
    if isempty(g)
        warning(['No geometry for camera ' cams(i).id]);
    else
        geoms(i) = g;
    end
    
    ip = DBGetTableEntry( 'IP', 'id', cams(i).IPID );
    if isempty(ip)
        error( ['No IP at station ' r.station]);
    end
    ip = DBLegacyIP( ip, cams(i) );
    ips(i) = ip(1);
    % horrid cluge, for Meg ...
    % if ip is indef, then must look up geom image
    if strcmp( ips(i).id, 'INDEF' )
        ips(i) = DBGetIPFromImage( geoms(i).imagePath );
    end
end

% last step -- insert cams, geoms, ip into r
r = PIXParameterizeR( r, cams, geoms, ips );


return;

%
% $Id: PIXPrepareR.m 265 2017-03-20 23:04:23Z stanley $
%
% $Log: PIXRebuildCollect.m,v $
% Revision 1.13  2016/02/11 22:14:19  stanley
% needed ip for call to distort
%
% Revision 1.12  2014/09/14 16:16:27  stanley
% added horizon call for delft zandmotor back projection problem
%
% Revision 1.11  2014/08/27 18:38:28  stanley
% added rebuild with old geometries, handle orderby none, added poly
%
% Revision 1.10  2012/10/26 21:16:33  stanley
% see comment about removing unique here
%
% Revision 1.9  2011/05/10 01:20:39  stanley
% added legacy IP call
%
% Revision 1.8  2011/04/15 21:57:37  stanley
% uniqueonly
%
% Revision 1.7  2010/02/25 20:52:51  stanley
% do not remove geoms data from original, do remove ip
%
% Revision 1.6  2009/06/18 17:55:44  stanley
% caught error rmfielding fields not present in new R structs
%
% Revision 1.5  2009/06/17 21:32:22  stanley
% distorted UV before inImage test. Stupid monkey.
%
% Revision 1.4  2008/11/13 00:00:08  stanley
% Fixed to update for new structs, IP defs, etc.
%
% Revision 1.3  2008/11/12 23:51:02  stanley
% fixed help
%
% Revision 1.2  2006/07/28 19:07:36  stanley
% resolve INDEF ip
%
% Revision 1.1  2005/01/27 23:44:28  stanley
% Initial revision
%
% Revision 1.8  1904/08/11 12:14:35  stanley
% ticked Z into findXYZ
%
%
%key pixel pixelDesign
%comment  % ReBuilds collection for a package at a time
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

