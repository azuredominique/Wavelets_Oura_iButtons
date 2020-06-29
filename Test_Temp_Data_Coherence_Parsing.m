Testfig=figure;
plot(AzTestTemps(:,2),'color','k','LineWidth',2); hold on; plot(AzTestTemps(:,3),'color',[0 0.3 1],'LineWidth',2);
plot(AzTestTemps(:,4),'color','r','LineWidth',2); plot(AzTestTemps(:,5),'color',[ 0.5 0.5 0.5],'LineWidth',2);

ylim([65 100]); xlim([0 1440*2.1/5]);
xticks([1:60/5:1440*3/5]);
xticklabels({'11','12','1','2','3','4','5','6','7','8','9','10','11','12','1','2','3',...
    '4','5','6','7','8','9','10','11','12','1','2','3','4','5','6','7','8','9','10','11',...
    '12','1','2','3','4','5','6','7','8','9','10','11','12','1','2','3','4'});

Testfig=figure;
plot(zscore(AzTestTemps(:,2)),'color','k','LineWidth',2); hold on; plot(zscore(AzTestTemps(:,3)),'color',[0 0.3 1],'LineWidth',2);
plot(zscore(AzTestTemps(:,4)),'color','r','LineWidth',2);  plot(zscore(AzTestTemps(:,5)),'color',[ 0.5 0.5 0.5],'LineWidth',2);
ylim([-3.5 2]); xlim([0 1440*2.1/5]);
xticks([1:60/5:1440*3/5]);
xticklabels({'11','12','1','2','3','4','5','6','7','8','9','10','11','12','1','2','3',...
    '4','5','6','7','8','9','10','11','12','1','2','3','4','5','6','7','8','9','10','11',...
    '12','1','2','3','4','5','6','7','8','9','10','11','12','1','2','3','4'});

figure; subplot(3,1,1); wcoherence(AzTestTemps(:,4),AzTestTemps(1:length(AzTestTemps(:,4)),5), hours(5/60),'PhaseDisplayThreshold',0.75); title('Axial to Environment');
subplot(3,1,2);wcoherence(AzTestTemps(:,3),AzTestTemps(1:length(AzTestTemps(:,3)),5), hours(5/60),'PhaseDisplayThreshold',0.75);  title('Wrist to Environment');
subplot(3,1,3);wcoherence(AzTestTemps(:,2),AzTestTemps(1:length(AzTestTemps(:,2)),5), hours(5/60),'PhaseDisplayThreshold',0.75);  title('Finger to Environment');


figure;
subplot(3,1,1); wcoherence(AzTestTemps(:,4),AzTestTemps(1:length(AzTestTemps(:,4)),3), hours(5/60),'PhaseDisplayThreshold',0.75);title('Axial to Wrist');
subplot(3,1,2); wcoherence(AzTestTemps(:,4),AzTestTemps(1:length(AzTestTemps(:,4)),2), hours(5/60),'PhaseDisplayThreshold',0.75);title('Axial to Finger');
subplot(3,1,3); wcoherence(AzTestTemps(:,2),AzTestTemps(1:length(AzTestTemps(:,2)),3), hours(5/60),'PhaseDisplayThreshold',0.75);title('Finger to Wrist');




%% Ok, Reacquainting myself with what data I have for a validation of QCycle iButton

DistalRow=4; AxialRow=5; FingerRow=6; OvWinDistalRow=9; OvWinAxialRow=10; OvWinFingerRow=11;
CycleColumnsWithDistalAxialFinger=[3,4,9,14,27,29,33,34,35,38,41,42,48,49,52,53];
%CycleColumnsWithDistalFingerOnly
%CycleColumnsWithAxialFingerOnly


%% Create Matrices of Wavelet Coherence and Phase Angle 
%Well, none of the scatters look like anything. 
%lets make an average coherence plot and be done with it. 

