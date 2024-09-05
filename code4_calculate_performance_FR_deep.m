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



files_path = {
    % '.\code3\results\cfiqa_baseline\baseline\squeeze_baseline.csv',
    % '.\code3\results\cfiqa_baseline\baseline\alex_baseline.csv',
    % '.\code3\results\cfiqa_baseline\baseline\vgg16_baseline.csv',
    % '.\code3\results\cfiqa_baseline\baseline\vgg19_baseline.csv',
    % '.\code3\results\cfiqa_baseline\baseline\vgg16_plus_baseline.csv',
    % '.\code3\results\cfiqa_baseline\baseline\resnet18_baseline.csv',
    % '.\code3\results\cfiqa_baseline\baseline\resnet34_baseline.csv',
    % '.\code3\results\cfiqa_baseline\baseline\resnet50_baseline.csv',
    % '.\code3\results\cfiqa_baseline\baseline_lpips\squeeze_baseline.csv',
    % '.\code3\results\cfiqa_baseline\baseline_lpips\alex_baseline.csv',
    % '.\code3\results\cfiqa_baseline\baseline_lpips\vgg_baseline.csv',
    '.\code3\results_lr=0.001_beta1=0.6\checkpoints\cfiqa_squeeze\test.csv',
    '.\code3\results_lr=0.001_beta1=0.6\checkpoints\cfiqa_alex\test.csv',
    '.\code3\results_lr=0.001_beta1=0.6\checkpoints\cfiqa_vgg\test.csv',
    '.\code3\results_lr=0.001_beta1=0.6\checkpoints\cfiqa_vgg19\test.csv',
    %'.\code3\results\checkpoints\cfiqa_resnet18\test.csv',
    %'.\code3\results\checkpoints\cfiqa_resnet34\test.csv',
    %'.\code3\results\checkpoints\cfiqa_resnet50\test.csv',
    %'.\code3\results\checkpoints\cfiqa_plus_resnet34\test.csv',
    };


%% FR Algorithms
for i = 1:size(files_path,1)
    file_name = files_path{i,1};
    [numeric_r,text_r,raw_r] = xlsread(file_name);
    result = [numeric_r(1:2:900);numeric_r(2:2:900)];

    score_FR(:,i) = result;
    
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

% choose alpha data range (alpha:(alpha1,alpha2))
for i = 1:450
    if (alpha(i,1)==0.75)
        DistortionType(i,1) = 1;
        DistortionType(i+450,1) = 1;
    else
        DistortionType(i,1) = 2;
        DistortionType(i+450,1) = 2;
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

% for i = 1:450
%     if (i<=225)
%         DatasetType(i,1) = 1;
%         DatasetType(i+450,1) = 1;
%     else
%         DatasetType(i,1) = 2;
%         DatasetType(i+450,1) = 2;
%     end
% end


%% For code deeplearning cross=6


