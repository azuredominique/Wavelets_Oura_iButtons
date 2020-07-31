#!/usr/bin/env python
# coding: utf-8

# # This is a Wavelet script that actually works, huzzah!

# In[1]:


#A wavelet script that works start to finish. 


# In[1]:


import pandas as pd
import numpy as np
import datetime as datetime
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.colors import ListedColormap, LinearSegmentedColormap
import os
import sklearn

# Discrete Wavelet Transform
import pywt

pd.set_option('display.width',500)
get_ipython().run_line_magic('matplotlib', 'inline')


# In[2]:


PRT = os.path.dirname(os.getcwd())
FIG_FOLDER = 'figures'
DATA_FOLDER = '\\Users\\Azure\\Google Drive\\AzureBenjyStuff2\\All Python\\Hot Tamale'
CSV = "Azure_Temps_To_July2019.csv"

DATA_PATH = os.path.join(PRT, DATA_FOLDER)
FILES = [f for f in os.listdir(DATA_PATH) if f[-3:].lower() not in ['jpg', 'ptx']]
print (DATA_PATH)


# In[3]:


original_csv = CSV
df = pd.read_csv(os.path.join(DATA_PATH, original_csv), sep=';', encoding='utf-8', header=0, 
parse_dates=['Local Date', 'Local Time'])
df.rename(columns={'Skin temperature':'temperature', 'Unix time':'unix_time'}, inplace=True)
df.sort_values(by='unix_time', inplace=True)

print (df.shape)
df.head(3)


# In[4]:


# Let's make a dataframe only X Days Long  #this simply takes a window of a specified length starting from the 
# Beginning of the data frame you read in. Change the definition of short_df if you wanna say, start in the middle of the log
s_day = 60*24# samples per day
n_days = 30# number of days to visualize

print (df.shape)
short_df = df.iloc[:n_days*s_day, :].dropna()
print (short_df.shape)


# In[6]:


sampling_period = 1/60# time difference btw two consecutive samples; inverse of sampling frequency
dt = sampling_period#  e.g., 100 Hz sampling.  1 sample per second --> 1 Hz
wavelet = 'cmor1.5-1.0'
scales = range(1,1440)#[60, 120, 360, 720, 1440]# Reasonable choices?  Does 1440 correspond to the daily rhythm?

signal='temperature'  #ok this is the column you are choosing from your data frame

# This function converts from scale domain to frequency domain. Higher scale is lower frequency
f = pywt.scale2frequency(wavelet, scales)/sampling_period# f is hertz when sampling_period in seconds
print ('Frequencies: {}\n'.format(f))
print ('Nyquist limit = {}\n'.format(dt/4))# Per conversation with Adam Rao

coeff, freq = pywt.cwt(df[signal], scales, wavelet, dt) #used to say df[signal]
print (len(coeff[0]), len(freq)) 
power = abs(coeff)**2
power[:5]


# In[8]:


# Using Ahmet's Wavelet Code

# http://ataspinar.com/2018/12/21/a-guide-for-using-the-wavelet-transform-in-machine-learning/

def plot_wavelet_denoised(df, signal):

    def lowpassfilter(signal, thresh, wavelet="db32"):
        thresh = thresh*np.nanmax(signal)
        coeff = pywt.wavedec(signal, wavelet, mode="per" )
        coeff[1:] = (pywt.threshold(i, value=thresh, mode="soft" ) for i in coeff[1:])
        reconstructed_signal = pywt.waverec(coeff, wavelet, mode="per" )
        return reconstructed_signal

    # Original signal
    xrange = list(range(df.shape[0]))
    fig, ax = plt.subplots(figsize=(12,8))
    ax.plot(xrange, df[signal], color="b", alpha=0.25, label='original signal')

    # Smoothing with Discrete Wavelet Transform
    rec = lowpassfilter(df[signal], .40)
    rec = rec[:df.shape[0]]# sometimes the DWT returns a vector one longer than the original signal
    ax.plot(xrange, rec, 'k', label='DWT smoothing}', linewidth=2)

    ax.legend()
    ax.set_title('Removing High Frequency Noise with DWT', fontsize=18)
    ax.set_ylabel('Signal Amplitude', fontsize=16)
    ax.set_xlabel('Sample No', fontsize=16)
    plt.margins(0)
    plt.show()
    return rec

