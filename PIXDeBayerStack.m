function val = PIXDeBayerStack()

% helper function, returns 8, which is flag to indicate debayer on the
% fly for stacks.
%
% NOTICE: This flag applies to ALL the pixels created by the
% PIXScheduleColletIII call. It does nothing to the pixel values, but it
% does create a warning file reporting that the user has set this flag.
% That is because the action of this flag is entirely within the
% ArgusIII collection program. 
%
%  It has no effect for non-ArgusIII systems, and no effect for systems
%  without Bayer encoded raw data collection.
%
% PLEASE remind the person setting up the collection on the remote Argus
% station that you want this option, since he may forget to look for the
% warning file and space out totally.


disp('NOTE: DeBayer stack applies to all pixels in this collection!');

val = 8;

% 

%
% $Id: PIXDeBayerStack.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXDeBayerStack.m,v $
% Revision 1.3  2008/04/17 21:10:50  stanley
% added help warnings
%
% Revision 1.2  2008/04/17 20:32:13  stanley
% added warning message
%
% Revision 1.1  2008/04/17 20:31:12  stanley
% Initial revision
%
%
%key pixel pixelDesign 
%comment  helper function, returns 8, flag to indicate debayer stack
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