% split the dataset to two sub-datasets (image:[1,150][151,300])
% for i = 1:450
%     if (i<=75)
%         DatasetType(i,1) = 1;
%         DatasetType(i+450,1) = 1;
%     else
%         if (i<=150)
%             DatasetType(i,1) = 2;
%             DatasetType(i+450,1) = 2;
%         else
%             if(i<=225)
%                 DatasetType(i,1) = 3;
%                 DatasetType(i+450,1) = 3;
%             else
%                 if(i<=300)
%                     DatasetType(i,1) = 4;
%                     DatasetType(i+450,1) = 4;   
%                 else    
%                     if(i<=375)
%                         DatasetType(i,1) = 5;
%                         DatasetType(i+450,1) = 5;
%                     else
%                         DatasetType(i,1) = 6;
%                         DatasetType(i+450,1) = 6;
%                     end
%                 end
%             end
%         end
%     end
% end
% 
% for i = 1:size(files_path,1)
%     file_name = files_path{i,1};
%     [numeric_r,text_r,raw_r] = xlsread(file_name);
%     %numeric_r = fliplr(numeric_r);
%     result = [numeric_r(1:2:900);numeric_r(2:2:900)];
%     score_FR(:,i) = result;
% 
%     for j = 1:6     % four types
%         scoreNewTemp = score_FR(:,i);
%         scoreNew = scoreNewTemp(find(DatasetType==j));
%         GTNew = GT(find(DatasetType==j));
%         MOSNew = MOS(find(DatasetType==j));
%         SDNew = SD(find(DatasetType==j));
%         perSRCC_FR(j+1,i) = corr(scoreNew,GTNew,'type','Spearman');
%         perKRCC_FR(j+1,i) = corr(scoreNew,GTNew,'type','Kendall');
%         [delta,beta,yhat,y,diff] = findrmse2(scoreNew,GTNew);
%         perRMSE_FR(j+1,i) = sqrt(sum(diff.^2)/length(diff));
%         perPLCC_FR(j+1,i) = corr(GTNew, yhat, 'type','Pearson');
%         perPWRC_FR(j+1,i) = calPWRC(scoreNew, MOSNew, SDNew);
%     end
% 
%     for j = 1:6     % 0.75
%         scoreNewTemp = score_FR(:,i);
%         scoreNew = scoreNewTemp(find(DistortionType==1&DatasetType==j));
%         GTNew = GT(find(DistortionType==1&DatasetType==j));
%         MOSNew = MOS(find(DistortionType==1&DatasetType==j));
%         SDNew = SD(find(DistortionType==1&DatasetType==j));
%         perSRCC_FR(j+7,i) = corr(scoreNew,GTNew,'type','Spearman');
%         perKRCC_FR(j+7,i) = corr(scoreNew,GTNew,'type','Kendall');
%         [delta,beta,yhat,y,diff] = findrmse2(scoreNew,GTNew);
%         perRMSE_FR(j+7,i) = sqrt(sum(diff.^2)/length(diff));
%         perPLCC_FR(j+7,i) = corr(GTNew, yhat, 'type','Pearson');
%         perPWRC_FR(j+7,i) = calPWRC(scoreNew, MOSNew, SDNew);
%     end
% 
%     for j = 1:6     % 0.5
%         scoreNewTemp = score_FR(:,i);
%         scoreNew = scoreNewTemp(find(DistortionType2==1&DatasetType==j));
%         GTNew = GT(find(DistortionType2==1&DatasetType==j));
%         MOSNew = MOS(find(DistortionType2==1&DatasetType==j));
%         SDNew = SD(find(DistortionType2==1&DatasetType==j));
%         perSRCC_FR(j+13,i) = corr(scoreNew,GTNew,'type','Spearman');
%         perKRCC_FR(j+13,i) = corr(scoreNew,GTNew,'type','Kendall');
%         [delta,beta,yhat,y,diff] = findrmse2(scoreNew,GTNew);
%         perRMSE_FR(j+13,i) = sqrt(sum(diff.^2)/length(diff));
%         perPLCC_FR(j+13,i) = corr(GTNew, yhat, 'type','Pearson');
%         perPWRC_FR(j+13,i) = calPWRC(scoreNew, MOSNew, SDNew);
%     end
% 
%     for j = 1:6     % 0.25
%         scoreNewTemp = score_FR(:,i);
%         scoreNew = scoreNewTemp(find(DistortionType3==1&DatasetType==j));
%         GTNew = GT(find(DistortionType3==1&DatasetType==j));
%         MOSNew = MOS(find(DistortionType3==1&DatasetType==j));
%         SDNew = SD(find(DistortionType3==1&DatasetType==j));
%         perSRCC_FR(j+19,i) = corr(scoreNew,GTNew,'type','Spearman');
%         perKRCC_FR(j+19,i) = corr(scoreNew,GTNew,'type','Kendall');
%         [delta,beta,yhat,y,diff] = findrmse2(scoreNew,GTNew);
%         perRMSE_FR(j+19,i) = sqrt(sum(diff.^2)/length(diff));
%         perPLCC_FR(j+19,i) = corr(GTNew, yhat, 'type','Pearson');
%         perPWRC_FR(j+19,i) = calPWRC(scoreNew, MOSNew, SDNew);
%     end
% end
% 
% perSRCC_FR(26,:) = (abs(perSRCC_FR(2,:))+abs(perSRCC_FR(3,:))+abs(perSRCC_FR(4,:))+abs(perSRCC_FR(5,:))+abs(perSRCC_FR(6,:))+abs(perSRCC_FR(7,:)))/6;
% perKRCC_FR(26,:) = (abs(perKRCC_FR(2,:))+abs(perKRCC_FR(3,:))+abs(perKRCC_FR(4,:))+abs(perKRCC_FR(5,:))+abs(perKRCC_FR(6,:))+abs(perKRCC_FR(7,:)))/6;
% perRMSE_FR(26,:) = (abs(perRMSE_FR(2,:))+abs(perRMSE_FR(3,:))+abs(perRMSE_FR(4,:))+abs(perRMSE_FR(5,:))+abs(perRMSE_FR(6,:))+abs(perRMSE_FR(7,:)))/6;
% perPLCC_FR(26,:) = (abs(perPLCC_FR(2,:))+abs(perPLCC_FR(3,:))+abs(perPLCC_FR(4,:))+abs(perPLCC_FR(5,:))+abs(perPLCC_FR(6,:))+abs(perPLCC_FR(7,:)))/6;
% perPWRC_FR(26,:) = (abs(perPWRC_FR(2,:))+abs(perPWRC_FR(3,:))+abs(perPWRC_FR(4,:))+abs(perPWRC_FR(5,:))+abs(perPWRC_FR(6,:))+abs(perPWRC_FR(7,:)))/6;
% 
% perSRCC_FR(27,:) = (abs(perSRCC_FR(8,:))+abs(perSRCC_FR(9,:))+abs(perSRCC_FR(10,:))+abs(perSRCC_FR(11,:))+abs(perSRCC_FR(12,:))+abs(perSRCC_FR(13,:)))/6;
% perKRCC_FR(27,:) = (abs(perKRCC_FR(8,:))+abs(perKRCC_FR(9,:))+abs(perKRCC_FR(10,:))+abs(perKRCC_FR(11,:))+abs(perKRCC_FR(12,:))+abs(perKRCC_FR(13,:)))/6;
% perRMSE_FR(27,:) = (abs(perRMSE_FR(8,:))+abs(perRMSE_FR(9,:))+abs(perRMSE_FR(10,:))+abs(perRMSE_FR(11,:))+abs(perRMSE_FR(12,:))+abs(perRMSE_FR(13,:)))/6;
% perPLCC_FR(27,:) = (abs(perPLCC_FR(8,:))+abs(perPLCC_FR(9,:))+abs(perPLCC_FR(10,:))+abs(perPLCC_FR(11,:))+abs(perPLCC_FR(12,:))+abs(perPLCC_FR(13,:)))/6;
% perPWRC_FR(27,:) = (abs(perPWRC_FR(8,:))+abs(perPWRC_FR(9,:))+abs(perPWRC_FR(10,:))+abs(perPWRC_FR(11,:))+abs(perPWRC_FR(12,:))+abs(perPWRC_FR(13,:)))/6;
% 
% perSRCC_FR(28,:) = (abs(perSRCC_FR(14,:))+abs(perSRCC_FR(15,:))+abs(perSRCC_FR(16,:))+abs(perSRCC_FR(17,:))+abs(perSRCC_FR(18,:))+abs(perSRCC_FR(19,:)))/6;
% perKRCC_FR(28,:) = (abs(perKRCC_FR(14,:))+abs(perKRCC_FR(15,:))+abs(perKRCC_FR(16,:))+abs(perKRCC_FR(17,:))+abs(perKRCC_FR(18,:))+abs(perKRCC_FR(19,:)))/6;
% perRMSE_FR(28,:) = (abs(perRMSE_FR(14,:))+abs(perRMSE_FR(15,:))+abs(perRMSE_FR(16,:))+abs(perRMSE_FR(17,:))+abs(perRMSE_FR(18,:))+abs(perRMSE_FR(19,:)))/6;
% perPLCC_FR(28,:) = (abs(perPLCC_FR(14,:))+abs(perPLCC_FR(15,:))+abs(perPLCC_FR(16,:))+abs(perPLCC_FR(17,:))+abs(perPLCC_FR(18,:))+abs(perPLCC_FR(19,:)))/6;
% perPWRC_FR(28,:) = (abs(perPWRC_FR(14,:))+abs(perPWRC_FR(15,:))+abs(perPWRC_FR(16,:))+abs(perPWRC_FR(17,:))+abs(perPWRC_FR(18,:))+abs(perPWRC_FR(19,:)))/6;
% 
% perSRCC_FR(29,:) = (abs(perSRCC_FR(20,:))+abs(perSRCC_FR(21,:))+abs(perSRCC_FR(22,:))+abs(perSRCC_FR(23,:))+abs(perSRCC_FR(24,:))+abs(perSRCC_FR(25,:)))/6;
% perKRCC_FR(29,:) = (abs(perKRCC_FR(20,:))+abs(perKRCC_FR(21,:))+abs(perKRCC_FR(22,:))+abs(perKRCC_FR(23,:))+abs(perKRCC_FR(24,:))+abs(perKRCC_FR(25,:)))/6;
% perRMSE_FR(29,:) = (abs(perRMSE_FR(20,:))+abs(perRMSE_FR(21,:))+abs(perRMSE_FR(22,:))+abs(perRMSE_FR(23,:))+abs(perRMSE_FR(24,:))+abs(perRMSE_FR(25,:)))/6;
% perPLCC_FR(29,:) = (abs(perPLCC_FR(20,:))+abs(perPLCC_FR(21,:))+abs(perPLCC_FR(22,:))+abs(perPLCC_FR(23,:))+abs(perPLCC_FR(24,:))+abs(perPLCC_FR(25,:)))/6;
% perPWRC_FR(29,:) = (abs(perPWRC_FR(20,:))+abs(perPWRC_FR(21,:))+abs(perPWRC_FR(22,:))+abs(perPWRC_FR(23,:))+abs(perPWRC_FR(24,:))+abs(perPWRC_FR(25,:)))/6;

