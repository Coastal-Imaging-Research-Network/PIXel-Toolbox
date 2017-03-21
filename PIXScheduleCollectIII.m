function err = PIXScheduleCollectIII( cams, samples, hertz, r )

% PIXScheduleCollectIII -- schedule a pixel sampling for Argus III
% 
%   err = PIXScheduleCollectIII( CAMS, SAMPLES, HERTZ, COLLECT ) builds the 
%   files necessary to run an argus station stack collection and returns 
%   an error flag if it fails. CAMS is a scalar or array of camera 
%   numbers to include in this schedule. SAMPLES is the number of samples 
%   (lines) to collect in this collection. HERTZ is how often to collect. 
%   HERTZ must be based on a 2HZ basis. COLLECT is a 
%   collection structure as produced by PIXBuildCollect.
%
%   The actual product from this routine will be documented later.
%

global PIXStation;

if isempty(cams)
	error('no cameras to schedule');
end

if (hertz > 2)
	error('too fast, max is 2 Hz');
end

err = 0;

% hertz must be 2/n, where n is 1 .. whatever. n will be skip+1
inc = fix(2/hertz);
run = samples / (2/inc);
disp(['This collection will run ' num2str(run) ' seconds (' ...
	num2str(run/60,4) ' minutes)']);

% create a place to put things -- my own temp
[status,msg] = mkdir('temp');

% sched file is commands to take data
if( sum( bitget( uint8(r.f(:)), 4 ) ) ) 
	fname = ['temp' filesep num2str(r.epoch) '.WARNING' ];
	[mfid,message] = fopen( fname, 'w' );
	fprintf(mfid, 'WARNING: This user wants THIS STACK DeBayered on the fly.\n');
	fclose(mfid);
end

fname = ['temp' filesep num2str(r.epoch) '.sched'];
[mfid,message] = fopen( fname, 'w' );

% foreach camera scheduled, build a UV list based on the epoch and camera
for thisCam = cams,

	% find the index in the collect array
	thisI = find( [r.cams(:).cameraNumber] == thisCam );
	if isempty(thisI)
		error(['Camera ' num2str(thisCam) ...
			' is not in the collect struct!']);
	elseif length(thisI) ~= 1
		error(['There are more than one camera ' num2str(thisCam) ...
			' in the collect struct!']);
	end

	disp(['Building camera number ' num2str(thisCam)]);

	myU = r.cams(thisI).U; myV = r.cams(thisI).V;
	if ~isempty(myU) & ~isempty(myV)
	    % if I want to uniq these, here is the place. not now, maybe later
	    fname = [num2str(r.epoch) '.c' num2str(thisCam) '.pix'];
	    [fid,message] = fopen( ['temp' filesep fname], 'w' );
	    if fid == -1
		    error(['Cannot open file ' fname ' for output: ' message]);
	    end

            % ok, let's unique this, rely on retrieving by UV later
	    zz = unique( myU * 10000 + myV );
	    myU = floor(zz/10000); myV = mod(zz,10000);

	    myUV = [myU';myV'];
	    fprintf( fid, '%d %d\n', myUV );
	    fclose(fid);

	    % fill in sched file for m
	    fprintf( mfid, [...
			    num2str(thisCam) ...
			    ' ' ...
			    'add - ' ...
			    num2str(samples) ...
			    ' ' ...
			    num2str(inc-1) ...
			    ' 30 ' ...
			    num2str(length(myUV)) ...
			    ' ' ...
			    fname '\n' ]); 
	end;
end

fclose(mfid);

% now save the collect struct for later use. 
disp('Saving collect structure');
fname = ['temp' filesep num2str(r.epoch) '.mat'];
save( fname, 'r' );

% 

%
% $Id: PIXScheduleCollectIII.m 21 2016-02-11 22:21:37Z  $
%
% $Log: PIXScheduleCollectIII.m,v $
% Revision 1.2  2008/04/17 20:55:50  stanley
% added text for '8' in flags -- DeBayer stack on the fly
%
% Revision 1.1  2004/08/18 00:59:51  stanley
% Initial revision
%
%
%key pixel pixelDesign 
%comment  Schedule a pixel sampling for Argus III  
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

