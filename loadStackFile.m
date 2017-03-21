function [p, epoch, MSC, data] = loadStackFile( filename, UV );

% loadStackFile -- load the data from a stack file
% 
%   This is the new lower level to loadStack, and actually takes all
%   the same parameters as loadStack (except 'clearCache'). You will
%   probably want to call loadStack instead of this routine.
%   
%   It's very slow, so do it once.
%

% filetype -- I want to read some floats, must tell matlab the format
filetype = 'l';

if nargin == 2
	allData = 0;
	if ischar(UV)
		% all I want is info
	elseif size(UV,1) ~= 2
		if size(UV,2) ~= 2
			error( 'Wrong dimension on UV array, must be 2xN or Nx2' );
		end;
		UV = UV';
	end
else
	allData = 1;
	UV = [];
end

% try opening directly
[fid,message] = fopen(filename,'r', filetype);
if fid == -1
	% no, try FTPpath'ing the name
	if isempty(findstr('/', filename) )
		tfile = FTPPath(filename);
		fid = fopen(tfile,'r', filetype);
	end
	if fid == -1
		% can't find it anywhere I know how!
		error(['Cannot find ' filename ': ' message]);
	end
	% found it, change name I look for
	filename = tfile;
end
fclose(fid);

% look for .Z on the end -- compressed file
if upper(filename(length(filename))) == 'Z',
	i = findstr(filename,filesep);
	if isempty(i)
		basename = filename;
	else
		basename = filename(max(i)+1:end);
	end
	basename = basename(1:max(find(basename=='.')-1));
	%js% disp(['base name of ' filename ' is ' basename]);

	% this can take time, warn the luser
	%disp( ['Decompressing ' filename ]);

	% do NOT copy if the file is already in /tmp! At least, as far
	% as we can tell. And do not remove it!
	if isunix
		l = min(findstr('/tmp/', filename));
		if isempty(l) | (l ~= 1),
			isInTmp = 0;
			eval( ['! cp ' filename ' /tmp']);
		else
			isInTmp = 1;
		end
		if( filename(end) == 'Z' )
			eval( ['! compress -df /tmp/' basename '.Z']);
        else
            %eval( ['!ls /tmp/13*'] );
            xfn = ['/tmp/' basename '.gz'];
            %disp( ['decompressing ' xfn ] );
			%eval( ['! gunzip -f /tmp/' basename '.gz']);
			eval( ['! gunzip -f ' xfn]);
		end
		filename = ['/tmp/' basename];
		[fid,message] = fopen( filename, 'r', filetype );
		if ~isInTmp
            % unlink it now and rely on it being open through the rest
            % of the reading process so it goes away as soon as I'm done
            % with it.
			eval( ['! (sleep 5;  rm -f ' filename ' ) & ' ] );
		end
	end
	if ispc
            %Try user argusTemp
            tempDir=argusOpt('argusTemp');
            if isempty(tempDir)  %If there's no tempDir in userInfo
        	areBase=strrep(which('argusInit.m'),'argusInit.m','');
        	tempDir=[areBase filesep 'argusTemp'];
        	if ~exist(tempDir,'dir')  %And it doesn't exist, make it
                    mkdir(areBase,'argusTemp');
        	end
            end
            if ~isempty(tempDir) & ~exist(tempDir,'dir')
		%if there is, but it doesn't exist, create it
        	[tempStr,tempRest]=strtok(fliplr(tempDir),filesep);
        	mkdir(fliplr(tempRest),fliplr(tempStr));
            end
            if ~exist([tempDir filesep basename],'file')
        	l = min(findstr(tempDir, filename));
        	if isempty(l) | (l ~= 1),
                    isInTmp = 0;
    %                 dos(['copy ' FTPPath(filename) filesep filename ' ' = tempDir]);
                    dos(['copy ' filename ' ' tempDir]);
        	else
                    isInTmp = 1;
        	end
        	%Store current path
        	oldPath=pwd;
        	%Switch path
        	cd(tempDir);
        	%Rename filename to temp.Z
        	dos(['ren ' basename '.Z temp.Z']);
        	%Uncompress
        	dos( [which('uncomp.exe') ' temp.Z']);
        	%Rename temp. to basename
        	dos(['ren Temp ' basename]);
        	cd(oldPath);
            end
            filename = [tempDir filesep basename];
            [fid,message] = fopen( filename, 'r', filetype );
	end

