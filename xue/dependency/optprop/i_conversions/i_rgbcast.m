function rgb=i_rgbcast(rgb, Dst)
%I_RGBCAST Convert RGB from one numeric represenation to another.
%   ARGB=RGB2RGB(RGB,CASTTO) with size(RGB)=[M 3]
%   returns matrix ARGB with same size.
%
%   CASTTO is any one of 'double', 'single' 'uint16' or 'uint8', converts
%   the image to CASTTO representation.
%
%   Example:
%      Convert limits of an uint8 image to double
%         rgb=rgbcast(uint8([255 255 255;0 0 0]), 'double')
%
%   See also: RGBCAST

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_rgbcast.m 24 2007-01-28 23:20:35Z jerkerw $

	switch class(rgb)
		case {'double', 'single'}
			switch Dst
				case {'double', 'single'}
				case 'uint16'
					rgb=uint16(round(65535*rgb));
				case 'uint8'
					rgb=uint8(round(255*rgb));
				otherwise
					error(illpar('Illegal destination class'));
				end
		case 'uint16'
			switch Dst
				case 'double'
					rgb=double(rgb)/65535;
				case 'single'
					rgb=single(rgb)/65535;
				case 'uint16'
				case 'uint8'
					rgb=rgbcast(rgbcast(rgb,'double'),'uint8');
				otherwise
					error(illpar('Illegal destination class'));
				end
		case 'uint8'
			switch Dst
				case 'double'
					rgb=double(rgb)/255;
				case 'single'
					rgb=single(rgb)/255;
				case 'uint16'
					rgb=257*uint16(rgb);
				case 'uint8'
				otherwise
					error(illpar('Illegal destination class'))
				end
		otherwise
			error(illpar('Illegal source class'));
		end