%DayHealthyCoherences=figure;
for i=14:length(CycleColumnsWithDistalAxialFinger);
    %row 1 is Distal to Finger
   [wcoh{1,i},wcs{1,i}]=wcoherence(NewQCycleDataAdjusted{DistalRow,CycleColumnsWithDistalAxialFinger(i)}(1:1440*25),NewQCycleDataAdjusted{FingerRow,CycleColumnsWithDistalAxialFinger(i)}(1:1440*25),minutes(1)); %for some reason this function has a hard time with (hours(1/60));
   PhysAng1{1,i} = angle(wcs{1,i}); %Save out a matrix of phase angles for every position; use this later in the network (as color?)
   
   %row 2 is Distal to Axial
   [wcoh{2,i},wcs{2,i}]=wcoherence(NewQCycleDataAdjusted{DistalRow,CycleColumnsWithDistalAxialFinger(i)}(1:1440*25),NewQCycleDataAdjusted{AxialRow,CycleColumnsWithDistalAxialFinger(i)}(1:1440*25),minutes(1)); %for some reason this function has a hard time with (hours(1/60));
   PhysAng1{2,i} = angle(wcs{2,i}); %Save out a matrix of phase angles for every position; use this later in the network (as color?)
  
   %row 3 is Axial to Finger
    [wcoh{3,i},wcs{3,i}]=wcoherence(NewQCycleDataAdjusted{AxialRow,CycleColumnsWithDistalAxialFinger(i)}(1:1440*25),NewQCycleDataAdjusted{FingerRow,CycleColumnsWithDistalAxialFinger(i)}(1:1440*25),minutes(1)); %for some reason this function has a hard time with (hours(1/60));
   PhysAng1{3,i} = angle(wcs{3,i}); %Save out a matrix of phase angles for every position; use this later in the network (as color?)
   disp(i)
end

%Extract Coherence Bands 

for i=[1:7,9:length(CycleColumnsWithDistalAxialFinger)-3];
    for j=1:3
    wcoh1to2{j,i}=max(movmean(wcoh{1,i} (14:37,:),60),[],1); %1 to 2 hour band
    PhysAng1to2{j,i}=max(movmean(PhysAng1{1,i} (14:37,:),60),[],1); %corresponding max phase angle in the band
      wcoh2to3{j,i}=max(movmean(wcoh{1,i} (37:50,:),60),[],1); %2 to 3 hour band
    PhysAng2to3{j,i}=max(movmean(PhysAng1{1,i} (37:50,:),60),[],1); %corresponding max phase angle in the band

      wcoh3to4{j,i}=max(movmean(wcoh{1,i} (50:60,:),60),[],1); %3 to 4 hour band
    PhysAng3to4{j,i}=max(movmean(PhysAng1{1,i} (50:60,:),60),[],1); %corresponding max phase angle in the band

     wcoh4to5{j,i}=max(movmean(wcoh{1,i} (60:65,:),60),[],1); %4 to 5 hour band
    PhysAng4to5{j,i}=max(movmean(PhysAng1{1,i} (60:65,:),60),[],1); %corresponding max phase angle in the band

     wcoh2to5{j,i}=max(movmean(wcoh{1,i} (37:65,:),60),[],1); %2 to 5 hour band
    PhysAng2to5{j,i}=max(movmean(PhysAng1{1,i} (37:65,:),60),[],1); %corresponding max phase angle
    
     wcoh5to9{j,i}=max(movmean(wcoh{1,i} (66:85,:),60),[],1); % 5 to 9 H band
    PhysAng5to9{j,i}=max(movmean(PhysAng1{1,i} (66:85,:),60),[],1);
    
     wcohcirc{j,i}=max(movmean(wcoh{1,i} (108:118,:),60),[],1); %23-25 h Band (Circad9an)
    PhysAngcirc{j,i}=max(movmean(PhysAng1{1,i} (108:118,:),60),[],1);
    
      wcoh10to12{j,i}=max(movmean(wcoh{1,i} (88:95,:),60),[],1); %10-12 h Band LOOKS GREAT
    PhysAng10to12{j,i}=max(movmean(PhysAng1{1,i} (88:95,:),60),[],1);%10-12 h
    disp(i)   
    end
end

