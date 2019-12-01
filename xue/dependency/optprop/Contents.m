% optprop
% Version 2.1.4  28 March 2007
%
% Color space conversions.
%   dp2xy            - Calculate chromaticity from dominating wavelength and spectral purity.
%   lab2disp         - Convert from LAB to display RGB.
%   lab2lab          - Adapt LAB to another illuminant/observer.
%   lab2lch          - Convert from Lab to LCH.
%   lab2luv          - Convert from Lab to Luv.
%   lab2rgb          - Convert from Lab to RGB.
%   lab2xy           - Convert from Lab to chromaticity coordinates x and y.
%   lab2xyz          - Convert from Lab to XYZ.
%   lch2lab          - Convert from LCh to Lab.
%   luv2lab          - Convert from LUV to LAB.
%   luv2xyz          - Convert from Luv to XYZ.
%   luvp2xyz         - Convert from Lu'v' to XYZ.
%   rgb2disp         - Convert from RGB to display RGB space.
%   rgb2lab          - Convert from RGB to Lab.
%   rgb2rgb          - Convert from one RGB space into another.
%   rgb2xyz          - Convert from RGB to XYZ.
%   rgb2ycc          - Converts from RGB to YCbCr.
%   rgbcast          - Convert RGB from one numeric represenation to another.
%   roo2brightness   - Convert spectrum to ISO Brightness.
%   roo2cct          - Calculate correlated color temperature.
%   roo2disp         - Convert from spectra to DisplayRGB.
%   roo2lab          - Convert from spectra to LAB.
%   roo2prop         - Convert from spectra to various optical properties.
%   roo2rgb          - Convert from spectra to RGB.
%   roo2xy           - Convert from spectra to chromaticity x and y.
%   roo2xyz          - Convert from spectra to XYZ.
%   srgbgamma        - Apply the special SRGB gamma function to RGB data.
%   xy2cct           - Calculate correlated color temperature.
%   xy2dp            - Calculate dominating wavelength and exitation purity.
%   xy2rgb           - Convert from XY to visually pleasing RGB.
%   xy2xyz           - Convert from xy to XYZ with maximum Y.
%   xyy2xyz          - Converts from xyY to XYZ.
%   xyz2disp         - Convert from XYZ to RGB.
%   xyz2lab          - Convert from XYZ to LAB.
%   xyz2luv          - Convert from XYZ to LUV.
%   xyz2luvp         - Convert from XYZ to LU'V'.
%   xyz2prop         - Convert from tristimulus XYZ to various optical properties.
%   xyz2rgb          - Convert from XYZ to RGB.
%   xyz2rxryrz       - Convert from XYZ to RxRyRz.
%   xyz2wtj          - Convert from XYZ to CIE Whiteness, T(Red Tint) and J (Yellowness).
%   xyz2xy           - Convert from XYZ to chromaticity xy.
%   xyz2xyy          - Convert from tristimulus XYZ to chromaticity xy and Y
%   xyz2xyz          - Adapt XYZ to another illuminant/observer.
%   ycc2rgb          - Convert from YCbCr to RGB.
% Low level color space conversions.
%   i_dp2xy          - Calculate chromaticity from dominating wavelength and spectral purity.
%   i_lab2disp       - Convert from LAB to display RGB.
%   i_lab2lab        - Adapt LAB to another illuminant/observer.
%   i_lab2lch        - Convert from Lab to LCH.
%   i_lab2luv        - Convert from Lab to Luv.
%   i_lab2rgb        - Convert from Lab to RGB.
%   i_lab2xy         - Convert from Lab to chromaticity coordinates x and y.
%   i_lab2xyz        - Convert from Lab to XYZ.
%   i_lch2lab        - Convert from LCh to Lab.
%   i_luv2lab        - Convert from LUV to LAB.
%   i_luv2xyz        - Convert from Luv to XYZ.
%   i_luvp2xyz       - Convert from Lu'v' to XYZ.
%   i_rgb2disp       - Convert from RGB to display RGB space.
%   i_rgb2lab        - Convert from RGB to Lab.
%   i_rgb2rgb        - Convert from one RGB space into another.
%   i_rgb2xyz        - Convert from RGB to XYZ.
%   i_rgb2ycc        - Converts from RGB to YCbCr.
%   i_rgbcast        - Convert RGB from one numeric represenation to another.
%   i_roo2brightness - Convert spectrum to ISO Brightness.
%   i_roo2cct        - Calculate correlated color temperature.
%   i_roo2disp       - Convert from spectra to DisplayRGB.
%   i_roo2lab        - Convert from spectra to LAB.
%   i_roo2prop       - Convert from spectra to various optical properties.
%   i_roo2rgb        - Convert from spectra to RGB.
%   i_roo2xy         - Convert from spectra to chromaticity x and y.
%   i_roo2xyz        - Convert from spectra to XYZ
%   i_srgbgamma      - Apply the special SRGB gamma function to RGB data.
%   i_xy2cct         - Calculate correlated color temperature.
%   i_xy2dp          - Calculate dominating wavelength and exitation purity.
%   i_xy2rgb         - Convert from XY to visually pleasing RGB.
%   i_xy2xyz         - Convert from xy to XYZ with maximum Y.
%   i_xyy2xyz        - Converts from xyY to XYZ.
%   i_xyz2disp       - Convert from XYZ to display realizable RGB.
%   i_xyz2lab        - Convert from XYZ to LAB.
%   i_xyz2luv        - Convert from XYZ to LUV.
%   i_xyz2luvp       - Convert from XYZ to LU'V'.
%   i_xyz2prop       - Convert from tristimulus XYZ to various optical properties.
%   i_xyz2rgb        - Convert from XYZ to RGB.
%   i_xyz2rxryrz     - Convert from XYZ to RxRyRz.
%   i_xyz2wtj        - Convert from XYZ to CIE Whiteness, T(Red Tint) and J (Yellowness).
%   i_xyz2xy         - Convert from XYZ to chromaticity xy.
%   i_xyz2xyy        - Convert from tristimulus XYZ to chromaticity xy and Y.
%   i_xyz2xyz        - Adapt XYZ to another illuminant/observer.
%   i_ycc2rgb        - Convert from YCbCr to RGB.
% Color data constants and generation
%   astm             - Database of ASTM E308 table 5 and 6 color weighting functions.
%   blackbody        - Calculate radiation from a Planck black body radiator.
%   cwf2ill          - Extract the illuminant from a color weigting functoins specification
%   cwf2obs          - Extract the observer from a color weigting functoins specification
%   dill             - Calculate arbitrary D-Illuminant.
%   illuminant       - returns the spectral distribution of an illuminant.
%   iscwf            - Check for valid color weighting function specification
%   isilluminant     - Check for valid illuminant specification
%   isobserver       - Check for valid observer specification
%   makecwf          - Create color weighting function.
%   observer         - Returns a specified observer
%   rgbs             - Return RGB specifications
%   wpt              - Returns the whitepoint of a color weighting functions specification
% Color data generation
%   addmix           - Generate color test map for additive mixings.
%   colorchecker     - Spectral data of a Macbeth ColorChecker.
%   colormix         - Mix primary RGB or CMY... colors/inks.
%   concmix          - Generate saturation/value map of hues.
%   rosch            - Create the Rosch color solid.
%   submix           - Generate color test map for subtractive mixings.
% Color difference functions
%   de               - Calculate CIELAB DeltaE.
%   de2000           - Calculate DeltaE(2000).
%   de94             - Calculate DeltaE(94).
% Visualization
%   ballplot         - 3-D spheres plot.
%   bar3c            - Plot 3-D bar chart in true color
%   closesurf        - Close a parameterized surface by concatenation.
%   helmholtz        - Calculate and show  the Helmholtz "horseshoe"
%   optimage         - Display true color image converted to display.
%   viewgamut        - Visualize a color gamut
%   viewlab          - Visualize an Lab color gamut
% Toolbox framework
%   dcwf             - Return the default color matching function.
%   dwl              - Return or set the session default wavelength range.
%   optgetpref       - Get OptProp preferences.
%   optproc          - Block and argument processing for OptProp conversions.
%   optsetpref       - Set OptProp preferences.
% General utilities
%   args2struct      - Parse input parameters into a struct.
%   callername       - Return name of caller function.
%   iff              - Conditional selection.
%   illpar           - Return illegal parameter error struct.
%   isrgbclass       - Indicates whether input is a valid RGB class.
%   isrgbtype        - Indicates whether input is an RGB specification or not.
%   iswlrange        - Indicate whether a wavelength range is valid.
%   lincols          - Linearly spaced column vectors.
%   lineup           - Lines up x so it "fits" line or row vector y
%   logcols          - logarithically spaced column vectors.
%   MultiArgIn       - Normalize multidimensional input down to an array with two dimensions.
%   MultiArgOut      - Resize and distribute multidimensional data.
%   powcols          - power spaced column vectors.
%   surfvol          - returns the volume of parameterized volume XYZ
%   varginfill       - Set omitted input arguments to the empty array
%   xd               - Permute dimensions temporarily or permanently.
% External utilities
%   gridfit          - estimates a surface on a 2d grid, based on scattered data
%   isnear           - True Where Nearly Equal.
%   onoff            - ON/OFF to/from Boolean Conversion.
% Demo
%   optpropdemo      -  Shows various features of the toolbox.

% Version 2.1.4
%    Chunking tristimulus calculation with non-ASTM spectra now works
%    Handles NaN in Brightness calculations without warning
%    Better error message in closesurf
%    Helmolz plot now in 3D. Won't show any difference if viewed in 2D.
%    Fixed viewgamut. Remnants caused error when updating a previous plot.
% Version 2.1.3
%    Corrected roo2prop for single 'L' and 'b'
%    roo2brightness now works for single spectrum
% Version 2.1.2  6 February 2007
%    wpt now also considers [] as dcwf
%    rosch documentation corrected
%    Typos corrected in manual
% Version 2.1.1  27 January 2007
%    Added illuminant data for F1-F12
% Version 2.0   1 December 2006
