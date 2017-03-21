function varargout = runupPIXArray(varargin)

%RUNUPPIXARRAY designs a pixel array for measuring runup in video
%
%USAGE: [x,y,z] = runupPIXArray(xshore,xdune,y0,zlevel,rot)
%   or: runupStruct = runupPIXArray(xyArray,X,Y,Z,tide,rot)
%
%INPUTS: (first uasge)
%  xshore - cross-shore shoreline position
%  xdune - cross-shore dune position
%  y0 - alongshore shoreline position
%  zlevel - (optional, default = 0) sea level in local coords.
%  rot - (optional, default = 0) rotations in degrees to rotate runup array
%  NOTE: if you include a rotation you must also specify a zlevel 
%OUTPUTS: (first usage)
%  x y and z of runup array 
%
%INPUTS: (second uasge)
%  xyArray - Nx2 matrix of locations 
%  Z - matrix of elevations of gridded beach survey data
%  X,Y - vectors or matrices of describing horizontal locations
%    of gridded survey data (see 'Z' above)
%  tide - vector of vertical range of runup expected 
%    (i.e. 'tide = [maxTideElev minTideElev]')
%  rot - (optional, default = 0) vector of rotations, in degrees, 
%    to rotate each runup array
%OUTPUTS: (second usage)
%  runupStruct - 1xN structure array     
%    XYZ - matrix of 3 columns of the x y an z location of each pixel 
%      in the individual runup array.  The z is mapped to the elevations
%      in 'Z' (above) between the min and max of 'tide' (above)

% set constants
dx = 0.25;
xoffset = 30;
lx = 50;

if nargout == 3  % First Usage Option
  % handle inputs
  switch length(varargin)
    case 3
      xshore = varargin{1};
      xdune = varargin{2};
      y0 = varargin{3};
      zlevel = 0;
      rot = 0;
    case 4
      xshore = varargin{1};
      xdune = varargin{2};
      y0 = varargin{3};
      zlevel = varargin{4};
      rot = 0;
    case 5
      xshore = varargin{1};
      xdune = varargin{2};
      y0 = varargin{3};
      zlevel = varargin{4};
      rot = varargin{5};
    otherwise  
      error('Incorrect number of inputs. Look at the help for help.')
  end
  
  % make unrotated runup line
  x = [xdune:dx:(xshore+xoffset)]';
  y = repmat(y0,size(x));
  varargout{3} = repmat(zlevel,size(x));

  % rotate x and y and translate to y0, x = 0
  rot = deg2rad(rot);
  R = [cos(rot) -sin(rot); sin(rot) cos(rot)];
  X = (R*[x'-xshore; y'-y0])';
  x = X(:,1)+xshore;
  y = X(:,2)+y0;
  varargout(1:2) = {x y}; % assign output
  
elseif nargout == 1  % Now for Second Usage Option 
  % deal out inputs
  switch length(varargin)
    case 5
      xyArray = varargin{1};
      X = varargin{2};
      Y = varargin{3};
      Z = varargin{4};
      tide = varargin{5};
      rot = zeros(size(xyArray,1));
    case 6
      xyArray = varargin{1};
      X = varargin{2};
      Y = varargin{3};
      Z = varargin{4};
      tide = varargin{5};
      rot = varargin{6};
    otherwise
  end
    
  % interp z along runup line, then find z between max(tide) and min(tide) 
  NInst = size(xyArray,1); 
  rot = deg2rad(rot);
  for j = 1:NInst
    fprintf(1,'   ...working on point at x = %3.1f y = %3.1f \r',xyArray(j,:))
    xR = [-lx:dx:lx];
    yR = zeros(size(xR));
    R = [cos(rot(j)) -sin(rot(j)); sin(rot(j)) cos(rot(j))];
    XYR = (R*[xR; yR])' + repmat(xyArray(j,:),length(xR),1);
    %[zR, rmse, bi, ci, sk, Ni] = loessInterp([X(:) Y(:)],Z(:),1,XYR,[100 100]);
    zR = interp2(X,Y,Z,XYR(:,1),XYR(:,2));
    tInd = find(zR <= max(tide) & zR >= min(tide));
    runupStruct(j).XYZ = [XYR(tInd,:) zR(tInd)];
  end
  varargout{1} = runupStruct; % assign output
else
  error('Incorrect number of outputs. Look at the help for help.')
end

%
% $Id: runupPIXArray.m,v 1.1 2005/04/05 21:02:35 stanley Exp $
%
% $Log: runupPIXArray.m,v $
% Revision 1.1  2005/04/05 21:02:35  stanley
% Initial revision
%
%
%key pixel applications
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