%% For code 'Baseline' and deeplearning cross=2


for i = 1:size(files_path,1)
    file_name = files_path{i,1};
    [numeric_r,text_r,raw_r] = xlsread(file_name);
    %numeric_r = fliplr(numeric_r);
    result = [numeric_r(1:2:900);numeric_r(2:2:900)];
    score_FR(:,i) = result;

    for j = 1:2     
        scoreNewTemp = score_FR(:,i);
        scoreNew = scoreNewTemp;
        GTNew = GT;
        MOSNew = MOS;
        SDNew = SD;

        scoreNew = scoreNewTemp(find(DatasetType==j));
        GTNew = GT(find(DatasetType==j));
        MOSNew = MOS(find(DatasetType==j));
        SDNew = SD(find(DatasetType==j));
        perSRCC_FR(j+1,i) = corr(scoreNew,GTNew,'type','Spearman');
        perKRCC_FR(j+1,i) = corr(scoreNew,GTNew,'type','Kendall');
        [delta,beta,yhat,y,diff] = findrmse2(scoreNew,GTNew);
        perRMSE_FR(j+1,i) = sqrt(sum(diff.^2)/length(diff));
        perPLCC_FR(j+1,i) = corr(GTNew, yhat, 'type','Pearson');
        perPWRC_FR(j+1,i) = calPWRC(scoreNew, MOSNew, SDNew);
    end

    for j = 1:2     % 0.75
        scoreNewTemp = score_FR(:,i);
        scoreNew = scoreNewTemp(find(DistortionType==1));
        GTNew = GT(find(DistortionType==1));
        MOSNew = MOS(find(DistortionType==1));
        SDNew = SD(find(DistortionType==1));
        % scoreNew = scoreNewTemp(find(DistortionType1==1&DatasetType==j));
        % GTNew = GT(find(DistortionType1==1&DatasetType==j));
        % MOSNew = MOS(find(DistortionType1==1&DatasetType==j));
        % SDNew = SD(find(DistortionType1==1&DatasetType==j));
        perSRCC_FR(j+3,i) = corr(scoreNew,GTNew,'type','Spearman');
        perKRCC_FR(j+3,i) = corr(scoreNew,GTNew,'type','Kendall');
        [delta,beta,yhat,y,diff] = findrmse2(scoreNew,GTNew);
        perRMSE_FR(j+3,i) = sqrt(sum(diff.^2)/length(diff));
        perPLCC_FR(j+3,i) = corr(GTNew, yhat, 'type','Pearson');
        perPWRC_FR(j+3,i) = calPWRC(scoreNew, MOSNew, SDNew);
    end

    for j = 1:2     % 0.5
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

