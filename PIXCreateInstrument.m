function id = PIXCreateInstrument( name, type, flags )

% id = PIXCreateInstrument( name, type, flags )
%
%  creates a new instrument with no coordinates with name 'name' and 
%  type 'type' and returns the ID for that instrument. name and type
%  are both strings.
% 
%  everything after type is optional.
%
%  The flag "PIXFixedZ" means that the user supplied Z coordinate
%  should be used instead of the tidal elevation when this
%  instrument is mapped into pixels with PIXBuildCollection. 
%
%  The flag "PIXFixedXY" locks the X and Y values stored in the
%  collection array. Normally, the X and Y values are shifted to
%  represent the actual pixel location sent to be collected.
%
%  The flag "PIXInterpUV" enables pixel interpolation. It does this
%  by sampling the four pixels surrounding the actual XYZ location,
%  which allows an interpolation of the intensity at the real point.
%  This flag implies PIXFixedXY -- original x and y MUST be known if
%  PIXInterp is going to work.
%
%  The flag "PIXDeBayerStack" indicates that the stack collection
%  should operate in internal deBayering mode. I.e., the collection
%  program will create the intensity from the four nearest pixels
%  instead of just the specific pixel. (ArgusIII only).
%
%  The flag PIXUniqueOnly tells the system to use only the unique 
%  pixels from an instrument and calculate the XY values for those
%  unique pixels. So, e.g., PIXAddLine with a very small dx will creat
%  hundreds of XYZ locations, but we'll throw away all but a small set
%  that corresponds to the unique pixels. Note that this is different
%  from the normal unique operation in that all the extra XYZs are 
%  discarded here and kept for normal ops.
%
%  Flags are set by adding the correct nmemonics. E.g.,
%
%  id = PIXCreateInstrument( 'FOBS1', 'OBS', PIXFixedZ+PIXFixedXY );
%
%  see also: PIXAddLine, PIXAddPoints, PIXAddMatrix. You better see those,
%  those are how you define the components of an instrument.
%

global PIXPackages;
global PIXInstruments;
global PIXModified;

% save the info on when created
i.whenCreated = epochtime;

% check to see if "fixedZ" is included.
if nargin == 3
	% MUST not allow changes to x,y for interp'd UV's.
	if( bitand(flags,PIXInterpUV) )
		flags = bitor(flags,PIXFixedXY);
	end
	i.flags = flags;
else
	i.flags = 0;
end;

% get an id
if isempty(PIXInstruments)
	id = 1;
else
	id = max([PIXInstruments(:).id]) + 1; 
end;
i.id = id;

% stuff away the name and type
i.name = name;
i.type = type;

% a place for coord id's to be stored
i.coords = [];

% and save it
if isempty(PIXInstruments)
	PIXInstruments = i;
else
	PIXInstruments(length(PIXInstruments)+1) = i;
end;

PIXModified = 1;

% 

%
% $Id: PIXCreateInstrument.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXCreateInstrument.m,v $
% Revision 1.5  2010/09/11 14:11:53  stanley
% added info about uniqueonly
%
% Revision 1.4  2008/06/10 19:17:20  stanley
% added help for PIXDeBayerStack
%
% Revision 1.3  1904/03/26 11:20:02  stanley
% auto insert keywords
%
%
%key pixel pixelDesign 
%comment  Create new empty instrument 
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

