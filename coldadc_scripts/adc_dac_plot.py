import sys 
import numpy as np
import pickle
import time, datetime, random, statistics
import matplotlib.pyplot as plt

fp = sys.argv[1]
sfn = fp.split("/") #default
if "/" in fp:
    sfn = fp.split("/")
elif "\\" in fp:
    sfn = fp.split("\\")
p = fp.find(sfn[-1])
fdir = fp[0:p]

with open(fp, 'rb') as fn:
    dac_setting_ch_avgs = pickle.load(fn)
    
v_daq_ref = 1.817 #2.5 #measured on DAT

fig = plt.figure(figsize=(10,6)) #one "FEMB"
x = np.arange(0,v_daq_ref,v_daq_ref/pow(2,16))

for chip in range(8): #adc
    for chn in range(16):
        i = chip*16 + chn
        
        adc_dacslope = [dac_setting_ch_avgs[dac_val][i] for dac_val in range(pow(2,16))]
        
        plt.plot(x, adc_dacslope, color = 'C%d'%chip )
        
plt.title("DAT ADC Calibration w/ 16-bit DAC (0 to %f V)"%(v_daq_ref))
#plt.xlim([1.5,1.8])
#plt.ylim([16300,16400])
plt.savefig(fdir + "adc_dacs.jpg")
plt.close()        