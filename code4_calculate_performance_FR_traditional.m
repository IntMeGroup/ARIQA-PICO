%  ------------------------------------------------------------------------------------------
%  Subjective and objective equality assessment for augmented reality images 
%  Pengfei Wang, Huiyu Duan, Zongyi Xie, Xiongkuo Min, and Guangtao Zhai
%  IEEE Open Journal on Immersive Displays
%  Reference from ：
%  Confusing image quality assessment: Towards better augmented reality experience
%  Huiyu Duan, Xiongkuo Min, Yucheng Zhu, Guangtao Zhai, Xiaokang Yang, and Patrick Le Callet
%  IEEE Transactions on Image Processing (TIP)
%  ------------------------------------------------------------------------------------------

clc
close all
clear all

%% performance

addpath('.\performance\')
addpath('.\PWRC')

MOS = load('..\database\CFIQAMOS\MOS.mat').MOS;
SD = load('..\database\CFIQAMOS\SD.mat').SD;
MOSz = load('..\database\CFIQAMOS\MOSz.mat').MOSz;
GT = MOSz;

confusion_IQA_FR = load('.\code2result.mat'); 
confusion_IQA_FR_names = fieldnames(confusion_IQA_FR);



%% FR Algorithms
for i = 1:size(confusion_IQA_FR_names,1)
    temp_score = real(getfield(confusion_IQA_FR,confusion_IQA_FR_names{i,1}));
    score_FR(:,i) = [temp_score(:,1);temp_score(:,2)];
    
    perSRCC_FR(1,i) = corr(score_FR(:,i),GT,'type','Spearman');
    perKRCC_FR(1,i) = corr(score_FR(:,i),GT,'type','Kendall');
    [delta,beta,yhat,y,diff] = findrmse2(score_FR(:,i),GT);
    score_mapped(:,i) = yhat;
    perRMSE_FR(1,i) = sqrt(sum(diff.^2)/length(diff));
    perPLCC_FR(1,i) = corr(GT, yhat, 'type','Pearson');
    perPWRC_FR(1,i) = calPWRC(score_FR(:,i), MOS, SD);
end

%% after split to two sub-datasets


for p = 1:10
    for j = 1:15
        alpha(45*(p-1)+j,1) = 0.75;
        alpha(45*(p-1)+j+15,1) = 0.5;   
        alpha(45*(p-1)+j+30,1) = 0.25;
    end
end

%alpha=0.75;alpha=0.5;alpha=0.25
for i = 1:450
    if (alpha(i,1)==0.75)
        DistortionType1(i,1) = 1;
        DistortionType1(i+450,1) = 1;
    else
        DistortionType1(i,1) = 2;
        DistortionType1(i+450,1) = 2;
    end
end
for i = 1:450
    if (alpha(i,1)==0.5)
        DistortionType2(i,1) = 1;
        DistortionType2(i+450,1) = 1;
    else
        DistortionType2(i,1) = 2;
        DistortionType2(i+450,1) = 2;
    end
end
for i = 1:450
    if (alpha(i,1)==0.25)
        DistortionType3(i,1) = 1;
        DistortionType3(i+450,1) = 1;
    else
        DistortionType3(i,1) = 2;
        DistortionType3(i+450,1) = 2;
    end
end

% split the dataset to two sub-datasets (image:[1,450][451,900])
% for i = 1:450
%     if (i<=225)
%         DatasetType(i,1) = 1;
%         DatasetType(i+450,1) = 1;
%     else
%         DatasetType(i,1) = 2;
%         DatasetType(i+450,1) = 2;
%     end
% end

for i = 1:size(confusion_IQA_FR_names,1)
    for j = 1:2     
        scoreNewTemp = score_FR(:,i);
        scoreNew = scoreNewTemp;
        GTNew = GT;
        MOSNew = MOS;
        SDNew = SD;
        % scoreNew = scoreNewTemp(find(DatasetType==j));
        % GTNew = GT(find(DatasetType==j));
        % MOSNew = MOS(find(DatasetType==j));
        % SDNew = SD(find(DatasetType==j));
        perSRCC_FR(j+1,i) = corr(scoreNew,GTNew,'type','Spearman');
        perKRCC_FR(j+1,i) = corr(scoreNew,GTNew,'type','Kendall');
        [delta,beta,yhat,y,diff] = findrmse2(scoreNew,GTNew);
        perRMSE_FR(j+1,i) = sqrt(sum(diff.^2)/length(diff));
        perPLCC_FR(j+1,i) = corr(GTNew, yhat, 'type','Pearson');
        perPWRC_FR(j+1,i) = calPWRC(scoreNew, MOSNew, SDNew);
    end
    
    for j = 1:2     % 0.75
        scoreNewTemp = score_FR(:,i);
        % scoreNew = scoreNewTemp(find(DistortionType1==1&DatasetType==j));
        % GTNew = GT(find(DistortionType1==1&DatasetType==j));
        % MOSNew = MOS(find(DistortionType1==1&DatasetType==j));
        % SDNew = SD(find(DistortionType1==1&DatasetType==j));
        scoreNew = scoreNewTemp(find(DistortionType1==1));
        GTNew = GT(find(DistortionType1==1));
        MOSNew = MOS(find(DistortionType1==1));
        SDNew = SD(find(DistortionType1==1));
        perSRCC_FR(j+3,i) = corr(scoreNew,GTNew,'type','Spearman');
        perKRCC_FR(j+3,i) = corr(scoreNew,GTNew,'type','Kendall');
        [delta,beta,yhat,y,diff] = findrmse2(scoreNew,GTNew);
        perRMSE_FR(j+3,i) = sqrt(sum(diff.^2)/length(diff));
        perPLCC_FR(j+3,i) = corr(GTNew, yhat, 'type','Pearson');
        perPWRC_FR(j+3,i) = calPWRC(scoreNew, MOSNew, SDNew);
    end
    
    for j = 1:2     %0.5

        scoreNewTemp = score_FR(:,i);
        scoreNew = scoreNewTemp(find(DistortionType2==1));
        GTNew = GT(find(DistortionType2==1));
        MOSNew = MOS(find(DistortionType2==1));
        SDNew = SD(find(DistortionType2==1));
        % scoreNew = scoreNewTemp(find(DistortionType2==1&DatasetType==j));
        % GTNew = GT(find(DistortionType2==1&DatasetType==j));
        % MOSNew = MOS(find(DistortionType2==1&DatasetType==j));
        % SDNew = SD(find(DistortionType2==1&DatasetType==j));        
        perSRCC_FR(j+5,i) = corr(scoreNew,GTNew,'type','Spearman');
        perKRCC_FR(j+5,i) = corr(scoreNew,GTNew,'type','Kendall');
        [delta,beta,yhat,y,diff] = findrmse2(scoreNew,GTNew);
        perRMSE_FR(j+5,i) = sqrt(sum(diff.^2)/length(diff));
        perPLCC_FR(j+5,i) = corr(GTNew, yhat, 'type','Pearson');
        perPWRC_FR(j+5,i) = calPWRC(scoreNew, MOSNew, SDNew);
    end

    for j = 1:2     % 0.25
        scoreNewTemp = score_FR(:,i);
        scoreNew = scoreNewTemp(find(DistortionType3==1));
        GTNew = GT(find(DistortionType3==1));
        MOSNew = MOS(find(DistortionType3==1));
        SDNew = SD(find(DistortionType3==1));
        % scoreNew = scoreNewTemp(find(DistortionType3==1&DatasetType==j));
        % GTNew = GT(find(DistortionType3==1&DatasetType==j));
        % MOSNew = MOS(find(DistortionType3==1&DatasetType==j));
        % SDNew = SD(find(DistortionType3==1&DatasetType==j));
        perSRCC_FR(j+7,i) = corr(scoreNew,GTNew,'type','Spearman');
        perKRCC_FR(j+7,i) = corr(scoreNew,GTNew,'type','Kendall');
        [delta,beta,yhat,y,diff] = findrmse2(scoreNew,GTNew);
        perRMSE_FR(j+7,i) = sqrt(sum(diff.^2)/length(diff));
        perPLCC_FR(j+7,i) = corr(GTNew, yhat, 'type','Pearson');
        perPWRC_FR(j+7,i) = calPWRC(scoreNew, MOSNew, SDNew);
    end
end

% Entire dataset
perSRCC_FR(10,:) = (abs(perSRCC_FR(2,:))+abs(perSRCC_FR(3,:)))/2;
perKRCC_FR(10,:) = (abs(perKRCC_FR(2,:))+abs(perKRCC_FR(3,:)))/2;
perRMSE_FR(10,:) = (abs(perRMSE_FR(2,:))+abs(perRMSE_FR(3,:)))/2;
perPLCC_FR(10,:) = (abs(perPLCC_FR(2,:))+abs(perPLCC_FR(3,:)))/2;
perPWRC_FR(10,:) = (abs(perPWRC_FR(2,:))+abs(perPWRC_FR(3,:)))/2;

% alpha=0.75
perSRCC_FR(11,:) = (abs(perSRCC_FR(4,:))+abs(perSRCC_FR(5,:)))/2;
perKRCC_FR(11,:) = (abs(perKRCC_FR(4,:))+abs(perKRCC_FR(5,:)))/2;
perRMSE_FR(11,:) = (abs(perRMSE_FR(4,:))+abs(perRMSE_FR(5,:)))/2;
perPLCC_FR(11,:) = (abs(perPLCC_FR(4,:))+abs(perPLCC_FR(5,:)))/2;
perPWRC_FR(11,:) = (abs(perPWRC_FR(4,:))+abs(perPWRC_FR(5,:)))/2;

% alpha=0.50
perSRCC_FR(12,:) = (abs(perSRCC_FR(6,:))+abs(perSRCC_FR(7,:)))/2;
perKRCC_FR(12,:) = (abs(perKRCC_FR(6,:))+abs(perKRCC_FR(7,:)))/2;
perRMSE_FR(12,:) = (abs(perRMSE_FR(6,:))+abs(perRMSE_FR(7,:)))/2;
perPLCC_FR(12,:) = (abs(perPLCC_FR(6,:))+abs(perPLCC_FR(7,:)))/2;
perPWRC_FR(12,:) = (abs(perPWRC_FR(6,:))+abs(perPWRC_FR(7,:)))/2;

% alpha=0.25
perSRCC_FR(13,:) = (abs(perSRCC_FR(8,:))+abs(perSRCC_FR(9,:)))/2;
perKRCC_FR(13,:) = (abs(perKRCC_FR(8,:))+abs(perKRCC_FR(9,:)))/2;
perRMSE_FR(13,:) = (abs(perRMSE_FR(8,:))+abs(perRMSE_FR(9,:)))/2;
perPLCC_FR(13,:) = (abs(perPLCC_FR(8,:))+abs(perPLCC_FR(9,:)))/2;
perPWRC_FR(13,:) = (abs(perPWRC_FR(8,:))+abs(perPWRC_FR(9,:)))/2;