else
	[fid,message] = fopen( filename, 'r', filetype );
end

if fid == -1 
	error(['Cannot open ' filename ': ' message]);
end

%% now let's deal with the new stack format, triggered by a
%  filename that ends in 'cil' instead of 'ras'. 
if( strcmp( filename(end-2:end), 'cil' ) )
    % gots us a new stack file. load it, return
    fclose(fid);
    [p, epoch, MSC, data] = newLoadStackFile( filename );
    return;
end

%% now let's deal with the new netcdf stack format, triggered by a
%  filename that ends in 'nc' instead of 'ras'. 
if( strcmp( filename(end-2:end), '.nc' ) )
    % gots us a new stack file. load it, return
    fclose(fid);
    [p, epoch, MSC, data] = ncLoadStackFile( filename );
    return;
end

%% proceed with rasterfile decoding!
% rasterfile header
[a,count] = fread( fid, 32, 'uint8' );
if( count < 8 ) 
	error(['This file is too short! ' filename]);
end;

p.magic  = b2i(a(1:4));
p.width  = b2i(a(5:8)); 
p.height = b2i(a(9:12)); 
maplen   = b2i(a(29:32));

if p.magic ~= 1504078485,
	error(['This is not a stack, bad magic: ' num2str(p.magic) ' ' filename ] );
end

%disp(['This stack has ' num2str(p.height-8) ' lines of ' ...
%	num2str(p.width-8) ' pixels.' ]);

% get rid of the colormap, not needed.
[map,count] = fread( fid, maplen, 'uchar' );

% starting my personal header
a = fread( fid, p.width, 'uint8' );
p.when = b2i(swab(a(1:4)));
p.camera = a(5); gain = a(6); offset = a(7); p.version = a(8);
xl = a(9:length(a));

%js% disp(['This version ' num2str(p.version) ' stack started at ' ...
%js% 	epoch2GMTString(p.when) ' (' num2str(p.when) ')']);

%if p.version <3
%	error( 'I don''t know how to handle this version of stack' );
%end

% -------------
a = fread( fid, p.width, 'uint8' );
p.increment = a(5); p.isColor = a(6);
p.pixels = b2i(swab(a(1:4)));
if( p.version < 8 ) 
	p.pixels = p.width - 8;
end
p.lines = bitor( bitshift(a(8),8), a(7));
xh = a(9:length(a));

%disp(['This stack has ' num2str(p.lines) ' lines at increment ' ...
%	num2str(p.increment)]);
%if p.isColor 
%	error('I don''t know how to do color stacks yet. Sorry.');
%end