perSRCC_FR(10,:) = (abs(perSRCC_FR(2,:))+abs(perSRCC_FR(3,:)))/2;
perKRCC_FR(10,:) = (abs(perKRCC_FR(2,:))+abs(perKRCC_FR(3,:)))/2;
perRMSE_FR(10,:) = (abs(perRMSE_FR(2,:))+abs(perRMSE_FR(3,:)))/2;
perPLCC_FR(10,:) = (abs(perPLCC_FR(2,:))+abs(perPLCC_FR(3,:)))/2;
perPWRC_FR(10,:) = (abs(perPWRC_FR(2,:))+abs(perPWRC_FR(3,:)))/2;

perSRCC_FR(11,:) = (abs(perSRCC_FR(4,:))+abs(perSRCC_FR(5,:)))/2;
perKRCC_FR(11,:) = (abs(perKRCC_FR(4,:))+abs(perKRCC_FR(5,:)))/2;
perRMSE_FR(11,:) = (abs(perRMSE_FR(4,:))+abs(perRMSE_FR(5,:)))/2;
perPLCC_FR(11,:) = (abs(perPLCC_FR(4,:))+abs(perPLCC_FR(5,:)))/2;
perPWRC_FR(11,:) = (abs(perPWRC_FR(4,:))+abs(perPWRC_FR(5,:)))/2;

