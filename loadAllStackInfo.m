function [allStackNames, r, allPs] = loadAllStackInfo(stackName)
%
%   [allStackNames, r, allPs] = loadAllStackInfo(stackName)
%
% Given a single stack name, returns the names of that any
% any other associated stackNames (array), as well as an
% array of the params, allPs, for each stackName and
% the r structure that was used in the collect generation
% Both allStackNames and allPs will be arrays of structures
% with one element for each valid stack.
%
%  if allPs is omitted as a destination, you will save a lot of
%   time because we won't have to open every stack to get that data
%  the only stack uncompressed/loaded will be the first  
%
%  NOTE: if you are getting failures with "no such field", notice that
%  the order of the returned parameters has CHANGED. This is so that
%  allPs can be omitted. 

%clear allPs r allStackNames

% commented out to see if it is causing failure in processing
%recordPath;

try 
    myPs = loadStack(stackName, 'info');   % at least some success?
    r = PIXGetRFromAOIName(stackName, myPs.aoifile);
    allStackNames(1) = {stackName};
    clist = [r.cams(:).cameraNumber];
    otherCams = clist(find(myPs.camera ~= clist));
    for i = 1: length(otherCams)
	    junk = findArgusImages(num2str(strtok(stackName,('.'))), myPs.where, ...
		    otherCams(i), 'stack', 'ras*', 5);
	    if ~isempty(junk)
		    allStackNames(end+1) = {junk};
	    end
    end
    if( nargout > 2 ) % load all params
	allPs = myPs;
	for i = 2 : length(allStackNames)
		allPs(i) = loadStack( allStackNames{i}, 'info' );
	end
    end
catch
	l = lasterror;
	disp(l.message);
end
%
% $Id: loadAllStackInfo.m 21 2016-02-11 22:21:37Z  $
%
% $Log: loadAllStackInfo.m,v $
% Revision 1.7  2016/02/11 22:03:12  stanley
% filtered otherCams
%
% Revision 1.6  2012/10/26 21:17:43  stanley
% get when from stackName, use only 'ras' (not new) stacks
%
% Revision 1.5  2011/04/15 21:53:57  stanley
% fix a cell reference
%
% Revision 1.4  2010/02/25 17:30:44  stanley
% changed order of return so allPs can be omitted
% this WAS loadAllStackInfoRob and then loadAllStackInfoRs
%
% Revision 1.3  2008/08/05 00:10:05  stanley
% removed clear statement -- matlab barfs on that!
%
% Revision 1.2  2005/06/06 22:48:21  stanley
% fixed for >2 stacks at the same time
%
% Revision 1.1  2004/08/19 21:54:24  stanley
% Initial revision
%
%
%key bathy pixelExtract 
%comment  Loads sibling stacks and loads info 
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