signal = 'temperature'
rec = plot_wavelet_denoised(short_df, signal)


# In[9]:


#And using this nice scalogram plotter kirstin found

#https://dsp.stackexchange.com/questions/62612/plotting-a-scalogram-of-a-signals-continuous-wavelet-transform-cwt-in-python#https://dsp.stackexchange.com/questions/62612/plotting-a-scalogram-of-a-signals-continuous-wavelet-transform-cwt-in-python


#notes from documentation of pwyt.cwt:
#def cwt(signal, dt, dj=1/12, s0=-1, J=-1, wavelet='morlet', freqs=None):
#"""Continuous wavelet transform of the signal at specified scales.

def plot_wavelet(ax, time2, signal, scales, waveletname = 'cmor', 
                 cmap =plt.cm.seismic, title = 'Scalogram', ylabel = '', xlabel = ''):
    dt=time2
    coefficients, frequencies = pywt.cwt(signal, scales, waveletname, dt)

    power = (abs(coefficients)) ** 2
    period = frequencies
    #levels = [0.015625, 0.03125, 0.0625, 0.125, 0.25, 0.5, 1] #futzing with levels
    levels = [ 0.0019, 0.0039, 0.0078, 0.015625, 0.03125, 0.0625, 0.125, 0.25, 0.5 , 1.  , 2,4,8,16,32,64,128,256,512,512*2,512*4,512*8] #0.0039/32, 0.0039/16,0.0004875,0.000975,
    contourlevels = np.log2(levels) #original
    time=range(signal.size)# MIGHT CHANGE THIS - len(signal)

    im = ax.contourf(time, np.log2(period), np.log2(power), contourlevels, extend='both', cmap=cmap)


    ax.set_title(title, fontsize=20)
    ax.set_ylabel(ylabel, fontsize=18)
    ax.set_xlabel(xlabel, fontsize=18)
    yticks = 2**np.arange(np.ceil(np.log2(period.min())), np.ceil(np.log2(period.max())))    
    ax.set_yticks(np.log2(yticks)) #original
    ax.set_yticklabels(yticks) #original
    ax.invert_yaxis()
    ylim = ax.get_ylim()

    cbar_ax = fig.add_axes([0.95, 0.5, 0.03, 0.25])
    fig.colorbar(im, cax=cbar_ax, orientation="vertical")

    return yticks, ylim


# In[25]:


# Voila; wavelet below

fig, ax = plt.subplots(figsize=(12,4))

# Normalize - Azure doesn't get what the '_z' is
s_norm = signal+'_z'
df[s_norm] = (df[signal] - df[signal].mean()) / df[signal].std()

# Alternately zscore

#s = df[s_norm].iloc[1440*60:1440*67].dropna()

# iloc is Purely integer-location based indexing for selection by position.
# .rolling provides rolling window calculations. for temp data we don't want to 
#roll by any frequency that would obliterate anything > 60 min so I've dropped this to 5
#quantile returns only the data within the given decimal specified quantile
#dropna drops rows containing missing values. Not sure what it replaces them with
#hopefully an average value of surrounding data but I need to check

#i got rid of .icol after df[s_norm] might need to put back got rid of .quantile(0.95)
s = df[s_norm].iloc[1:1440*70].rolling(5).quantile(0.99).dropna()


scales = [10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,220,240,260,280, 360, 720,1000,1100,1200,1300,1440, 1600,1800,2000,2100,2200,2300,2400,2500]

plot_wavelet(ax, 1/60, s, scales, waveletname = 'shan8.0-1.0', 
                 cmap =plt.cm.seismic, title = 'test wavelet', ylabel = '', xlabel = 'minutes')

#bandwidth and centre values tested

#in leise code b controls behavior near zero freq. gamma controls high frequency decay

#cmor1.5-1.0

# # Testing Some Coherence Code I found

# In[29]:


#  http://duducosmos.github.io/PIWavelet/
#import numpy as np
#from piwavelet import piwavelet

#This seems to not exist? wtw?

x=signal; 
y=signal;

mycoherence = pywt.wcoherence(x,y)
Rsq,period,scale,coi,sig95=mycoherence()


# In[ ]:




