% SWIR temperature estimation

close all
clear variables

%% Input parameters + load data
data_folder = "data";

filename = "20220706_870";
track_num = 870;

fps = 50;
bitlength = 8;
S0 = 30;
max_S = 2^bitlength - 1;
plot_roi = [150 300 225 375];

swir_frames = swir_readData(fullfile(data_folder, filename));

%% Calibration
% For PhotonFocus MV3-D640I-M01-144-CL (Snake SW sensor)
wl_response = [900:100:1600 1650 1700];
cam_response = [0.3 0.68 0.75 0.83 0.9 0.96 1.05 1.05 1.05 0.2];
T_calibpoint = 1500;
S_calibpoint = 110; 
[T_LU, S_LU] = swir_getCalib(wl_response, cam_response, T_calibpoint, S_calibpoint);

f_T = figure;
f_T.Position(3:4) = [400 300];
plot(S_LU, T_LU, "LineWidth",1.0)
xlabel("Pixel value look-up table [DN]")
ylabel("Temperature look-up table [K]")
title("SWIR calibration")
grid on
xlim([0 max_S])

exportgraphics(gcf, "./figures/swircalib.png", "Resolution",300)

%% Temperature estimation
i_melting_start = 15;
i_frames = i_melting_start+4:2:i_melting_start+12;
frames = swir_frames(:,:,i_frames);
T = swir_fitTemp(frames, T_LU, S_LU, S0, bitlength);
T_plot = T(:,:,1);

f_temp = figure;
f_temp.Position(3:4) = [800 400];

tiledlayout(1,2)

nexttile;
imagesc(frames(:,:,1));
axis equal
axis(plot_roi)
hold on
title("Raw frame")
c = colorbar;
c.Label.String = 'Pixel value [DN]';

nexttile
imAlpha=ones(size(T_plot));
imAlpha(isnan(T_plot))=0;
imagesc(T_plot, 'AlphaData',imAlpha);
axis equal
axis(plot_roi)
hold on
title("Temperature distribution")
c = colorbar;
c.Label.String = 'Temperature [K]';
grid on
exportgraphics(f_temp, sprintf("./figures/2Dtemperature_track%d_frames%d.png", track_num, i_frames(1)), 'Resolution',300)

%% Tail temperature
delta_t = 1000/fps; % [ms]
t = i_frames * delta_t;

i_meltpool = 300;
j_meltpool = 150:300;

T_meltpool = squeeze(T(i_meltpool, j_meltpool,:));

f_tail = figure;
f_tail.Position(3:4) = [600 400];
plot(T_meltpool, '.-', 'MarkerSize',10)
xlabel("Pixel index [-]")
ylabel("Temperature [K]")
grid on
legend("t = " + string(t) + " ms", 'Interpreter', 'none', 'Location','eastoutside')
title("Melt pool longitudinal temperature profile")
exportgraphics(f_tail, sprintf("./figures/1Dtemperature_track%d_frames%d-%d.png", track_num, i_frames(1), i_frames(end)), 'Resolution',300)