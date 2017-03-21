function g = PIXGetGeometry( epoch, camID )

% g = PIXGetGeometry( epoch, camID )
%
%   get camera geometry at time 'epoch' for camera with id camID.
%
%  this is the argusDB version. the matlab database version will be
%  different.

% get whichever exists
%g = DBGetCurrentGeom( camID, epoch, 'autook' );
% NO. Rely on user setting global
g = DBGetCurrentGeom( camID, epoch );
return;

% 

%
% $Id: PIXGetGeometry.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXGetGeometry.m,v $
% Revision 1.3  2008/04/09 14:27:47  stanley
% removed autook flag -- bad juju.
%
% Revision 1.2  1904/08/17 16:34:04  stanley
% new
%
%
%key internal pixel pixelDesign 
%comment  argusDB version to get camera geometry 
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

