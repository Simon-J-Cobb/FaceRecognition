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

%Take a ramdom sample of the faces
sample = randperm(nface);
ratio = round(nface/10 * 5);
Training =  Faces(:,sample(1:ratio));
Test = Faces(:,sample(ratio + 1:nface));
DifferentClasses = unique(classes);
TrainingClasslabel = classes(sample(1:ratio));
TestClasslabel = classes(sample(ratio + 1:nface));
TrainingCounter = ratio;
TestCounter = nface - ratio;

%Take a stratified sample of the faces
Training =  zeros(Pixels,nface, 'uint8');
Test = zeros(Pixels,nface, 'uint8');
DifferentClasses = unique(classes);
TrainingClasslabel = zeros(1,nface , 'uint8');
TestClasslabel = zeros(1,nface , 'uint8');
TrainingCounter = 0;
TestCounter = 0;
for j = DifferentClasses
    Facegroup = Faces(:,classes == j);
    Facegroupsize = length(Facegroup(1,:));
    if Facegroupsize == 0
        continue
    end    
    sample = randperm(Facegroupsize);
    for k = 1:Facegroupsize
        if k < 3
            TestCounter = TestCounter + 1;
            Test(:,TestCounter) = Facegroup(:,sample(k));
            TestClasslabel(TestCounter) =  j;
        else
            TrainingCounter = TrainingCounter + 1;
            Training(:,TrainingCounter) = Facegroup(:,sample(k));
            TrainingClasslabel(TrainingCounter) =  j;
        end    
    end
end    

Training = Training(:,1:TrainingCounter);
TrainingClasslabel = TrainingClasslabel(1:TrainingCounter);
Test = Test(:,1:TestCounter);
TestClasslabel = TestClasslabel(:,1:TestCounter);

