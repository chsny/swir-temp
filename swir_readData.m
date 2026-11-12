function swirData = swir_readData(filename, frames, bitlength, k_defectpx)
% swir_readData  Reads data from avi files produced with the SWIR camera
% roi = [istart istop; jstart jstop]
arguments
    filename string
    frames = [1 Inf]
    bitlength (1,1) = 8
    k_defectpx = []
end

filename = filename + ".avi";
v = VideoReader(filename);
swirData = read(v, frames);

if bitlength == 8
    swirData = squeeze(uint8(swirData));

elseif bitlength == 12 || bitlength == 16
    swirData = squeeze(uint16(swirData));
end

swirData(k_defectpx)= NaN;
end