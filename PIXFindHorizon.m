function [xh,yh,zh] = PIXFindHorizon(xo,yo,zo,az);

% 
%function [xh,yh,zh] = PIXFindHorizon(xo,yo,zo,az);
% find the coordinates of the horizon
% 
% [xh,yh,zh] = find_horizon(xo,yo,zo,az);
%
% Input
% xo,yo coordinates of observation point
%  zo, elevation above sealevel (meters) of observation point
%  az, azimuthal angles to horizon (az = 0) along y=const.
%
% Output
% xh, yh, zh, coodinates of horizon (z relative to sealevel!)
% only need to know the radius of the earth: 6378140 (m)

% first find distances centered on xo,yo
% earth's radius 
R = 6378140; % meters

% ERROR IN THESE EQUATIONS OCURRED prior to 8 Sept. 2000
% HERE ARE CORRECT EQUATIONS
% horizontal coordinate of horizon
ds = sqrt(zo*(zo+2*R))*R/(zo+R);
% distance below observation point
% SKIP GEOMETRIC COMPUTATION: dz = zo*(zo+2*R)/(zo+R);
% USE "Astro-Navigation by Calculator" by Levison, 1984
dip = (0.0293 * pi/180)*sqrt(zo); % VALID for zo in METERS
dz = ds*dip;

% elevation to horizon
zh = zo-dz + 0*az;
yh = ds*cos(az) + yo;
xh = ds*sin(az) + xo;


%
% $Id: PIXFindHorizon.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXFindHorizon.m,v $
% Revision 1.1  2014/09/14 16:14:38  stanley
% Initial revision
%
%
%key 
%comment  
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