% -------------
where = fread( fid, 8, 'uint8' ); 
a = fread( fid, p.width-8, 'uint8' );
p.where = char(cellstr(char(where)'));

yl = a;

%disp(['This stack was taken at ' p.where ] );

% ------------- 
a = fread( fid, p.width, 'uint8' );
yh = a(9:length(a));

% -------------
ust1 = fread( fid, 4, 'uint8' );
ust2 = fread( fid, 4, 'uint8' );
ust1 = b2i(ust1);
ust2 = b2i(ust2);
p.ust = ((ust1*2^32)+ust2)/1000000000;
a = fread( fid, p.width-8, 'uchar' );
p.aoifile = char(a(1:min(find(a==0))-1))';

%disp( ['The start UST was ' num2str(p.ust) ' and aoifile ' p.aoifile '.']);

% -----------------
tv = fread(fid, 8, 'uint8');
p.syncTime = b2i(tv(1:4)) + b2i(tv(5:8))/1000000;
	
a = fread( fid, p.width-8, 'uint8' );

%disp(['The sync time for this stack was ' num2str(p.syncTime) ]);

% -- empty two lines in my header.
a = fread( fid, p.width, 'uchar' );
a = fread( fid, p.width, 'uchar' );

% pack U and V back together
p.U = bitor( bitshift(xh,8), xl );
p.V = bitor( bitshift(yh,8), yl );

% heuristic for testing color. Check if isColor isn't set
% this is a fix for at least some Duck stacks that are color but
% don't say so internally.
if (p.isColor == 0) 
	tuv = p.U*10000 + p.V; 
	ntuv = fix(length(tuv)/3);
	% color has the odd property that UV is triplacated.
	if ((tuv(1:ntuv) == tuv(ntuv+1:2*ntuv)) ...
	  & (tuv(2*ntuv+1:end) == tuv(1:ntuv) ) )
		disp('fixing color flag for this stack');
		p.isColor = 1;
	end
end

% version 8 adds packed data at the end of the stack row. deal with 
% this now. First, find packed data indices
pdi = find( p.U > 61439 );
pdU = p.U(pdi); pdV = p.V(pdi);
% then 'not packed' indices, return only UV of unpacked
pdni = find( p.U < 61440 );
p.U = p.U(pdni); p.V = p.V(pdni);

% now return the U (packed code) for the packed
pdui = find( pdV == 0 );
p.packedCode = pdU(pdui);

% if all I want is the info from the stack, here we are.
if (ischar(UV)) & (UV == 'info')
    fclose(fid);
	return;
end;

% ok, getting data is next. Sadly, I screwed up and allowed RebuildCollect
% to generate outside-the-image UV's, which get corrupted into valid pixels
% in hotm etc... Must NOW get the camera info so I can detect off the edge
% right and bottom (left and top are negative, easy!) Then return a flag
% (column of -1's) to signal invalid request UV. Sigh. 

cam = DBGetCameraByImage( filename );
% if no cam data found, assume umax and vmax are for Scorpion 
if isempty(cam) 
	umax = 1280; vmax = 960;
else
	% look for IP data for width and height
	ip = DBGetTableEntry('IP','id', cam.IPID );
	umax = ip.width; vmax = ip.height;
end

% figure out from p.U/p.V and UV which columns of data and what order to return.
% frack! this code belongs in loadStack ONLY! we get called from loadStack to
% load FULL file into cache, and only then suck out the right pixels! Snark!
baddies = [];
if allData == 0
	order = [];
	oob = 0;    % out of bounds counter
	nf = 0;     % not found counter
	for j = 1:size(UV,2)
		myU = UV(1,j);
		myV = UV(2,j);
		% check for out of bounds
		if( myU < 1 || myU > umax || myV < 1 || myV > vmax )
			baddies = [baddies j];
			order = [order 1]; % placeholder
			oob = oob + 1;
			continue;
		end;
		% now check existance and find column
		x = find(p.U == myU & p.V == myV);
		if isempty(x)
			% not found! stupid user!
			baddies = [baddies j];
			order = [order 1];  % still placeholder
			nf = nf + 1;
		else
			% ?? I had [order x'] in the code, commented out
			% [order x(1)]. Latter seems most correct. Why did
			% I have the other? I don't know!
			order = [order x(1)];
			%order = [order x'];
		end;
	end
	p.order = order';
	if ~isempty(baddies)
		p.order(baddies) = -1;
	end;
else
	order = 1:length(p.U);
	p.order = order';
end

% now warn user about bad values. Just warning here. Later we replace
% bad columns with -1.
if( length(baddies) > 0 ) 
	warning(['Errors in UV request to loadStack: %d out-of-bounds, ' ...
		 '%d not found.\nMissing data flagged as -1. Use ' ...
		 'PIXCleanup to clean up data.'], ...
		 oob, nf );
end;	

%disp(['Order determined for ' num2str(length(order)) ' pixels.']);

% whew, I have decoded all the header data, now let's do image data

% first, determine real time at system boot (ust==0). That's start time minus
% UST at start. 
timeAtBoot = p.syncTime - p.ust;

% problem -- ust stored in lines can rollover. must add back the time
%  lost when this happens. How do we know? p.ust is greater than 2^32/1000.
timeAtBoot = timeAtBoot + fix(p.ust/(2^32/1000))*(2^32/1000);

%disp('Allocating empty arrays, this may take time');
epoch = ones(1,p.lines); MSC = []; 
data = uint8(ones(p.lines, length(order)));
%disp('Empty data arrays allocated, time to cook...');

firstcount = 0;
for line = 1:p.lines,

	% get UST and MSC from line
	[aa, count] = fread( fid, 8, 'uint8' );
	if( count == 0 ) 
		disp(['truncated stack: ' filename ', got only ' num2str(line-1) ' lines']);
		data = data(1:line-1,:);
		epoch = epoch(1:line-1);
		break;
	end

	a(1) = b2i(aa(1:4)); a(2) = b2i(aa(5:8));
	if( p.version == 0 ) % wow, old DIPIX!
		a(1) = b2i(swab(aa(1:4))); a(2) = b2i(swab(aa(5:8)));
	end
	% and then data
	[d,count] = fread( fid, p.pixels, 'uchar=>uint8' );
    if firstcount == 0
        firstcount = count;
    end
    if count ~= firstcount
		disp(['truncated midline stack: ' filename ', got only ' num2str(line-1) ' lines']);
		data = data(1:line-1,:);
		epoch = epoch(1:line-1);
		break;
    end

	ust = a(1)/1000 + timeAtBoot;
	epoch(line) = ust;
	if( p.version == 0 ) 
		epoch(line) = a(1);
	end;

	if( p.version > 7 ) 
		a = fread( fid, 2, 'float32' );
		MSC = [ MSC a ];
	else
		MSC(line) = a(2);
	end;

	data(line,:) = d(order)';

	% now cleanup missing/oob data
	if ~isempty(baddies)
		data(line,baddies) = -1;
	end
	%if mod(line,100) == 0
	%	fprintf( 1, '%d       \r', line );
	%end
end

fclose(fid);

% kludge hack to fix IF we take data during a UST rollover -- time in epoch
% will drop back 2^32/1000 seconds! Find any points where time is less than
% epoch(1) and add 2^32/1000!

goo = find(epoch<epoch(1));
if ~isempty( goo ) && (p.version<9)
	disp('UST rollover during collection, fixing.');
	epoch(goo) = epoch(goo) + (2^32)/1000;
end

% version 6 -- change MSC to gain and shutter. Must have camera info to
% know which camera is being used -- DX700 or SX900.

if( p.version == 6 )

	DBTestConnect;
	c = DBGetCamerasByStation(p.where, p.when);
	me = find( [c(:).cameraNumber] == p.camera );
	if( isempty(me) ) 
		warning('cannot find camera info for this camera, no gain');
		warning('assuming I am an DX700');
		me = 1:5; c = 'DX700';
	end

	gain = floor(MSC./65536); % high side of MSC
	gain = (gain-2048)/10;    % convert to dB

	shutter = bitand(MSC, 65535);  % low side of MSC
	%shutter = sonyShutterToTime( shutter, c(me) );

	MSC = [gain;shutter];

end

function out = swab( in )

% SWAB -- swap bytes to change from little endian to big and vice versa.
%
%   out = swab( in ) returns the swapped in to out.

if size(in,1) ~= 4
	error( 'Wrong dimensions for input' );
end

le = [ 4 3 2 1 ];
out(:,:) = in(le,:);

function i = b2i( b )

% b2i  -- convert four bytes to an integer
%

i = 	bitor( bitshift(b(1,:), 24), bitor( bitshift(b(2,:), 16), bitor( bitshift(b(3,:), 8), b(4,:))));

% SIGNED INTEGER! Frack!
if( i > bitshift(128, 24) ) 
	i = i - bitshift( 128, 25 );
end
% 

%
% $Id: loadStackFile.m 21 2016-02-11 22:21:37Z  $
%
% $Log: loadStackFile.m,v $
% Revision 1.13  2016/02/11 22:04:41  stanley
% manage temp file length of life, add netcdf, better error on truncated stack
%
% Revision 1.12  2012/12/12 23:46:21  stanley
% added new stack format in .cil files
%
% Revision 1.11  2012/10/26 21:18:59  stanley
% added filename to error messages. necessary for automated stuff
%
% Revision 1.10  2011/04/15 21:55:56  stanley
% force compress to uncompress the file in /tmp
%
% Revision 1.9  2010/02/25 20:50:38  stanley
% fix for bug in hotm, invalid UV pixels.
%
% Revision 1.8  2008/08/05 00:09:30  stanley
% added processing for .gz files -- for Pedro
%
% Revision 1.7  2005/06/06 21:00:24  stanley
% updated for latest AIII stacks!
%
% Revision 1.6  2004/10/20 21:06:00  stanley
% fix mime code error
%
% Revision 1.5  2004/10/13 19:44:38  stanley
% added ispc section for working on PCs
%
% Revision 1.4  2004/09/02 01:12:17  stanley
% changed data fread to uint8=>uint8, hope is faster
%
% Revision 1.3  2004/09/02 01:05:16  stanley
% moved uint8 cast from d(order) to fread -- faster
%
% Revision 1.2  2004/09/02 00:45:49  stanley
% changed data to uint8
%
% Revision 1.1  1904/08/17  16:33:52  stanley
% converted from SCCS
%
%
%key pixelExtract 
%comment  Load the data from a stack file 
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

