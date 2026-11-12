function T = swir_fitTemp(frames, T_LU, S_LU, S0, bitlength)
%   T = SWIR_FITTEMP estimates the temperature of each pixel with single-band pyrometry, 
%   by interpolating a calibration lookup table relating pixel signal intensity (DN) to temperature.
%
%   Pixels with signal intensities below 10% or above 90% of the camera's
%   maximum digital value are considered unreliable (underexposed or
%   overexposed) and assigned NaN.
%
%   Inputs:
%       frames      [DN]  M-by-N-by-K array of K monochrome image frames of size M-by-N
%       T_LU        [K]   Lookup table of calibrated temperatures
%       S_LU        [DN]  Corresponding lookup table of signal intensities
%       S0          [DN]  Camera black level
%       bitlength   [-]   Camera bit depth (default: 8)
%
%   Output:
%       T           [K]   M-by-N-by-K array of estimated pixel temperatures,
%                     with unreliable pixels assigned NaN.
%
%   Note:
%       Temperature estimation relies on the calibration relationship
%       between signal intensity and temperature. Its validity depends
%       on the calibration conditions and measurement setup.

arguments
    frames (:,:,:) double
    T_LU (1,:) {mustBePositive}
    S_LU (1,:) {mustBePositive}
    S0 (1,1) {mustBePositive}
    bitlength (1,1) {mustBePositive} = 8
end

% sz_frame = size(frames, [1 2]);
% n_frames = size(frames, 3);
% T = zeros(size(frames));
% 
% for i_frame = 1:n_frames
%     frame = frames(:,:,i_frame);
%     T_loc = interp1(S_LU, T_LU, frame(:));
%     T_loc = reshape(T_loc, sz_frame);
%     T(:,:,i_frame) = T_loc;
% end

T = interp1(S_LU, T_LU, frames, 'linear', NaN);

underexposed_thr = S0;

max_S = 2^bitlength - 1;
overexposed_thr = max_S * 0.9; 

T(frames < underexposed_thr) = nan; % temperature estimation does not make sense if pixel is underexposed
T(frames > overexposed_thr) = nan; % temperature estimation does not make sense if pixel is overexposed
end