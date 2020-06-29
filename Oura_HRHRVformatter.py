# -*- coding: utf-8 -*-
"""
Created on Thu Mar 07 12:40:43 2019

@author: Azure
"""



#create a new excel file

#add the contents of the above excel file to it starting in row 2

#append same contents of next file

#save out this new excel file


#the jsondata is a dictionary of size 4 - it has activity; sleep; readiness; and overview potentially

#dependencies
import json
import csv
import simplejson
import numpy as np
import datetime as datetime
from datetime import datetime as dt

#load json data
rawjsondatapath= '\\Users\\Azure\\Google Drive\\Berkeley Grad School\\QCycle\\Oura Data Participants\\K\\K_Oura_OH_05_02_2019.json'
openjson=open(rawjsondatapath).read()

#simplejson is apparently better for reporting errors specifically
jsondata=json.loads(openjson) #used to say simplejson.loads(openjson)

## Moving to Bastian's Code
oura=jsondata 
print('we have data on the following things:')
print(oura.keys())
print('\nour profile is:')
print(oura['profile'])

#how the hell is he arranging the dates? this reads out hr apparently
#this probably reads the dates but not the times...

dates = []
hrs = []
interval = []
bedstarts=[]
bedstartdt=[]

for sdate in oura['sleep']:
    if 'hr_5min' in sdate.keys():
        for i,hr_val in enumerate(sdate['hr_5min']):
            interval.append(i)
            hrs.append(hr_val)
            dates.append(dt.strptime(str(sdate['summary_date']),'%Y-%m-%d').date())  #(sdate['summary_date'])
            bedstarts.append(dt.strptime(str(sdate['bedtime_start'] [11:-6]),'%H:%M:%S').time())
            bedstartdt.append(dt.combine(dates[i], bedstarts[i]))
          #bedstartdt is fucked up is why this is having issue...just plots the first date time
       

            
import pandas as pd
dataframe = pd.DataFrame(
    data = {
        'date': dates,
        'interval': interval,
        'bedstarts': bedstarts,
        'bedstartdt':bedstartdt,
        'heart_rate': hrs,
     
    }
)


        
#now do the same thing for HRVs  
hrvs=[]         
for sdate in oura['sleep']:   
    if 'rmssd_5min' in sdate.keys():
        for i, rmssd_val in enumerate(sdate['rmssd_5min']):
            hrvs.append(rmssd_val)
            
            
#now format HR and HRV by day

splitdaysHR = []
splitdaysHRV=[]
for i in range(len(hrs)):
    if dataframe.iloc[i,4] ==0:
        #splitdaysHR.append(dates[i])
        splitdaysHR.append(hrs[i:i+114])
        splitdaysHRV.append(hrvs[i:i+114])
        
 

hrdataframe=pd.DataFrame((splitdaysHR))
hrdataframe.transpose()
hrdataframe.tail()
#hrdataframe.to_csv('\\Users\\Azure\\Google Drive\\Berkeley Grad School\\QCycle\\Oura Data Participants\\AllDataFromOH_2_28_19\\5df04a86-a4a3-4735-9496-40b2926c28cd\\Mag\\hrframetest.csv')

hrvdataframe=pd.DataFrame((splitdaysHRV))
hrvdataframe.transpose()
hrvdataframe.tail()
#hrvdataframe.to_csv('\\Users\\Azure\\Google Drive\\Berkeley Grad School\\QCycle\\Oura Data Participants\\AllDataFromOH_2_28_19\\5df04a86-a4a3-4735-9496-40b2926c28cd\\Mag\\hrvframetest.csv')

ensembledataframe=pd.concat([hrdataframe, hrvdataframe])

ensembledataframe.to_excel('\\Users\\Azure\\Google Drive\\Berkeley Grad School\\QCycle\\Oura Data Participants\\Kate\\ensembledataframe.xlsx')
dataframe.to_excel('\\Users\\Azure\\Google Drive\\Berkeley Grad School\\QCycle\\Oura Data Participants\\Kate\\dataframeto.xlsx')


#get unique bedtime starts

 # intilize a null list 
   # unique_beddts = [] 
      
    # traverse for all elements 
    #for x in csv_read('\\Users\\Azure\\Google Drive\\Berkeley Grad School\\QCycle\\Oura Data Participants\\AllDataFromOH_2_28_19\\5df04a86-a4a3-4735-9496-40b2926c28cd\\Kate\\dataframe.csv'): 
        # check if exists in unique_list or not 
       # if x not in unique_beddts: 
        #    unique_beddts.append(x) 
    # print list 
    #for x in unique_beddts: 
     #   print x