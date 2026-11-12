function [T_LU, S_LU] = swir_getCalib(wl_response, cam_response, T_calibpoint, S_calibpoint, bitlength)
% SWIR_GETCALIB Generate a temperature-to-signal calibration lookup table.
%
%   [T_LU, S_LU] = SWIR_GETCALIB(wl_response, cam_response, ...
%       T_calibpoint, S_calibpoint, bitlength) generates a lookup table
%   relating blackbody temperature to camera signal intensity.
%
%   The theoretical blackbody radiance is integrated over the camera's
%   spectral response and scaled using a single experimental calibration
%   point (T_calibpoint, S_calibpoint).
%
%   IMPORTANT:
%   This calibration is only valid for:
%       - The specific material and its emissivity.
%       - The specific camera exposure time and acquisition settings.
%       - Temperatures close to the calibration temperature.
%
%   The single-point calibration assumes that the system conversion
%   factor does not introduce significant spectral variations beyond
%   those accounted for by cam_response.
%
%   Inputs:
%       wl_response   - Wavelength vector (e.g. nm).
%       cam_response  - Corresponding dimensionless spectral response.
%       T_calibpoint  - Known calibration temperature (K).
%       S_calibpoint  - Measured pixel signal at calibration temperature (DN).
%       bitlength     - Camera bit depth (default: 16).
%
%   Outputs:
%       T_LU          - Lookup table of temperatures (K).
%       S_LU          - Corresponding calibrated signal values (DN).
%
%   Note:
%   The calibration point must be within the camera's admissible DN range.
%   The calibration temperature must lie within the generated lookup table.

arguments
    wl_response (1,:) double
    cam_response (1,:) double
    T_calibpoint (1,1) double
    S_calibpoint (1,1) double
    bitlength (1,1) {mustBeInteger, mustBePositive} = 8
end

% Verify calibration signal is within camera's dynamic range
max_DN = 2^bitlength - 1;

if S_calibpoint < 0 || S_calibpoint > max_DN
    error('Calibration signal must be within the camera DN range [0, %d].', max_DN);
end

% Define temperature lookup table
T_LU = 500:100:3500;
S_unitless = zeros(1, length(T_LU));

if T_calibpoint < T_LU(1) || T_calibpoint > T_LU(end)
    error('Calibration temperature must be within the lookup table range [%d, %d] K.', ...
        T_LU(1), T_LU(end));
end

% Calculate theoretical blackbody signal
for i = 1:length(T_LU)
    B = blackbody(wl_response, T_LU(i));
    S_unitless(i) = trapz(wl_response, cam_response .* B(:)');
end

% Scale theoretical signal using the experimental calibration point
S_calibpoint_unitless = interp1(T_LU, S_unitless, T_calibpoint);

S_LU = S_unitless .* S_calibpoint ./ S_calibpoint_unitless;

end