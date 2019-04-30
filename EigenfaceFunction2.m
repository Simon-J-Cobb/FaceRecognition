function [SuccessRate,Falsematchrate,Falsenonmatchrate,NumberofEigenvectorsused] = EigenfaceFunction2(Faces,classes,poses,proportion,Mahalanobis,ClassMeansChoice,t)

% number of faces in the folder
nface = length (Faces);
Resolution = 72;
Pixels = Resolution^2;

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
% proportion = 0.95;
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

% Mahalanobis = 1; %Choce of Whether to Use Mahalanobis Distance or Euclidean
% ClassMeansChoice = 1 %Choice to use all the data or the class means

%Face Recognition With Threshold
% t = 10;
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
Falsematchrate = Falsematch/(length(Successes)-sum(Successes));
Falsenonmatchrate = Falsenonmatch/(length(Successes)-sum(Successes));