function [iid, pid] = PIXCreatePoly( name, XYZ, func )

% function [iid, pid] = PIXCreatePoly( name, XYZ, func );
%
%  create a new instrument of type 'poly', defined by the vertices listed
%  in XYZ. This is a "wall" or "sheet" or "patch" consisting of all pixels
%  in the region bounded by your polygon in xyz space. 
%
%  this is a specialized instrument and thus may consist of only one
%  polygon per instrument and the flags will be set appropriately for you.
% 
%  'name' is the name of the instrument. 'wall1'. 'patch500'. 
%
%  XYZ is an Nx3 array of vertices for a 3D polygon in real space in argus
%  coordinates. YOU are responsible for it being planar if you want it that
%  way. At build time, each vertice is converted to UV and used with
%  roipoly to get a filled polygon of UV points to sample.
%
%  'func' is the name of the function used to expand this poly into UV
%  for each camera. User must create a special function -- see
%  makePixelWallWEWAB in /home/ruby/matlab/CIL/pixel/apps for an example.
%
%  returns: iid is the instrument ID that is created, pid is the id of the
%  coordinate structure that contains this polygon. (You can ignore pid, it
%  is used in PIXBuildCollect and as a unique ID in the the pixel data. It
%  will be retrieved when it is needed to build this instrument.
%
%  Note: this function differs from PIXAddMatrix in that you are going to
%  get every UV in the bounded area, whereas a matrix with tiny dx,dy may
%  miss some or may horribly oversample the area. We also bypass all the
%  early collection building steps and do not generate UV until very late
%  in the process. 

% first, need a new instrument
flags = 0;  % not sure now, see what we need later
% kludge alert! this poly instrument hides the function in the type.
% PIXBuildCollect will unpack this into the poly struct PIXRebuildCollect knows
% about 
if nargin < 3
    type = 'poly';
else
    type = ['poly:' func];
end;
iid = PIXCreateInstrument( name, type, flags );  % hardwired type 'poly'

% now split up the XYZ so PIXAddPoints can handle it. 
x = XYZ(:,1);
y = XYZ(:,2);
z = XYZ(:,3);

% ok, call PIXAddPoints. PIXAddPoints knows about a poly through number of
% parameters. one extra
pid = PIXAddPoints( iid, x, y, z, name, 1 );

% all done here.

%
% $Id: PIXCreatePoly.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXCreatePoly.m,v $
% Revision 1.1  2016/02/11 22:10:02  stanley
% Initial revision
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

