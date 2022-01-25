# Wavelets_Oura_iButtons
Not updated - but reads out HRV, HR, and temp timeseries for oura, for cleaning Oura and iButton timeseries, and for doing wavelet transformations on the data. 

The python script inputs JSON files pulled from oura (for me, these are generated through my Open Humans project "QCycle", which can also be found in this account). HR, HRV and temperature timeseries are extracted and formatted into csvs from the JSON file. 

The Data cleaning and wavelet maker matlab script is meant to take the output CSVs from the python script, make HR, HRV and temperature into minute by minute 1-D timeseries and remove erroneous points.   The wavelet maker in this script is modified from Tanya Leise's matlab code for the morlet wavelet transformation, adapted for circadian and ultradian rhythms. Her paper is here: https://journals.sagepub.com/doi/full/10.1177/0748730411416330 and her webpage (with her original code to do tons more) is here: https://tleise.people.amherst.edu/CircadianWaveletAnalysis.html.  

The Test Data script currently reads out data from my data object that isn't yet shared. So if you want to use the third matlab script to run wavelet coherence, you'll have to add in your variable names. Not annotated/friendly, just quickndirty.
