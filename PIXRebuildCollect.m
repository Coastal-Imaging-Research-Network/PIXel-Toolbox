function r = PIXRebuildCollect( rin )

% r = PIXRebuildCollect( r-in )
%
%  ReBuild a pixel collection based on the input 'r-in' array
%
%  if you want a different epoch time, modify r-in.epoch
%
% returns a whole slew of stuff. everything that went in comes out.
% plus full arrays of raw U, V; x,y,z; camera id, cam#, instrument name.
%

r = rin;

% prepare for sorting by fov or camera order. build 'sortBy' matrix if not there
if( isempty(r.sortBy) )

	% no sortBy specified, use default cameraNumber order ascending
	[junk,sortBy] = sort([r.cams(:).cameraNumber]);

elseif ischar(r.sortBy)

	% should be 'fov'
	if( strcmp( r.sortBy, 'fov') )
		% first get fov's from camera geometry
		[fovs,sortBy] = sort([r.geoms(:).fov]);
	elseif( strcmp( r.sortBy, 'none') )
        % use default camera number order, but later do not remove
        % pixels that have been assigned to a camera
        [junk,sortBy] = sort([r.cams(:).cameraNumber]);
	else
		error(['unknown sortBy string: ' r.sortBy]);
	end;

else
	% sort by given cameraNumber order.Convert sortBy from cameraNumber to
	% index in cams and geoms array number.
	% sorry Rob, I have no vectorized solution to this
	for i = 1:length(r.sortBy),

		findCam = find( [r.cams(:).cameraNumber] == r.sortBy(i) );
		if isempty(findCam),
			error(['There is no camera number ' num2str(r.sortBy(i))]);
		end;
		if( length(findCam) > 1 )
			error(['There is more than one camera ' num2str(r.sortBy(i)) ]);
		end;
		sortBy(i) = findCam;
	end;
end;

camNums = [r.cams(:).cameraNumber];
disp(['Sorted camera number order: ' num2str(camNums(sortBy)) ]);

% sortBy is now an array of indexes into r.cams and r.geoms.

% all  my 'x' are in one 'basket'. Find UV's. One set for each camera
% using the sortBy sort order, determine U and V, and delete from the x,y,z
% arrays when that is found in a camera view

% sort out interp and uninterp'd points to make processing easier
% helps with simply appending interpd UVs to rest.
interp = find(bitand(PIXInterpUV,r.f) ~= 0);
uninterp = find(bitand(PIXInterpUV,r.f) == 0);
r.origx = r.origx([uninterp interp]); 
r.origy = r.origy([uninterp interp]);
r.origz = r.origz([uninterp interp]); 
r.names = r.names([uninterp interp]);
r.types = r.types([uninterp interp]);
r.f = r.f([uninterp interp]);

% first, temp copies of x,y,z,names
tempx = r.origx; tempy = r.origy; tempz = r.origz; 
tempNames = r.names; tempf = r.f; tempTypes = r.types;

