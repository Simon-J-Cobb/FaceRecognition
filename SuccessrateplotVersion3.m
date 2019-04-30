clear variables

% Load from files and folders
faceFolder = 'Croppedfaces2/'; 
fileType = '.bmp';
folderContent = dir([faceFolder,'*',fileType]);
addpath('Croppedfaces2/');
%read the faces
% number of faces in the folder
nface = size (folderContent,1);

classes = zeros(1,nface);
poses = zeros(1,nface);
counter = 1;
Resolution = 72;
Pixels = Resolution^2;
Faces = zeros(Pixels,nface, 'uint8');
for i = 1:nface
    face = folderContent(i,1).name;
    splitfilename = split({face},'-');
    folder = folderContent(i,1).folder;
    fullFileName = fullfile(folder, face);
    I=imread(fullFileName);
    %Resize the image
    I=imresize(I,[Resolution,Resolution]);
    Faces(:,i) = I(:);
    classes(i) = str2num(splitfilename{1});
    poses(i) = str2num(splitfilename{2});
end


%Changing Proportion
% Proportion = 0.5:0.025:0.975;
% Successrates = zeros(20,1);
% Vectors = zeros(20,1);
% for i = 1:20
%     [Successrates(i),~,~,Vectors(i)] = EigenfaceFunction2(Faces,classes,poses,Proportion(i),1,1,1000);
% end
% figure(1)
% plot(Proportion,Successrates)
% xlabel('Proportion of Variance') 
% ylabel('Face Recognition Success Rate')
% figure(2)
% plot(Vectors,Successrates)
% xlabel('Eigenfaces Used') 
% ylabel('Face Recognition Success Rate')
% figure(3)
% plot(Proportion,Vectors)
% xlabel('Proportion of Variance') 
% ylabel('Eigenfaces Used')

%Changing Test, Same Proportion
% Successrates = zeros(20,1);
% Vectors = zeros(20,1);
% for i = 1:20
%     [Successrates(i),Vectors(i)] = York2DEigfaceVersion3(0.95);
% end
% boxplot(Successrates)

Successratemeans = zeros(20,1);
Successratesds = zeros(20,1);
meanEigenvectorsused = zeros(20,1);
Proportion = 0.5:0.025:0.975;
Successrates = zeros(20,1);
EigenVectorsUsed = zeros(20,1);
SuccessratemeansM = zeros(20,1);
SuccessratesdsM = zeros(20,1);
meanEigenvectorsusedM = zeros(20,1);
SuccessratesM = zeros(20,1);
EigenVectorsUsedM = zeros(20,1);
for i = 1:20
    for j = 1:20
        [SuccessratesM(j),~,~,EigenVectorsUsedM(j)] = EigenfaceFunction2(Faces,classes,poses,Proportion(i),1,1,1000);
        [Successrates(j),~,~,EigenVectorsUsed(j)] = EigenfaceFunction2(Faces,classes,poses,Proportion(i),0,1,1000);
    end
SuccessratemeansM(i) = mean(SuccessratesM);
SuccessratesdsM(i) = std(SuccessratesM);
meanEigenvectorsusedM(i) = mean(EigenVectorsUsedM);
Successratemeans(i) = mean(Successrates);
Successratesds(i) = std(Successrates);
meanEigenvectorsused(i) = mean(EigenVectorsUsed);
i
end
P = errorbar(meanEigenvectorsused(1:20),Successratemeans(1:20),Successratesds(1:20))
P(1).LineWidth = 2;
hold on
errorbar(meanEigenvectorsusedM(1:20),SuccessratemeansM(1:20),SuccessratesdsM(1:20))
xlabel('\fontsize{10}Mean Eigenvectors Used') 
ylabel('\fontsize{10}Mean Face Recognition Success Rate')
title('\fontsize{10}Face Recognition Success Rate Vs Eigenvectors Used Over 20 Repetitions')
legend('Euclidean','Mahalanobis','Location','northwest')

Plotdata = [meanEigenvectorsused,Successratemeans,Successratesds,meanEigenvectorsusedM,SuccessratemeansM,SuccessratesdsM];
Changing Test, Same Proportion
Successrates = zeros(20,1);
Vectors = zeros(20,1);
for i = 1:20
    [Successrates(i),Vectors(i)] = York2DEigfaceProcrustes(0.95);
end
boxplot(Successrates)