close all; clear; clc;

% set parameters
[info, scheme] = setParams;

% compute normals
compNormals(info);

% compute LBP normal
compLBPNormal(info, scheme);

% compute LBP normal basis (dictionary)
compPolyLBPBasis(info, scheme);

% compute descriptors of video sequences
compVidDesc(info, scheme);

% training and testing
svmClassify(info, scheme);