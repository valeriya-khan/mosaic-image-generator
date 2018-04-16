function [] = mosaic(bar_numl,shape)
%UNTITLED2 Summary of this function goes here
%bar_numl is number of bars in the length of large image
%shape can be square or circle
%file types
file_types = {['*.BMP;*.GIF;*.HDF;*.JPEG;*.JPG;*.PBM;*.PCX;*.PGM;',...
    '*.PNG;*.PNM;*.PPM;*.RAS;*.TIFF;*.TIF;*.XWD'],'MATLAB Graphical Files'};
comp_file_types = {'BMP' 'GIF' 'HDF' 'JPEG' 'JPG' 'PBM' 'PCX' 'PGM' ...
    'PNG' 'PNM' 'PPM' 'RAS' 'TIFF' 'TIF' 'XWD'};
%main image and folder of small images
img_path = uigetfile(file_types, 'Select main image');
img_dir = uigetdir();
%reading main image
main = imread(img_path);
main_size = size(main);
main_size = main_size(1:2);
%size of bar
bar_pix = floor(main_size(1)/bar_numl);
bar_size = [bar_pix bar_pix];
%resize of main image according to bar size
new_height = floor(main_size(2)/bar_pix);
num_bars = [bar_numl new_height];
new_size = [bar_numl new_height].*bar_pix;
main = imresize(main, new_size);
%get bar images
dir_files = dir(img_dir);
ind = 1;
%% adding images to array
for d = 1:length(dir_files)
    if ~dir_files(d).isdir
        file_name = dir_files(d).name;
        %Check file extension
        [~, ~, ext] = fileparts(file_name);
        if max(strcmpi(ext(2:end), comp_file_types))
            imageData = imread(file_name);
            cellArrayOfImages{ind} = imageData;
            ind = ind+1;
        end
    end