% now step through the sortBy array as index into cams and geoms
for i = sortBy,

	% clear output U and V arrays
	outU = []; outV = []; outNames = {}; outTypes = {};

	% get U and V for available xyz
	[rawUs,rawVs] = findUV( r.geoms(i).m, [tempx;tempy;tempz]' );

	% distort the UVs 
	[dU,dV] = distort( rawUs, rawVs, r.cams(i), r.ip(i) );

	% then find out which ones are in the image
	isIn = inImage( dU, dV, r.ip(i).width, r.ip(i).height, 'full' ); 

    %% added by delft to deal with backprojection from points behind
    % the camera. 20140827

    % applying another filter, based on the horizon (take points below it)
    % it uses find_horizon
    % special case, if we don't know fov, don't do this. UAV driven
    if( r.geoms(i).fov > 0 )
        daz = -r.geoms(i).fov:(r.geoms(i).fov/10):r.geoms(i).fov;
        az = r.geoms(i).azimuth + daz;
        [xH, yH, zH] = PIXFindHorizon(r.cams(i).x, r.cams(i).y, r.cams(i).z, az(:));
        [uH, vH] = findUV(r.geoms(i).m, [xH, yH, zH]);
        [uH, vH] = distort(uH, vH, r.cams(i), r.ip(i));
        pHor = polyfit(uH,vH,1);
        funcZeroHor = -dV + pHor(1)*dU + pHor(2);
        isIn = isIn & funcZeroHor<0;
    end

    %% end delft

	in = find(isIn==1);   % in applies to tempx/tempy/tempz, too.
	if( length(in) < 1 )
		continue;
	end;
	rawUs = dU(in); rawVs = dV(in); rawNames = tempNames(in); 
	rawFlags = tempf(in); rawTypes = tempTypes(in);
	rawX = tempx(in); rawY = tempy(in); rawZ = tempz(in);
    
    % keep track of real raw X/Y/Z, don't throw away by backcalc, etc
    %  those calcs will overwrite "raw" data
    realRawX = rawX; realRawY = rawY; realRawZ = rawZ;

	% 20100911 -- add high-density unique pixel code
	% PIXUniqueOnly -- collect only one of each pixel requested
	%  for vbar or patch
	% 20120130 -- remove unique only! Moved to PIXFindUVByName
	%  doing it here lost XY ordering, which screws up runup lines
	%isUnique = find(bitand(rawFlags,PIXUniqueOnly));
	%isNormal = find(bitand(rawFlags,PIXUniqueOnly)==0);
	%UrawUs = fix(rawUs(isUnique)); UrawVs = fix(rawVs(isUnique));
	%Uflags = rawFlags(isUnique); Utypes = rawTypes(isUnique);
	%Ux = rawX(isUnique); Uy = rawY(isUnique); Uz = rawZ(isUnique);
	%Unames = rawNames(isUnique);

	%uUV = UrawUs * 10000 + UrawVs;
	%[uUV,uind,junk] = unique( uUV );
	%UrawUs = fix(uUV/10000); UrawVs = fix(mod(uUV,10000));
	%Uflags = Uflags(uind); Utypes = Utypes(uind); 
	%Ux = Ux(uind); Uy = Uy(uind); Uz = Uz(uind);
	%Unames = Unames(uind);

	% remove all uniqueonly points from others, add back unique
	%rawUs = rawUs(isNormal); rawUs = [rawUs; UrawUs];
	%rawVs = rawVs(isNormal); rawVs = [rawVs; UrawVs];
	%rawFlags = rawFlags(isNormal); rawFlags = [rawFlags Uflags];
	%rawTypes = rawTypes(isNormal); rawTypes = [rawTypes Utypes];
	%rawNames = rawNames(isNormal); rawNames = [rawNames Unames];
	%rawX = rawX(isNormal); rawX = [rawX Ux];
	%rawY = rawY(isNormal); rawY = [rawY Uy];
	%rawZ = rawZ(isNormal); rawZ = [rawZ Uz];

	% back calculate the x,y for each unfixed point
	% must distort UV, then fix, then undistort, THEN findXYZ,
	% since the "fix" operation in 'm' is on the distorted UV.
	unfix = find(bitand(rawFlags,PIXFixedXY) == 0);
	if (length(unfix) > 0 )
		%[distU, distV] = distort( rawUs(unfix), ...
		%		rawVs(unfix), r.cams(i), r.ip(i) );
		distU = fix(rawUs(unfix)); distV = fix(rawVs(unfix));
		[undistU, undistV] = undistort( distU, distV, ...
						r.cams(i), r.ip(i) );
		unfixedXYZ = findXYZ( r.geoms(i).m, ...
			[undistU undistV], ...
			rawZ(unfix)', 3 );
		rawX(unfix) = unfixedXYZ(:,1);
		rawY(unfix) = unfixedXYZ(:,2);
	end;

	%% now distort the UV's we have. // already done, js 20090617
	%rawUs, rawVs] = distort( rawUs, rawVs, r.cams(i), r.ip(i) );

	% refind who is interped and who idn't.
	interp = find(bitand(PIXInterpUV,rawFlags) ~= 0);
	uninterp = find(bitand(PIXInterpUV,rawFlags) == 0);

	% ok, rawUs, rawVs, and rawNames are u,v and names in an image. 
	% handle uninterp first, then we'll append interpd at end.
	if (length(uninterp) > 0 )
		outU = fix(rawUs(uninterp));
		outV = fix(rawVs(uninterp));
		outNames = rawNames(uninterp);
		outTypes = rawTypes(uninterp);
	end;
	if (length(interp) > 0)
		% get remainders of real U and V points
		tempUinterp = rawUs(interp); tempVinterp = rawVs(interp);
		tuRem = tempUinterp - fix(tempUinterp);
		tvRem = tempVinterp - fix(tempVinterp);
		tuoff = ones(size(tempUinterp)); 
		tvoff = ones(size(tempVinterp));
		tuoff(find(tuRem < .5)) = -1;
		tvoff(find(tvRem < .5)) = -1;
		iUi = fix(tempUinterp)'; iUoff = (iUi' + tuoff)';
		outU = [outU',iUi,iUi,iUoff,iUoff]';
		iVi = fix(tempVinterp)'; iVoff = (iVi' + tvoff)';
		outV = [outV',iVi,iVoff,iVi,iVoff]';

		% at this point, I should do an inImage pass to remove interp'd
		% points that will be outside the image, but I'll let 'm' take
		% care of it. 

		% handle expanding name array
		outNames = { outNames{:} ...
			rawNames{interp} rawNames{interp} ...
			rawNames{interp} rawNames{interp} };
		outTypes = { outTypes{:} ...
			rawTypes{interp} rawTypes{interp} ...
			rawTypes{interp} rawTypes{interp} };

	end;

	% save raw (floating) U's and V's. 	
	r.cams(i).Uraw = rawUs;
	r.cams(i).Vraw = rawVs;
	r.cams(i).namesRaw = rawNames;
	r.cams(i).flags = rawFlags;

	r.cams(i).U = outU;
	r.cams(i).V = outV;
	r.cams(i).names = outNames;
	r.cams(i).types = outTypes;

	r.cams(i).XYZ = [rawX; rawY; rawZ]';
    r.cams(i).rawXYZ = [realRawX; realRawY; realRawZ]';

	% now, keep xyz and names of only those that haven't been used
    % BUT only if r.sortBy is not 'none'
    if( ~strcmp( r.sortBy, 'none' ) ) 
        out = find(isIn==0);
        tempx = tempx(out); tempy = tempy(out); tempz = tempz(out); 
        tempNames = tempNames(out); tempf = tempf(out);
        tempTypes = tempTypes(out);
    end

	% ran out of points, did I? all done!
	if isempty(tempx) 
		break; %% can't just return, have to check poly! return;
	end;
end;

if ~isempty(tempx)
	disp(['I have points left after assigning them to all cameras.']);
end;

% new processing, "poly". A sheet or patch. triggered by having a non-empty
% member of r called 'poly'. all info is already in 'r'.

if isfield( r, 'poly' )
    r = PIXBuildPoly( r );
end

% 

%
% $Id: PIXRebuildCollect.m 265 2017-03-20 23:04:23Z stanley $
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

