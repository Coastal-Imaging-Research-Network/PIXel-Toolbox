function r = PIXBuildPoly( r )

%  function r = PIXBuildPoly(r)
%
%   take the information in the poly struct (an array of structures of polygons)
%   and camera data (geoms) and create a distributed set of UV pixels for each 
%   camera that covers that xyz space.
%
%
%  ignore the code behind the curtain, this is the great and powerful
%  wizard of ... walls? 
%  
%  BuildPoly now looks for a special function name in each polygon, and
%  assumes one polygon for simplicity. It calls that function to do the
%  building of the polygon and bookkeeping. that function must accept the
%  r struct and return the r struct.
%
%  I have high hopes for a generic solution, so I left the code in this
%  function that may become the generic solution. 

%  method:
%
%       for each camera in 'sortBy':
%           for each poly:
%               calculate polyUV = findUV(polyxyz);
%               calculate all UV from roipoly;
%               back calculate xy(z=0) from all UV.
%               floor the xy.
%               eliminate dupes xy from master list per camera. (setxor)
%               then eliminate UV.
%               add xyz/UV/names to camera list

%%
% make a list of array position to camera numbers.
%

if( length(r.poly) == 0 )
    return;
end

for pind = 1:length(r.poly)
    in = r.poly(pind); % instrument
    % split type into type and function
    cind = find(in.type == ':');
    if( isempty(cind) ) 
        pfunc = 'PIXBuildPolyDefault';
        warning( 'no function for polygon, using default' );
    else
        pfunc = in.type(cind+1:end);
        in.type = in.type(1:cind-1);
   end
    disp( ['evaluating poly with function ' pfunc ' for ' in.type ' of ' in.name ] );
    eval( [ 'r = ' pfunc '( r, in );' ] );
end;

return;



%% %%%%%%%%%%%%%%%%%%%% old code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = PIXBuildPolyDefault( r, in )

cvec = [r.cams(:).cameraNumber];

% a place to keep sampled XYZ;
mypoly.XYZ = [ -10000 -10000 -10000 ];
mypoly.cam = [ -1 ];

%%
% foreach camera, in sorted order
for cam = r.sortBy
    
    % find the index in the r structure
    cind = find(cvec==cam);
    
    %%
    % find the vertices in UV space in this camera
    [pU, pV] = findUV( ...
        r.geoms(cind).m, ...
        [in.c.x1;r.in.c.y1;in.c.z]);
    % distort them
    %%% NO NO NO. Distort will fail on vertices well off the edge of
    %%% the image, makeing goofy looking polygons. we'll make do with
    %%% the approximate locations.
    %[pU, pV] = distort( pU, pV, r.cams(cind), r.ip(cind) );
    
    % build a grid of the UV for the camera size
    u = 1:r.ip(cind).width;
    v = 1:r.ip(cind).height;
    [uu,vv] = meshgrid( u, v );
    Ifoo = zeros(size(uu));
    
    % now use roipoly to let matlab find the UV for all pixels in
    % our polygon that are in the image
    BW = roipoly( Ifoo, pU, pV );
    myU = uu(BW);
    myV = vv(BW);
    
    % back propogate the xyz at canonical z=0
    % undistort
    [umyU, umyV] = undistort( myU, myV, r.cams(cind), r.ip(cind));
    umyU = myU; umyV = myV;
    myXYZ = findXYZ( r.geoms(cind).m, ...
        [umyU umyV], ...
        0, 3 );
    
    % convert to int for comparisons.
    bin = 1;
    imyXYZ = floor(myXYZ./bin)*bin;
    
    % now, find elements of this list that are not in the list of ones
    %  I've already done. I only want IB.
    [CC, IA, IB] = setxor( mypoly.XYZ, imyXYZ, 'rows' );
    myU = myU(IB);
    myV = myV(IB);
    myXYZ = myXYZ(IB,:);
    imyXYZ = imyXYZ(IB,:);
    
    % add these to the camera list of UVXYZ, names, flags, etc.
    r.cams(cind).Uraw = [r.cams(cind).Uraw; myU];
    r.cams(cind).Vraw  = [r.cams(cind).Vraw; myV];
    r.cams(cind).U    = [r.cams(cind).U;    myU];
    r.cams(cind).V    = [r.cams(cind).V;    myV];
    
    clear foo;
    [foo{1:length(myV)}] = deal(in.c.name);
    r.cams(cind).names    = {r.cams(cind).names{:} foo{:}};
    r.cams(cind).namesRaw = {r.cams(cind).namesRaw{:} foo{:}};
    
    [foo{1:length(myV)}] = deal(in.c.type);
    r.cams(cind).types = {r.cams(cind).types{:} foo{:}};
    
    r.cams(cind).XYZ = [r.cams(cind).XYZ; myXYZ];
    
    r.cams(cind).flags = [r.cams(cind).flags in.flags*ones(size(myU))'];
    
    % bookkeeping in R all done. save my current XYZ
    mypoly.XYZ = [mypoly.XYZ; imyXYZ];
    mypoly.cam = [mypoly.cam; cam*ones(size(myU))];
    
    %next poly, please.
    
end

return;


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

