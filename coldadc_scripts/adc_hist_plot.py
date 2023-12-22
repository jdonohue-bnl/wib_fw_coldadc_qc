import sys 
import numpy as np
import pickle, struct
import time, datetime, random, statistics
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

fp = sys.argv[1]
sfn = fp.split("/") #default
if "/" in fp:
    sfn = fp.split("/")
elif "\\" in fp:
    sfn = fp.split("\\")
p = fp.find(sfn[-1])
fdir = fp[0:p]

with open(fp, 'rb') as fn:
    hist_data = pickle.load(fn)
    

fig, ax = plt.subplots(figsize=(10,6)) #one "FEMB"
num_bins = 50
x = np.arange(0,pow(2,14)+1)
real_max = 0 #for stuff with a lot of data outside bounds
for ch, ch_hist_data in enumerate(hist_data):
    
    
    
    # ch_group = int(ch % 16 < 8)    
    chip = ch // 16
    

        
    #decode from raw memory:
    num_32bwords = 0x8000 / 4
    num_16bwords = 0x8000 / 2
    
    words16b = list(struct.unpack_from("<%dH"%(num_16bwords),ch_hist_data))
    # print("Parse 16 bit words")
    # for bin_id, height in enumerate(words16b):
        # if height != 0:
            # print("Word",hex(bin_id),"is",hex(height))
    
    
    # words32b = list(struct.unpack_from("<%dI"%(num_32bwords),ch_hist_data))
    # print("parse 32 bit words")
    # for bin_id, height in enumerate(words32b):
        # if height != 0:
            # print("Word",hex(bin_id),"is",hex(height))        
    # exit()
    
    # ax.bar(x, ch_hist_data, linewidth=1, edgecolor='C%d'%chip, facecolor='C%d'%chip)
    # ax.hist(chdata_unordered,num_bins,color='C%d'%chip)
    # print(np.histogram(chdata_unordered))
    
    #for stuff with a lot of data outside the range of the ADC:
    if any(height > real_max for height in words16b[1:-1]): 
        # for binid, height in words16b[1:-1]:
            # if height > real_max:
                # print(binid,":",height)
        real_max = max(words16b[1:-1])    
    
    # #check for missing codes
    # if any(height == 0 for height in words16b):
        # print(binid,":",height)
    
    ax.stairs(words16b, x, fill=True, color='C%d'%chip)
    
    # ax.hist(chdata_unordered,bins=num_bins,color='C%d'%chip)
    
    print(ch)
# plt.xticks(ticks=[0x48d, 0x2af3]) #<- the 2 values expected from test pattern   
# ax.get_xaxis().set_major_formatter(ticker.FormatStrFormatter("0x%x"))

# plt.title("ADC Histogram w/ No Pulse (2000 samples)")
# plt.title("ADC Histogram w/ DAC constant voltage of ~1.22V (2000 samples)")
# plt.title("ADC Histogram w/ Test Pattern (2000 samples)")
# plt.title("ADC Histogram Ch %d w/ Test Pattern (2000 samples)"%(ch))

#for stuff with a lot of data outside bounds
# print(real_max)


# plt.ylim([0,100+max([np.median(ch_hist_data) for ch_hist_data in hist_data])])
#plt.ylim([0,real_max+10])
plt.ylim([0,250])

plt.savefig(fdir+"adc_hist.jpg")





# plt.savefig(fdir+"adc_hist"+str(ch)+".jpg")

plt.close()