end
switch shape
    case 'square'
        %% resizing bar images
        for i = 1:length(cellArrayOfImages)
            %if ~isempty(cellArrayOfImages{i})
                img = cellArrayOfImages{i};
                res_img = uint8(imresize(img, bar_size));
                bars{i} = res_img;
                bar_RGB{i} = mean(reshape(res_img, [], 3), 1);
            %end;
        end;
        %% compare tiles and bars
        for row_tile = 1:num_bars(1)
            for col_tile = 1:num_bars(2)
                closest = 1;
                shortest_dist = 1000;
                %get mean of tiles
                tile = main(bar_pix*(row_tile-1)+1:bar_pix*(row_tile), ...
                bar_pix*(col_tile-1)+1:bar_pix*(col_tile),:);
                tile_RGB = mean(reshape(tile, [], 3), 1);
                %find the closest bar 
                for bar_tile = 1:length(cellArrayOfImages)
                    if ~isempty(bars{bar_tile})
                        dist= sqrt(sum((tile_RGB-bar_RGB{bar_tile}).^2));
                    end;
                    %if new dist is closer
                    if dist < shortest_dist
                        shortest_dist = dist;
                        pic_map(row_tile, col_tile) = bar_tile;
                    end
                end
            end
        end
        %% constructing the image and show
        for row_tile = 1:num_bars(1)
            cur_row = bars{pic_map(row_tile, 1)};
            for col_tile = 2:num_bars(2)
                cur_row = horzcat(cur_row, bars{pic_map(row_tile, col_tile)});
            end
            if row_tile == 1
                mosaic = cur_row;
            else
                mosaic = vertcat(mosaic, cur_row);
                clear cur_row;
            end
        end
        imshow(mosaic)
    case 'circle'
        %% resizing bar images and converting to circles
        for i = 1:length(cellArrayOfImages)
            if ~isempty(cellArrayOfImages{i})
                img = cellArrayOfImages{i};
                res_img = uint8(imresize(img, bar_size));
                bar_RGB{i} = mean(reshape(res_img, [], 3), 1);
                res = zeros(bar_size(1), bar_size(2),3);
                for k=1:bar_size
                    for j=1:bar_size
                        if (k-bar_size(1)/2)^2+(j-bar_size(1)/2)^2<=(bar_size(1)/2)^2+1
                            res(k,j,:)=res_img(k,j,:);
                        end;
                    end;
                end;
                bars{i}=uint8(res);
            end;
        end;
        %% calculating rad
        rad=int16((bar_size(1)/2));
        %% comparing first sequence of tiles with bars
        for row_tile = 1:num_bars(1)
            for col_tile = 1:num_bars(2)
                closest = 1;
                shortest_dist = 1000;
                %get mean vals for tiles
                tile = main(bar_pix*(row_tile-1)+1:bar_pix*(row_tile), ...
                bar_pix*(col_tile-1)+1:bar_pix*(col_tile),:);
                tile_RGB = mean(reshape(tile, [], 3), 1);

                %find the closest bar
                for bar_tile = 1:length(cellArrayOfImages)
                    if ~isempty(bars{bar_tile})
                        dist= sqrt(sum((tile_RGB-bar_RGB{bar_tile}).^2));
                    end;
                    %if new dist is closer
                    if dist < shortest_dist
                        shortest_dist = dist;
                        pic_map(row_tile, col_tile) = bar_tile;
                    end
                end
            end
        end
        %% constructing first mosaic
        for row_tile = 1:num_bars(1)
            cur_row = bars{pic_map(row_tile, 1)};
            for col_tile = 2:num_bars(2)
                cur_row = horzcat(cur_row, bars{pic_map(row_tile, col_tile)});
            end
            if row_tile == 1
                mosaic = cur_row;
            else
                mosaic = vertcat(mosaic, cur_row);
                clear cur_row;
            end
        end
        %% comparing second sequence of tiles with bars
        for row_tile = 1:num_bars(1)-1
            for col_tile = 1:num_bars(2)-1
                closest = 1;
                shortest_dist = 1000;
                %get mean vals for tile
                tile = main(bar_pix*(row_tile-1)+1+rad:bar_pix*(row_tile)+rad, ...
                bar_pix*(col_tile-1)+1+rad:bar_pix*(col_tile)+rad,:);
                tile_RGB = mean(reshape(tile, [], 3), 1);

                %find the closest bar
                for bar_tile = 1:length(cellArrayOfImages)
                    if ~isempty(bars{bar_tile})
                        dist= sqrt(sum((tile_RGB-bar_RGB{bar_tile}).^2));
                    end;
                    %if new dist is closer
                    if dist < shortest_dist
                        shortest_dist = dist;
                        pic_map(row_tile, col_tile) = bar_tile;
                    end
                end
            end
        end
        %% constructing the second mosaic for covering spces between circles
        for row_tile = 1:num_bars(1)-1
            cur_row = bars{pic_map(row_tile, 1)};
            for col_tile = 2:num_bars(2)-1
                cur_row = horzcat(cur_row, bars{pic_map(row_tile, col_tile)});
            end
            if row_tile == 1
                mosaic1 = cur_row;
            else
                mosaic1 = vertcat(mosaic1, cur_row);
                clear cur_row;
            end
        end
        %% making two mosaics the same size
        temp1 = size(mosaic1);
        temp=size(mosaic);
        a = zeros(temp1(1),floor((temp(1)-temp1(1))/2),3);
        a1 = zeros(temp1(1),floor((temp(1)-temp1(1))/2)+1,3);
        mosaic1 = [a, mosaic1,a1];
        temp1=size(mosaic1);
        b = zeros(floor((temp(1)-temp1(1))/2)+1,temp1(2),3);
        b1 = zeros(floor((temp(1)-temp1(1))/2),temp1(2),3);
        mosaic1 = [b; mosaic1;b1];
        %% replacing spaces of second mosaic with corresponding pixels of first one
        for i=1:new_size(1)
            for j = 1:new_size(2)
                if mosaic1(i,j,:)==0
                    mosaic1(i,j,:)=mosaic(i,j,:);
                end;
            end;
        end;
        imshow(mosaic1);
end

end