perSRCC_FR(12,:) = (abs(perSRCC_FR(6,:))+abs(perSRCC_FR(7,:)))/2;
perKRCC_FR(12,:) = (abs(perKRCC_FR(6,:))+abs(perKRCC_FR(7,:)))/2;
perRMSE_FR(12,:) = (abs(perRMSE_FR(6,:))+abs(perRMSE_FR(7,:)))/2;
perPLCC_FR(12,:) = (abs(perPLCC_FR(6,:))+abs(perPLCC_FR(7,:)))/2;
perPWRC_FR(12,:) = (abs(perPWRC_FR(6,:))+abs(perPWRC_FR(7,:)))/2;

perSRCC_FR(13,:) = (abs(perSRCC_FR(8,:))+abs(perSRCC_FR(9,:)))/2;
perKRCC_FR(13,:) = (abs(perKRCC_FR(8,:))+abs(perKRCC_FR(9,:)))/2;
perRMSE_FR(13,:) = (abs(perRMSE_FR(8,:))+abs(perRMSE_FR(9,:)))/2;
perPLCC_FR(13,:) = (abs(perPLCC_FR(8,:))+abs(perPLCC_FR(9,:)))/2;
perPWRC_FR(13,:) = (abs(perPWRC_FR(8,:))+abs(perPWRC_FR(9,:)))/2;