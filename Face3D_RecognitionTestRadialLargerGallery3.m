%Load the Data in
%load('counter.mat')
load('ClassesRadialICP.mat')
load('SetofCurvesRadialICP.mat')
load('PosesRadialICP.mat')

%Shrink the arrays to remove empty cells
%classes = classes(1:counter);
%poses = poses(1:counter);
%setsofcurves = setsofcurves(:,1:counter);

%Test for distance metric between 2 faces, over the 12 radial curves
% dist = 0;
% for i = 1:36
%     dist = dist + my3Dgeod(setsofcurves{1,1}',setsofcurves{1,10}');
% end

%Overall Face Recognition Test
%Probe faces set up, pose = 1 mean neutral looking forward
galleryfaces = setsofcurves(:,poses == 1);
galleryfaceclasses = classes(poses == 1);
ngalleryfaces = sum(poses == 1) ;

% %Rest of the faces taken to test the system
% DifferentClasses = unique(classes);
% trainingfaces = []
% trainingfaceclasses = []
% for i = DifferentClasses
%     test = randsample(8:15,2);
%     faces = setsofcurves(:,and(classes == i,or(poses == test(1),poses == test(2))));
%     faceclasses = classes(and(classes == i,or(poses == test(1),poses == test(2))));
%     trainingfaces = [trainingfaces,faces];
%     trainingfaceclasses = [trainingfaceclasses,faceclasses];
% end
% ntrainingfaces = length(trainingfaces);
% 
% %Test Carried out using min distance classifier
% alldistances = zeros(1,ntrainingfaces);
% distances = zeros(1,ngalleryfaces);
% correct = zeros(1,ntrainingfaces);
%  for k = 1:ntrainingfaces
%      for j = 1:ngalleryfaces
%          dist = 0;
%          for i = 1:1:36
%              %            i,j,k
%              n = 36;
%              %             if or(size(galleryfaces{i,j}',2)<10,size(trainingfaces{i,k}',2)<10)
%              %                 n = n - 1;
%              %                 break
%              %             end
%              try
%                  geodist = my3Dgeod(trainingfaces{i,k}',galleryfaces{i,j}');
%              catch
%                  n = n-1;
%                  continue
%              end
%              dist = dist + geodist;
%          end
%          if dist ~= 0
%              distances(j) = (1/n)*dist;
%          else
%              distances(j) = 10;
%          end
%      end
%      [mindist,person] = min(distances);
%      alldistances(k) =  mindist;
%      correct(k) = galleryfaceclasses(person) == trainingfaceclasses(k);
%      k, correct(k)
%  end
% 
% %Percentage Correct
% sum(correct)/ntrainingfaces

%successrates over various samples
successrates = zeros(1,10);
for l = 1:10
    %Rest of the faces taken to test the system
    DifferentClasses = unique(classes);
    trainingfaces = [];
    trainingfaceclasses = [];
    for i = DifferentClasses
        test = randsample(8:15,2);
        faces = setsofcurves(:,and(classes == i,or(poses == test(1),poses == test(2))));
        faceclasses = classes(and(classes == i,or(poses == test(1),poses == test(2))));
        trainingfaces = [trainingfaces,faces];
        trainingfaceclasses = [trainingfaceclasses,faceclasses];
    end
    ntrainingfaces = length(trainingfaces);
    
    %Test Carried out using min distance classifier
    alldistances = zeros(1,ntrainingfaces);
    distances = zeros(1,ngalleryfaces);
    correct = zeros(1,ntrainingfaces);
    for k = 1:ntrainingfaces
        for j = 1:ngalleryfaces
            dist = 0;
            for i = 1:1:36
                %            i,j,k
                n = 36;
                %             if or(size(galleryfaces{i,j}',2)<10,size(trainingfaces{i,k}',2)<10)
                %                 n = n - 1;
                %                 break
                %             end
                try
                    geodist = my3Dgeod(trainingfaces{i,k}',galleryfaces{i,j}');
                catch
                    n = n-1;
                    continue
                end
                dist = dist + geodist;
            end
            if dist ~= 0
                distances(j) = (1/n)*dist;
            else
                distances(j) = 10;
            end
        end
        [mindist,person] = min(distances);
        alldistances(k) =  mindist;
        correct(k) = galleryfaceclasses(person) == trainingfaceclasses(k);
        k, correct(k)
    end
    
    %Percentage Correct
    l
    successrates(l) =sum(correct)/ntrainingfaces
end
