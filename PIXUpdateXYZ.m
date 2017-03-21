function r = PIXUpdateXYZ( rin, epoch, tide )

%  r = PIXUpdateXYZ( rin, epoch, tide ) updates the UV to XYZ 
%   mapping for the 'r' structure passed in, based on the geometries 
%   for the specified epoch. I.e., it recalculates the XYZ (real world)
%   locations for each of the rawUV values in the r.cams struct.
%
%  Remember, this updates ONLY the XYZ found in the cams element
%  of the r struct, not the top level 'orig' xyz's. It also updates
%  the geometry entries on the r struct.  Because of that, this function
%  will fail if the cameras change.
%
%  The 'tide' value is optional. If present, the basis value for the
%  Z (in the underlying findXYZ call) will be the specified tide level
%  for those pixels without PIXFixedZ set, or the original Z otherwise.
%

% start by copying in to out.
r = rin;
r.epoch = epoch;

% enforce a warning: fixed Z pixels don't get changed if new tide value!
if( nargin == 3 ) 
	fixed = bitand( r.f, PIXFixedZ );
	if( ~isempty(fixed) ) 
		warning( 'There are fixed-Z pixels in this R file. They will not change Z values!' );
	end
end;
% get a local copy of the cameras, we'll compare later
c = DBGetCamerasByStation( r.station, epoch );
if(isempty(c))
	error(['No cameras at station ' r.station ' at that epoch']);
	return;
end

% get new geometries. test for camera going away!
for i=1:size(r.cams)

	me = find( [c(:).cameraNumber] == r.cams(i).cameraNumber );
	if( ~strcmp( c(me).id, r.cams(i).id ) )
		error( ['Camera ' num2str(r.cams(i).cameraNumber) ' changed!'] );
		return;
	end
	ng = DBGetCurrentGeom( r.cams(i).id, epoch, 'autook' );
	if( isempty(ng) ) 
		error( ['No current geometry for camera ' num2str(r.cams(i).cameraNumber) ' at that epoch']);
	return;
	end;

	newgeoms(i) = ng(1);

end

r.geoms = newgeoms;

% now loop through cameras, find new ZYX
for i=1:size(r.cams)

	% nothing to do if there are no XYZs for this cam
	if isempty(r.cams(i).XYZ) continue; end;

	% start with original Z's
	z = r.cams(i).XYZ(:,3);

	% now deal with updating unfixed Z's
	if(nargin == 3)
		unfixed = ~bitand(r.cams(i).flags, PIXFixedZ);
		z(unfixed) = tide;
	end

	% let's do it!
	UV = [r.cams(i).Uraw';r.cams(i).Vraw']';
	UV = undistort( UV, r.cams(i), r.ip );
	r.cams(i).XYZ = findXYZ( r.geoms(i).m, UV, z, 3 );

	% that's all, isn't it?

end

%
% $Id: PIXUpdateXYZ.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXUpdateXYZ.m,v $
% Revision 1.2  2008/09/18 23:55:09  stanley
% don't do anything for empty XYZ -- no pix in that cam to fix
%
% Revision 1.1  2005/06/06 21:02:12  stanley
% Initial revision
%
%
%key pixel 
%comment  rebuild pixel lists
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