%Projection to Eigenspace
Training = double(Training');
Trainingmean = mean(Training);
TrainingArraySize = size(Training);
Trainingminusmean = Training - ones(TrainingArraySize(1),1) * Trainingmean;

covariance = cov(Trainingminusmean);
[V,D] = eig(covariance);
eigenvalues = diag(D);
i = Pixels;
proportion = 0.95;
variationexplained = sum(eigenvalues(i:Pixels))/sum(eigenvalues);
while variationexplained < proportion
    variationexplained = sum(eigenvalues(i:Pixels))/sum(eigenvalues);
    i = i - 1;
end    
NumberofEigenvectorsused = Pixels + 1 - i;

Eigenvectorspace = V(:,i:Pixels);
Projectedtraining = Trainingminusmean * Eigenvectorspace;

% for pictures = 1:10
%     Eigenface = rescale(V(:,Pixels-pictures),0,255);
%     Eigenface = uint8(reshape(Eigenface,Resolution,Resolution));
%     figure(pictures)
%     imshow(Eigenface)
% end


Test = double(Test');
TestingArraySize = size(Test);
Projectedtesting = (Test - ones(TestingArraySize(1),1) * Trainingmean) * Eigenvectorspace; 
eigenspacecov = Eigenvectorspace' * covariance * Eigenvectorspace;

%Mean Of Training
Classmeans = zeros(length(unique(TrainingClasslabel)),NumberofEigenvectorsused);
meancounter = 0;
ClassMeanslabel = unique(TrainingClasslabel);
for j = ClassMeanslabel
    meancounter = meancounter + 1;
    Classmeans(meancounter,:) = mean(Projectedtraining(TrainingClasslabel == j,:));
end

%Face Recognition Using All Data
% Successes = zeros(1,TestCounter);
% for i = 1:TestCounter
%     distances = pdist2(Projectedtesting(i,:),Projectedtraining,'mahalanobis',eigenspacecov);
%     [~,Index] = min(distances);
%     ActualClasslabel = TrainingClasslabel(Index);
%     Success = (TestClasslabel(i) == ActualClasslabel);
%     Successes(i) = Success;
% end
% 
% SuccessRate = sum(Successes)/length(Successes)

%Face Recognition Using Means
% Successes = zeros(1,TestCounter);
% for i = 1:TestCounter
%     distances = pdist2(Projectedtesting(i,:),Classmeans,'mahalanobis',eigenspacecov);
%     [~,Index] = min(distances);
%     ActualClasslabel = ClassMeanslabel(Index);
%     Success = (TestClasslabel(i) == ActualClasslabel);
%     Successes(i) = Success;
% end
% 
% SuccessRate = sum(Successes)/length(Successes)

Mahalanobis = 1; %Choce of Whether to Use Mahalanobis Distance or Euclidean
ClassMeansChoice = 1 %Choice to use all the data or the class means

%Face Recognition With Threshold
t = 10;
Falsematch = 0;
Falsenonmatch = 0;
Successes = zeros(1,TestCounter);
if ClassMeansChoice == 1
    ClassVectors = Classmeans;
    Classlabels = ClassMeanslabel;
else
    ClassVectors = Projectedtraining;
    Classlabels = TrainingClasslabel;
end    
for i = 1:TestCounter
    if Mahalanobis == 1
        distances = pdist2(Projectedtesting(i,:),ClassVectors,'mahalanobis',eigenspacecov);
    else
        distances = pdist2(Projectedtesting(i,:),ClassVectors);
    end
    [Min,Index] = min(distances);
    if Min > t
            ActualClasslabel = 0;
            Success = not(ismember(TestClasslabel(i),Classlabels));
            if Success == 0
                Falsenonmatch = Falsenonmatch + 1;
            end    
            Successes(i) = Success;
    else
    ActualClasslabel = Classlabels(Index);
    Success = (TestClasslabel(i) == ActualClasslabel);
    if Success == 0
                Falsematch = Falsematch + 1;
    end 
    Successes(i) = Success;
    end
end

SuccessRate = sum(Successes)/length(Successes)
Falsematchrate = Falsematch/(length(Successes)-sum(Successes))
Falsenonmatchrate = Falsenonmatch/(length(Successes)-sum(Successes))

%Plot of Thresholds
thresholds = 1:25;
Successrates = zeros(1,length(thresholds));
Falsematchrates = zeros(1,length(thresholds));
Falsenonmatchrates = zeros(1,length(thresholds));
for t = thresholds
    Falsematch = 0;
    Falsenonmatch = 0;
    Successes = zeros(1,TestCounter);
    for i = 1:TestCounter
        if Mahalanobis == 1
            distances = pdist2(Projectedtesting(i,:),ClassVectors,'mahalanobis',eigenspacecov);
        else
            distances = pdist2(Projectedtesting(i,:),ClassVectors);
        end
        [Min,Index] = min(distances);
        if Min > t
            ActualClasslabel = 0;
            Success = not(ismember(TestClasslabel(i),Classlabels));
            if Success == 0
                Falsenonmatch = Falsenonmatch + 1;
            end
            Successes(i) = Success;
        else
            ActualClasslabel = Classlabels(Index);
            Success = (TestClasslabel(i) == ActualClasslabel);
            if Success == 0
                Falsematch = Falsematch + 1;
            end
            Successes(i) = Success;
        end
    end
    SuccessRate = sum(Successes)/length(Successes);
    Successrates(t) = SuccessRate;
    Falsematchrate = Falsematch/length(Successes);
    Falsematchrates(t) = Falsematchrate ;
    Falsenonmatchrate = Falsenonmatch/length(Successes);
    Falsenonmatchrates(t) = Falsenonmatchrate ;
end

plot(thresholds,1-Successrates,thresholds,Falsematchrates,thresholds,Falsenonmatchrates)
legend('Total Error Rate','False Nonmatch Error Rate','False Match Error Rate')
xlabel('Thresholds')
ylabel('Percentage Error Rate')
title('Error Rates Over Multiple Thresholds')