% Run this segment once for each set of 2 outputs you want to compare
%Change name of wcohs for averaging when you want to do so.
for a=[1:7,9:length(CycleColumnsWithDistalAxialFinger)-3];
%      wcohsforaveraging1to2DtoF(:,a)=wcoh1to2{1,a}(1,:);
%      wcohsforaveraging2to3DtoF(:,a)=wcoh2to3{1,a}(1,:);
%      wcohsforaveraging3to4DtoF(:,a)=wcoh3to4{1,a}(1,:);
%      wcohsforaveraging4to5DtoF(:,a)=wcoh4to5{1,a}(1,:);
%      wcohsforaveraging5to9DtoF(:,a)=wcoh5to9{1,a}(1,:);
%      wcohsforaveragingcircDtoF(:,a)=wcohcirc{1,a}(1,:);
%      wcohsforaveraging10to12DtoF(:,a)=wcoh10to12{1,a}(1,:);

     wcohsforaveraging1to2DtoA(:,a)=wcoh1to2{2,a}(1,:);
     wcohsforaveraging2to3DtoA(:,a)=wcoh2to3{2,a}(1,:);
     wcohsforaveraging3to4DtoA(:,a)=wcoh3to4{2,a}(1,:);
     wcohsforaveraging4to5DtoA(:,a)=wcoh4to5{2,a}(1,:);
     wcohsforaveraging5to9DtoA(:,a)=wcoh5to9{2,a}(1,:);
     wcohsforaveragingcircDtoA(:,a)=wcohcirc{2,a}(1,:);
     wcohsforaveraging10to12DtoA(:,a)=wcoh10to12{2,a}(1,:);
     
     wcohsforaveraging1to2AtoF(:,a)=wcoh1to2{3,a}(1,:);
     wcohsforaveraging2to3AtoF(:,a)=wcoh2to3{3,a}(1,:);
     wcohsforaveraging3to4AtoF(:,a)=wcoh3to4{3,a}(1,:);
     wcohsforaveraging4to5AtoF(:,a)=wcoh4to5{3,a}(1,:);
     wcohsforaveraging5to9AtoF(:,a)=wcoh5to9{3,a}(1,:);
     wcohsforaveragingcircAtoF(:,a)=wcohcirc{3,a}(1,:);
     wcohsforaveraging10to12AtoF(:,a)=wcoh10to12{3,a}(1,:);
     

    disp(a);
end

%% Averaging across coherence bands D to F
MeanwcohcircDtoF=mean(movmean(wcohsforaveragingcircDtoF(:,[1:8,9:13]),1440),2);StdevwcohcircDtoF=mean(movstd(wcohsforaveragingcircDtoF(:,[1:8,9:13]),60*4,0,2),2)./3;
Meanwcoh1to2DtoF=mean(wcohsforaveraging1to2DtoF(:,[1:8,9:13]),2);Stdevwcoh1to2DtoF=mean(movstd(wcohsforaveraging1to2DtoF(:,[1:8,9:13]),60*4,0,2),2)./3;
Meanwcoh3to4DtoF=mean(movmean(wcohsforaveraging3to4DtoF(:,[1:8,9:13]),20),2);Stdevwcoh3to4DtoF=mean(movstd(wcohsforaveraging3to4DtoF(:,[1:8,9:13]),60*4,0,2),2)./3;
Meanwcoh2to3DtoF=mean(movmean(wcohsforaveraging2to3DtoF(:,[1:8,9:13]),20),2);Stdevwcoh2to3DtoF=mean(movstd(wcohsforaveraging2to3DtoF(:,[1:8,9:13]),60*4,0,2),2)./3;
Meanwcoh4to5DtoF=mean(movmean(wcohsforaveraging4to5DtoF(:,[1:8,9:13]),20),2);Stdevwcoh4to5DtoF=mean(movstd(wcohsforaveraging4to5DtoF(:,[1:8,9:13]),60*4,0,2),2)./3;
Meanwcoh5to9DtoF=mean(movmean(wcohsforaveraging5to9DtoF(:,[1:8,9:13]),20),2);Stdevwcoh5to9DtoF=mean(movstd(wcohsforaveraging5to9DtoF(:,[1:8,9:13]),60*4,0,2),2)./3;


%Stdev is currently formatted as SEM with Number of samples = 25 (# of
%days); now number of people (9)

%circadian
figure; plot(mean(wcohsforaveragingcircDtoF,2),'color',[0 0.3 0.9],'LineWidth',3);
hold on;x=1:length(MeanwcohcircDtoF+StdevwcohcircDtoF);a=fill([x fliplr(x)],[(MeanwcohcircDtoF+StdevwcohcircDtoF)' flipud(MeanwcohcircDtoF-StdevwcohcircDtoF)'],[0 0.3 0.9]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);

% 3 to 4 h
figure; plot(mean(wcohsforaveraging3to4DtoF,2),'color',[0 0.3 0.9],'LineWidth',3);
hold on;x=1:length(Meanwcoh3to4DtoF+Stdevwcoh3to4DtoF);a=fill([x fliplr(x)],[(Meanwcoh3to4DtoF+Stdevwcoh3to4DtoF)' flipud(Meanwcoh3to4DtoF-Stdevwcoh3to4DtoF)'],[0 0.3 0.9]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);

