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
    
v_daq_ref = 2.5 #1.817 #measured on DAT

    
fig = plt.figure(figsize=(30,6)) #one "FEMB"
x = np.arange(1,pow(2,16))
#x = np.arange(8000,8100-1)
# chip = 7
# chn = 2
for chip in range(8): #adc #if True:#
    for chn in range(16): #if True: #
        i = chip*16 + chn
        
        
        
        #adc_dacslope = [dac_setting_ch_avgs[dac_val][i] for dac_val in range(8000,8100)]
        #adc_lsbdiff = [adc_dacslope[dac_val] - adc_dacslope[dac_val-1] for dac_val in range(1,100)]
        adc_dacslope = [dac_setting_ch_avgs[dac_val][i] for dac_val in range(pow(2,16))]
        adc_lsbdiff = [adc_dacslope[dac_val] - adc_dacslope[dac_val-1] for dac_val in range(1,pow(2,16))]
        #print(len(x))
        #print(len(adc_lsbdiff))        
        plt.bar(x, adc_lsbdiff, color = 'C%d'%chip )

        plt.title("DAT ADC Calibration w/ 16-bit DAC (0 to %f V): LSB diffs for Chip %d Chn %d"%(v_daq_ref, chip, chn))
        plt.xlabel("Difference between DAC value X and X-1")
        #plt.xlim(8000,8100)
        plt.savefig(fdir + "adc_lsb_chip" + str(chip) + "_ch" + str(chn) + ".jpg")
        plt.close()        