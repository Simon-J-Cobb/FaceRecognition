%Load from files and folders
%Retreive all photos from UoY File
faceFolder = 'UoY/'; 
fileType = '.bmp';
folderContent = dir([faceFolder,'*',fileType]);
addpath('UoY/');
% number of faces in the folder
nface = size (folderContent,1);

%Detecting and cropping the face
for j = 1:nface
    filename = folderContent(j,1).name;
    folder = folderContent(j,1).folder;
    fullName = fullfile(folder, filename);
    img = imread(fullName);
    FaceDetect = vision.CascadeObjectDetector;
    FaceDetect.MergeThreshold = 7 ;
    Box = step(FaceDetect, img);
    for i = 1 : size(Box, 1)
        J = imcrop(img, Box(i, :));
        string = {folderContent(j,1).name};
        imwrite(J,strcat('Croppedfaces2/',folderContent(j,1).name)) 
    end
end