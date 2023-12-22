import struct, os, sys
import time, datetime
import pickle
import ctypes

from wib_cfgs import WIB_CFGS



self = WIB_CFGS()



def hist_reg_read(bin_id): #now replaced by histbuf()
    # #address is 14-bit
    # hist_addr = hist_addr & 0x3FFF
    # #turn off hist_write and set address
    # self.poke(0xA00C0074, (hist_addr<<2))   
    # #sleep for >32 ns
    # pass
    # pass
    # pass
    # #read hist_dout  
    # return self.peek(0xA00C00F8)
    
    #New method directly reading from memory:
    hist_baseaddr = 0xA00C8000
    
    #Address to read from is hist_baseaddr + (bin_id / 2) * 4 [4 = 4 bytes / word]
    mem_readout = self.peek(hist_baseaddr + 4 * int(bin_id/2))
    # print("Peeking A00C8000 + "+hex(4 * int(bin_id/2)))
    # if mem_readout != 0:
        # print(hex(mem_readout))
    
    #LSbit of bin count is at position (bin_id mod 2) * 16
    lsb_pos = (bin_id % 2) * 16
    
    return (mem_readout >> lsb_pos) & 0xFFFF # 16 bit result
    
def histbuf(): #adapted from llc.spybuf()
    HIST_MEM_SIZE = 0x8000 #rom A00C8000 to A00CFFFF
    buf = (ctypes.c_char*HIST_MEM_SIZE)()
    buf_bytes = bytearray(HIST_MEM_SIZE)
    

    self.wib.bufread(buf,8) #read from histogram memory
    byte_ptr = (ctypes.c_char*HIST_MEM_SIZE).from_buffer(buf_bytes)            
    if not ctypes.memmove(byte_ptr, buf, HIST_MEM_SIZE):
        print('memmove failed')
        exit()
                
    return buf_bytes 
    
def histbuf_trig(fembs,num_samples=1639000):

    print("WIB histogram test")  
    print("before running this script: configure the FEMB chips and trigger")  


    print("Connecting ADCP channels to WIB external signal")
    # Set ADC_PN_TST_SEL to 0x1 to select TST_PULSE_AMON on the ADC P mux and GND on the ADC N mux
    self.cdpoke(0, 0xC, 0, self.DAT_ADC_PN_TST_SEL, 0x1)

    # Set ADC_TEST_IN_SEL to 0x0 to connect the P&N mux outputs to ADC_test_P and ADC_test_N, respectively
    self.cdpoke(0, 0xC, 0, self.DAT_ADC_TEST_IN_SEL, 0x0)

    # Set ADC_SRC_CS_P_MSB and ADC_SRC_CS_P_LSB both to 0x0 to connect all ColdADC positive and negative 
    # input channels to ADC_test_P and ADC_test_N, respectively.
    self.cdpoke(0, 0xC, 0, self.DAT_ADC_SRC_CS_P_LSB, 0x0)
    self.cdpoke(0, 0xC, 0, self.DAT_ADC_SRC_CS_P_MSB, 0x0)


    #set samples to take
    self.poke(0xA00C007C, num_samples)

    hist_data = []

    #chs = 128
    chs = []
    for femb in fembs:
        for ch in range(128):
            chs.append(femb*128+ch)

    start = time.time()
    #for ch in range(chs):   
    for ch in chs:    
        
        #indicate which channel is to be analyzed
        # self.poke(0xA00C0078, ch | (0x1<<9)) #extra bit is to make sure trigger is output over P12 LEMO
        self.poke(0xA00C0078, ch)
        
        while self.peek(0xA00C00F0) & ~(0x3ff) != 0x000: #wait till monitor output = 0x000
            pass
            
        # if ch == 64:
           # input("Press enter to continue")
        
        #trigger histogram
        self.poke(0xA00C0074, 0x1)
        self.poke(0xA00C0074, 0x0)
        
        num_waits = 0
        while self.peek(0xA00C00F0) & (0x1<<9) == 0: #while hist not done
            num_waits = num_waits + 1
            pass
            
        # #read out data
        # ch_hist_data = []
        # for addr in range(pow(2,14)):
            # ch_hist_data.append(hist_reg_read(addr))
            
        # print(histbuf())
        
        # print("done")
        # exit()
        ch_hist_data = histbuf()
            
        print("Ch",ch) # ,"stats:")
        # for addr,count in enumerate(ch_hist_data):
            # if count != 0:
                # print(count,"counts of ADC value",hex(addr),"num_waits =",num_waits)

        hist_data.append(ch_hist_data)
        
        
        #break #1 ch only

    print("Connecting ADC back to ASIC channels")
    self.cdpoke(0, 0xC, 0, self.DAT_ADC_SRC_CS_P_LSB, 0xFF)
    self.cdpoke(0, 0xC, 0, self.DAT_ADC_SRC_CS_P_MSB, 0xFF)
    
    #Set P12 LEMO output to 10mhz clock
    self.poke(0xA00C0078, 0x0)
    
    return hist_data
    
    
  

if __name__ == "__main__":
    
    fembs = [0]
    if len(sys.argv) > 1:
        num_samples = int(sys.argv[1])
        hist_data = histbuf_trig(fembs,num_samples)
    else:
        #num_samples = 1639000 #default    
        hist_data = histbuf_trig(fembs)

    #write hist_data to file
    fdir = "./tmp_data/"
    ts = datetime.datetime.now().strftime("%d_%m_%Y_%H_%M_%S")
    fp = fdir + "ADChist_" + ts  + ".bin"
    with open(fp, 'wb') as fn:
        pickle.dump(hist_data, fn)  