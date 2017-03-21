function [UV, rawUV, rawXYZ, XYZ] = PIXFindUVByName( cam, r, name )

% PIXFindUVByName -- retrieve UV coordinates from the collection structure
%   by INSTRUMENT name. Optionally, get raw UV and X/Y/Z coords.
%
%   UV = PIXFindUVByName( CAM, r, name ) retrieves the UV coords from the 
%   collection structure 'r' that have an instrument name 'name'. CAM is
%   either the integer camera number or the name of the stack file in Argus
%   format (from which the camera number will be extracted with parseFilename.)
%
%   [UV, rawUV] = PIXFindUVByName( ... ) retrieves both the collected UV 
%   coords and the raw UV coords for the collection defined in 'r'. 
%
%   [UV, rawUV, rawXYZ] = PIXFindUVByName( ... ) also returns the X,Y, and Z
%   coordinates that resulted in the rawUV pixel coordinates.
%
%   [UV, rawUV, rawXYZ, XYZ] = PIXFindUVByName( ... ) also returns the X,Y, 
%   and Z coordinates that resulted in the UV pixel coordinates.
%
%   NOTE: if the 'interp' flag for the collection has been set, the UV
%   array will contain four times as many pixels as the rawUV array. The
%   first N/4 UV pixels will be the the 'fix' versions of rawUV. The 
%   remaining 3N/4 UV points will be the surrounding UV pixels which will 
%   allow interpolation of pixel values. IF you want to use PIXUnInterp,
%   you MUST retrieve the rawUV values. 
%
%   Another note: if the "unique only" flag has been set for pixels with
%   this name, you will get back a processed list of UV that are the
%   unique set. E.g., if you created an instrument with two XY points
%   that mapped to the same UV, you will get back ONE UV and ONE XYZ.
%

if nargout > 3
	XYZ = [];
end

if nargout > 2
	rawXYZ = [];
end

if nargout > 1
	rawUV = [];
end

if nargout > 0
	UV = [];
end


if ischar(cam)
	p = parseFilename(cam);
	cam = p.camera;
end

ind = find( [r.cams(:).cameraNumber] == cam );
if isempty(ind)
	error(['Camera number ' num2str(cam) ' not found in struct']);
end

i = strmatch( name, r.cams(ind).names, 'exact' );
if isempty(i)
	return;  % no UV, return empty set
end
UV = [r.cams(ind).U(i) r.cams(ind).V(i)];

% if we have set UniqueOnly, we want only the UNIQUE UV pixels,
% but we can't just unique, we must return them to the original
% order. That's how the instrument was created, the user might
%  have created them in this order for a reason. Like a runup line.

if( bitand(r.cams(ind).flags(i(1)), PIXUniqueOnly))
	% make a sortable uniquable UV list
	UVs = 10000 * UV(:,1) + UV(:,2);
	[UVu, UVi, UVj] = unique( UVs );
	% UVu now has the unique UV pairs. UVi is the index they came from
	% in the list based on names. We want them in original order. So
	% we sort UVi to get them in the original order limited to the
	% unique ones.
	UVi = sort(UVi);
	UV = UV(UVi,:);
end

if nargout >= 4
	% count on previous strmatch still valid
	XYZ = r.cams(ind).XYZ(i,:);
	if( bitand(r.cams(ind).flags(i(1)), PIXUniqueOnly))
		XYZ = XYZ(UVi,:);
	end;
end

if nargout >= 2
	i = strmatch( name, r.cams(ind).namesRaw, 'exact' );
	rawUV = [r.cams(ind).Uraw(i) r.cams(ind).Vraw(i)];
end

if nargout > 2
	% count on previous strmatch still valid
    if(isfield(r.cams(ind), 'rawXYZ') )
        rawXYZ = r.cams(ind).rawXYZ(i,:);
    else    
%        warning('rawXYZ not available for this stack, XYZ returned instead.');
        rawXYZ = r.cams(ind).XYZ(i,:);
    end
    
end

% 

%
% $Id: PIXFindUVByName.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXFindUVByName.m,v $
% Revision 1.6  2016/02/11 22:11:31  stanley
% added raw XYZ processing
%
% Revision 1.5  2012/01/31 23:16:28  stanley
% added setting null responses, return if empty find
%
% Revision 1.3  1904/03/26 11:20:03  stanley
% auto insert keywords
%
%
%key pixel pixelExtract 
%comment  Find UV coords for a named instrument 
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

