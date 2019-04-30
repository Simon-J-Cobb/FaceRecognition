clc
clear variables
close all
% Load from files and folders
faceFolder = '3D_Faces_Processed_Step2/'; 
fileType = '.obj';
folderContent = dir([faceFolder,'*',fileType]);
addpath('3D_Faces_Processed_Step2/');
% number of faces in the folder
nface = size (folderContent,1);

res = 100;    
sel = 1;
lvSet = 0:10:350;
npt = 50;
setsofcurves{36,nface} = [];
classes = zeros(1,nface);
poses = zeros(1,nface);
counter = 1;
for i = 4:nface
    face = folderContent(i,1).name;
    splitfilename = split({face},'-');
    mesh = readObj(strcat(faceFolder,face));
    vertices = mesh.v;
    [M,I] = max(vertices);
    translatedvertices = vertices - vertices(I(3),:);
    croppedvertices = translatedvertices(vecnorm(translatedvertices') < 75,:);
    classes(counter) = str2num(splitfilename{1});
    poses(counter) = str2num(splitfilename{2});
    if and(poses(counter)>1,poses(counter)<8)
        continue
    end    
    if poses(counter) == 1
        referenceface = croppedvertices;
        registeredvertices = referenceface;
    else
        [~,registeredvertices] = pcregistericp(pointCloud(croppedvertices),pointCloud(referenceface));
        registeredvertices = registeredvertices.Location;
    end
    try
        exFacialCurve(registeredvertices, res, sel, lvSet, npt);
    catch
        continue
    end
    curvSet = exFacialCurve(registeredvertices, res, sel, lvSet, npt);
    setsofcurves(:,counter) = curvSet;
%   figure(1);hold all
   %scatter3(croppedvertices(:,1),croppedvertices(:,2),croppedvertices(:,3))
   scatter3(registeredvertices(:,1),registeredvertices(:,2),registeredvertices(:,3))
   scatter3(referenceface(:,1),referenceface(:,2),referenceface(:,3))
%    visualizeCurve(registeredvertices, res, curvSet)
    counter = counter + 1;
end

%Shrink the arrays to remove empty cells
classes = classes(1:counter);
poses = poses(1:counter);
setsofcurves = setsofcurves(:,1:counter);
