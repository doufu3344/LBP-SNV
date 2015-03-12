function compNormals(info)

for i = 1:info.ncls
    idxcls = sprintf('a%02d', i);
    
    for j = 1:info.nsbj
        idxsbj = sprintf('s%02d', j);
        
        for k = 1:info.nemp
            idxemp = sprintf('e%02d', k);
            
            disp(['computing normals of video: ', idxcls, '_', idxsbj, '_', idxemp, ' ......']);
            
            % read depth sequences from a binary file
            vidName = [info.vidpath, '\', idxcls, '_', idxsbj, '_', idxemp, '_sdepth.bin'];
            depth = readDepthBin(vidName);

            % some missed videos
            if isempty(depth)
                continue;
            end
            
            % compute derivatives of depth sequence
            [nrows, ncols, nfrms] = size(depth);
            dx = zeros(nrows - 2, ncols - 2, nfrms - 1);
            dy = zeros(nrows - 2, ncols - 2, nfrms - 1);
            dt = zeros(nrows - 2, ncols - 2, nfrms - 1);
            mag = ones(nrows - 2, ncols - 2, nfrms - 1) * -1;
            
            for f = 1:nfrms-1
                % smooth
                frame1 = medfilt2(depth(:, :, f), [5, 5]);
                frame2 = medfilt2(depth(:, :, f + 1), [5, 5]);

                % derivatives along x/y/t
                dx(:, :, f) = frame1(2:end-1, 3:end) - frame1(2:end-1, 1:end-2);
                dy(:, :, f) = frame1(3:end, 2:end-1) - frame1(1:end-2, 2:end-1);
                dt(:, :, f) = frame1(2:end-1,2:end-1) - frame2(2:end-1, 2:end-1);
            
                % normalize
                reg = sqrt(dx(:, :, f).^2 + dy(:, :, f).^2 + dt(:, :, f).^2 + (-1)^2 );
                dx(:, :, f) = dx(:, :, f) ./ reg;
                dy(:, :, f) = dy(:, :, f) ./ reg;
                dt(:, :, f) = dt(:, :, f) ./ reg;
                mag(:, :, f) = mag(:, :, f) ./ reg;
                
                
                dx(isinf(dx)) = 0; dx(isnan(dx)) = 0;
                dy(isinf(dy)) = 0; dy(isnan(dy)) = 0;
                dt(isinf(dt)) = 0; dt(isnan(dt)) = 0;
                mag(isinf(mag)) = 0; mag(isnan(mag)) = 0;
            end

            % to mask cloud points belonging to human body
            masks = logical(depth);
            masks(:, :, end) = [];
            
            % save normals and masks
            normalName = [info.normpath, '\', idxcls, '_', idxsbj, '_', idxemp, '_norm.mat'];
            save(normalName, 'dx', 'dy', 'dt', 'mag', 'masks');
        end
    end
end

end