% 1 to 2 h
figure; plot(mean(wcohsforaveraging1to2DtoF,2),'color',[0 0.3 0.9],'LineWidth',3);
hold on;x=1:length(Meanwcoh1to2DtoF+Stdevwcoh1to2DtoF);a=fill([x fliplr(x)],[(Meanwcoh1to2DtoF+Stdevwcoh1to2DtoF)' flipud(Meanwcoh1to2DtoF-Stdevwcoh1to2DtoF)'],[0 0.3 0.9]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);

%5to9
figure; plot(mean(wcohsforaveraging5to9DtoF,2),'color',[0 0.3 0.9],'LineWidth',3);
hold on;x=1:length(Meanwcoh5to9DtoF+Stdevwcoh5to9DtoF);a=fill([x fliplr(x)],[(Meanwcoh5to9DtoF+Stdevwcoh5to9DtoF)' flipud(Meanwcoh5to9DtoF-Stdevwcoh5to9DtoF)'],[0 0.3 0.9]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);

%4to 5
figure; plot(mean(wcohsforaveraging4to5DtoF,2),'color',[0 0.3 0.9],'LineWidth',3);
hold on;x=1:length(Meanwcoh4to5DtoF+Stdevwcoh4to5DtoF);a=fill([x fliplr(x)],[(Meanwcoh4to5DtoF+Stdevwcoh4to5DtoF)' flipud(Meanwcoh4to5DtoF-Stdevwcoh4to5DtoF)'],[0 0.3 0.9]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);

%2 to3 
figure; plot(mean(wcohsforaveraging2to3DtoF,2),'color',[0 0.3 0.9],'LineWidth',3);
hold on;x=1:length(Meanwcoh2to3DtoF+Stdevwcoh2to3DtoF);a=fill([x fliplr(x)],[(Meanwcoh2to3DtoF+Stdevwcoh2to3DtoF)' flipud(Meanwcoh2to3DtoF-Stdevwcoh2to3DtoF)'],[0 0.3 0.9]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);

%% Averaging across coherence bands A to F

MeanwcohcircAtoF=mean(movmean(wcohsforaveragingcircAtoF(:,[1:8,9:13]),1440),2);StdevwcohcircAtoF=mean(movstd(wcohsforaveragingcircAtoF(:,[1:8,9:13]),60*4,0,2),2)./3;
Meanwcoh1to2AtoF=mean(wcohsforaveraging1to2AtoF(:,[1:8,9:13]),2);Stdevwcoh1to2AtoF=mean(movstd(wcohsforaveraging1to2AtoF(:,[1:8,9:13]),60*4,0,2),2)./3;
Meanwcoh3to4AtoF=mean(movmean(wcohsforaveraging3to4AtoF(:,[1:8,9:13]),20),2);Stdevwcoh3to4AtoF=mean(movstd(wcohsforaveraging3to4AtoF(:,[1:8,9:13]),60*4,0,2),2)./3;
Meanwcoh2to3AtoF=mean(movmean(wcohsforaveraging2to3AtoF(:,[1:8,9:13]),20),2);Stdevwcoh2to3AtoF=mean(movstd(wcohsforaveraging2to3AtoF(:,[1:8,9:13]),60*4,0,2),2)./3;
Meanwcoh4to5AtoF=mean(movmean(wcohsforaveraging4to5AtoF(:,[1:8,9:13]),20),2);Stdevwcoh4to5AtoF=mean(movstd(wcohsforaveraging4to5AtoF(:,[1:8,9:13]),60*4,0,2),2)./3;
Meanwcoh5to9AtoF=mean(movmean(wcohsforaveraging5to9AtoF(:,[1:8,9:13]),20),2);Stdevwcoh5to9AtoF=mean(movstd(wcohsforaveraging5to9AtoF(:,[1:8,9:13]),60*4,0,2),2)./3;



