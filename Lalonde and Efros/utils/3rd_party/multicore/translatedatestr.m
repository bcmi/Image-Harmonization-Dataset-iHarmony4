function dateStr = translatedatestr(dateStr)
%TRANSLATEDATESTR  Translate german date string to english version.
%		STR = TRANSLATEDATESTR(STR) converts a german date string like 
%		  13-Mär-2006 15:55:00
%		to the english version
%		  13-Mar-2006 15:55:00.
%		This is needed on some systems if function DIR returns german date
%		strings.
%
%		Markus Buehren
%
%		See also DATENUM2.

dateStr = strrep(dateStr, 'Mrz', 'Mar');
dateStr = strrep(dateStr, 'Mär', 'Mar');
dateStr = strrep(dateStr, 'Mai', 'May');
dateStr = strrep(dateStr, 'Okt', 'Oct');
dateStr = strrep(dateStr, 'Dez', 'Dec');
