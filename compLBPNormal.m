function compLBPNormal(info, scheme)
for i = 1:info.ncls
    idxcls = sprintf('a%02d', i);
    
    for j = 1:info.nsbj
        idxsbj = sprintf('s%02d', j);
        
        for k = 1:info.nemp
            idxemp = sprintf('e%02d', k); 
            disp(['computing LBP normals of video: ', idxcls, '_', idxsbj, '_', idxemp, ' ......']);
            
            % read normals and masks
            normalName = [info.normpath, '\', idxcls, '_', idxsbj, '_', idxemp, '_norm.mat'];
            
            % some missed videos
            if ~exist(normalName, 'file')
                continue;
            end
            
            load(normalName, 'dx', 'dy', 'dt', 'mag', 'masks');
            lbp = getLBP(dx, dy, dt, mag, scheme.anglethres);
           
            % save lbp normals and masks
            lbpName = [info.lbppath, '\', idxcls, '_', idxsbj, '_', idxemp, '_lbp.mat'];
            save(lbpName, 'lbp', 'masks');
        end
    end
end
end