figure; plot(mean(wcohsforaveraging2to3AtoF,2),'color',[0.9 0 0.1],'LineWidth',3);
hold on;x=1:length(Meanwcoh2to3AtoF+Stdevwcoh2to3AtoF);a=fill([x fliplr(x)],[(Meanwcoh2to3AtoF+Stdevwcoh2to3AtoF)' flipud(Meanwcoh2to3AtoF-Stdevwcoh2to3AtoF)'],[0.9 0 0.1]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '-7','-6', '-5','-4','-3','-2','-1','LH','1','2','3','4','5' '6' '7'});
xlim([0 20161]); %ylim([45 75]);
ylim([0 1]);
%circadian
figure; plot(mean(wcohsforaveragingcircAtoF,2),'color',[0.9 0 0.1],'LineWidth',3);
hold on;x=1:length(MeanwcohcircAtoF+StdevwcohcircAtoF);a=fill([x fliplr(x)],[(MeanwcohcircAtoF+StdevwcohcircAtoF)' flipud(MeanwcohcircAtoF-StdevwcohcircAtoF)'],[0.9 0 0.1]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);

% 3 to 4 h
figure; plot(mean(wcohsforaveraging3to4AtoF,2),'color',[0.9 0 0.1],'LineWidth',3);
hold on;x=1:length(Meanwcoh3to4AtoF+Stdevwcoh3to4AtoF);a=fill([x fliplr(x)],[(Meanwcoh3to4AtoF+Stdevwcoh3to4AtoF)' flipud(Meanwcoh3to4AtoF-Stdevwcoh3to4AtoF)'],[0.9 0 0.1]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);

% 1 to 2 h
figure; plot(mean(wcohsforaveraging1to2AtoF,2),'color',[0.9 0 0.1],'LineWidth',3);
hold on;x=1:length(Meanwcoh1to2AtoF+Stdevwcoh1to2AtoF);a=fill([x fliplr(x)],[(Meanwcoh1to2AtoF+Stdevwcoh1to2AtoF)' flipud(Meanwcoh1to2AtoF-Stdevwcoh1to2AtoF)'],[0.9 0 0.1]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);

%5to9
figure; plot(mean(wcohsforaveraging5to9AtoF,2),'color',[0.9 0 0.1],'LineWidth',3);
hold on;x=1:length(Meanwcoh5to9AtoF+Stdevwcoh5to9AtoF);a=fill([x fliplr(x)],[(Meanwcoh5to9AtoF+Stdevwcoh5to9AtoF)' flipud(Meanwcoh5to9AtoF-Stdevwcoh5to9AtoF)'],[0.9 0 0.1]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);

%4to 5
figure; plot(mean(wcohsforaveraging4to5AtoF,2),'color',[0.9 0 0.1],'LineWidth',3);
hold on;x=1:length(Meanwcoh4to5AtoF+Stdevwcoh4to5AtoF);a=fill([x fliplr(x)],[(Meanwcoh4to5AtoF+Stdevwcoh4to5AtoF)' flipud(Meanwcoh4to5AtoF-Stdevwcoh4to5AtoF)'],[0.9 0 0.1]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);

%2 to3 
figure; plot(mean(wcohsforaveraging2to3AtoF,2),'color',[0.9 0 0.1],'LineWidth',3);
hold on;x=1:length(Meanwcoh2to3AtoF+Stdevwcoh2to3AtoF);a=fill([x fliplr(x)],[(Meanwcoh2to3AtoF+Stdevwcoh2to3AtoF)' flipud(Meanwcoh2to3AtoF-Stdevwcoh2to3AtoF)'],[0.9 0 0.1]); alpha(0.05); set(a,'EdgeColor','none')
xticks([ 1:1440:1440*25]); xticklabels({ '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25'});
xlim([0 1440*25]); %ylim([45 75]);
ylim([0 1]);


%% Make the daily rhythm of ultradian coherence intuitive!

dailyrofcoherence=figure;

plot(NewQCycleDataAdjusted{DistalRow,CycleColumnsWithDistalAxialFinger(i)}(531:1440*25),'color','k','LineWidth','2');
hold on;
plot(NewQCycleDataAdjusted{FingerRow,CycleColumnsWithDistalAxialFinger(i)}(1:1440*25),'color',[0 0.3 1],'LineWidth','2');

%I don't thiink these data are appropriately aligned. For instance on i=13
%delay of 3484 4015

figure;
wcoherence(NewQCycleDataAdjusted{DistalRow,CycleColumnsWithDistalAxialFinger(i)}(531:1440*25),NewQCycleDataAdjusted{FingerRow,CycleColumnsWithDistalAxialFinger(i)}(1:1440*25-530),hours(1/60),'PhaseDisplayThreshold',0.7);

length(NewQCycleDataAdjusted{DistalRow,CycleColumnsWithDistalAxialFinger(i)}(531:1440*25))
