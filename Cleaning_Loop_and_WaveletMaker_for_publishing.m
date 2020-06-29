%Example wvlt code and and data cleaning code for publishing
%note that wavelet code is adapted from Tanya Leise, Amherst and JLab by
%JM Lily.  %Colormap by Ben Smarr
%% Ben color map definition
Sm = -4:0.01:4;
smarrR = [(0.5:0.005:1) (1:-0.002:0.004) (0:0.005:1)];%{0.5+sin(Sm./1-3)./2;%(801:-1:1)./801;%(1.*Sm.^2+0.5.*Sm+0)./20+0.005; %0.5+sin(Sm./1.5-1.5)./2;
smarrG = [zeros(1,550) (0:0.004:1)]; %(3.^Sm)./81;%1./(1+2.^-Sm);
smarrB = [zeros(1,100) (0:0.0016:1) ones(1,75)];%(1.4.^Sm)./4;%(1:1:801)./801;
figure;hold on; plot(smarrR,'r'); %plot(smarrG,'g'); plot(smarrB,'b');
smarr = [smarrB' smarrG' smarrR'];
Fig_bar = figure; colorbar = (1:0.1:100);% imagesc(colorbar);colormap(smarr);
set(gca,'XTick',[],'YTick',[]);
print(Fig_bar,'-djpeg','-r1000','Color_bar');

%% Cleaning Loop 2/27/2019 for data that starts with 2 columns, the data in column 1 and the excel datetime in column2.
%Tempfile is the dummy variable name for your data, organized as above.

MATLABDate=x2mdate(Tempfile(:,2),1);
matrix=[MATLABDate, Tempfile(:,1)]; 
[~,idx2] = unique(matrix(:,1));   %which rows have a unique first value?
matrix2 = matrix(idx2,:);  %only use those
MATLABDate=matrix2(:,1); Tempfile=matrix2(:,2);
idx = isfinite(MATLABDate) & isfinite(Tempfile(:,1));
MATLABDate=MATLABDate(idx); Tempfile=Tempfile(idx);% will this result in mismatching lenghts or did the & above correct for this
tempfit=fit(MATLABDate,Tempfile,'linearinterp');
ending=MATLABDate(end); start=MATLABDate(1); interval=(start:1/1440:ending); TempString=feval(tempfit, interval); 
figure; plot(TempString); %test plot

a=input('What is the lower limit ');
b=input('What is the upper limit '); 

TempString(TempString<a)=a;
TempString(TempString>b)=b; 

TempString2=TempString;
Deriv=abs(diff(TempString));%previously TempString2
    for k=1:length(Deriv)-60
       if Deriv(k)>=0.4 %0.5 ;
           disp(k); 
           TempString2(k,1)=median(TempString(k:k+60));
       elseif Deriv(k)<=0.05 
           disp(k); 
           TempString2(k,1)=median(TempString(k:k+60));
       else
           disp('cats');
  end
    end
%end
figure; plot(TempString2);

%% Wavelet calculations

%% wavelets. %note that data is automatically detrended
%24h: 336; 9h: 248; 5h: 194; 1h: 45.plot([336, 248, 194, 45],[24 9 5 1]);
%%this is the scale
NstepsPerHr=60; TimeStep=1/NstepsPerHr;
period1=24;  % period in hours of main oscillation
period2=24*56;% period in hours governing the varying frequency or amplitude
Nsteps=24*60*NstepsPerHr+1; t=(0:Nsteps-1)'/NstepsPerHr; T=t(Nsteps)-t(1);
longestperiod=40;shortestperiod=1;  % range of periods to use in AWT
gamma=3;beta=5; % parameter values for Morse wavelet function; g=3,b=5; morse wavelet; no dramatic change with different g,b.
nvoice=64; %this nvoice is much smaller than hers
[fs,tau,qscaleArray] = CalcScaleForCWT(shortestperiod,longestperiod,T,NstepsPerHr,nvoice);
taubnds=round(interp1(tau,1:numel(tau),[1 39])); 

%%%Remember to delete old variables iwt and iWT before running this, other wise it will say subscript mismatch.

clear iwt iWT
for i = 1%:15;
iwt{:,:,i}=wavetrans(zscore(TempString2),{1,gamma,beta,fs,'bandpass'},'periodic'); %reduce resolution as needed %zscore data first to isolate stability rather than amplitude dominating power
iWT{:,:,i} = abs(iwt{:,:,i});
disp(i);
end

%Visualize in 3D
figure;
for i = 1;%7:12%:5; %mod to be list
   % subplot(2,3,i-6);
    imagesc(flipud(iWT{:,:,i}'));
set(gca, 'YTick',[48 110 173 237 339],'YTickLabel',{'24','12','6','3','1'}); colormap(smarr);
%xticks([1440 1440*30 1440*60 1440*90 1440*120 1440*150 1440*180 1448*220 1440*250 1440*280 1440*310]);
%xticklabels({'1', '2', '3','4','5','6','7','8','9','10'});

end

%Excerpting desired wavelet bands

clear URProj
%This divides the wavelet matrix iWT into its hour component bands from
%1-12 (spanning physiologically common UR possibilities) and 23-25 h
%(Circadian band)
URProj{11,1}= movmean(iWT(:,1:39),1440); %1 h
URProj{11,2}=movmean(iWT(:,39:98),1440); %2 h
URProj{11,3}=movmean(iWT(:,98:132),1440); %3 h
URProj{11,4}=movmean(iWT(:,132:156),1440); %4 h
URProj{11,5}=movmean(iWT(:,156:175),1440); %5 h
URProj{11,6}=movmean(iWT(:,175:191),1440); %6 h
URProj{11,7}=movmean(iWT(:,191:204),1440); %7 h
URProj{11,8}=movmean(iWT(:,204:215),1440); %7 h
URProj{11,9}=movmean(iWT(:,215:225),1440); %9 h
URProj{11,10}=movmean(iWT(:,225:234),1440); %10 h
URProj{11,11}=movmean(iWT(:,234:242),1440); %11 h
URProj{11,12}=movmean(iWT(:,242:250),1440); %12 h
CircadianProj{1,1}=movmean(iWT(:,330:339),500); %Vary this


%this takes the mean across each band. Taking the max is a better future
%option for seeing "the peaks along the ridge of power" rather than taking
%a cut through the middle of the mountain (this will make sense if you have
%been observing the 3D wavelet matrices using the surf function)
OnehURProj=mean(URProj{11,1} (:,:),2); %
TwohURProj=mean(URProj{11,2} (:,:),2); %
ThreehURProj=mean(URProj{11,3} (:,:),2);%  
SevenhURProj=mean(URProj{11,7} (:,:),2);
EighthURProj=mean(URProj{11,8} (:,:),2);
NinehURProj=mean(URProj{11,9} (:,:),2);
TenhURProj=mean(URProj{11,10} (:,:),2); % 
ElevenhURProj=mean(URProj{11,11} (:,:),2);%
TwelvehURProj=mean(URProj{11,12} (:,:),2); %

ShortPerURProj=mean([OnehURProj,TwohURProj],2);
MediumPerURProj=mean([OnehURProj,TwohURProj,ThreehURProj],2); %vary to suit your needs
LongPerURProj=mean([TenhURProj,ElevenhURProj,TwelvehURProj],2);