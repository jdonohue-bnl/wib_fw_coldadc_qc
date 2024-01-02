# wib_fw_coldadc_qc
DUNE WIB firmware repository with additional features for ColdADC QC. 
Does not include updated simulation at this time.

### How to generate a histogram using this firmware:
 1. Compile with binfile generation turned on.
 2. Ensure your C++ firmware library is up to date by doing either of these two things:
	 - Copying coldadc_scripts/wib_util.so directly into [your working directory]/build to just use the library file itself.
	 - The source code for the C++ firmware library is in https://github.com/sgaobnl/BNL_CE_WIB_SW_QC/tree/DAT_FEMB_QC_hermes/src (pull request pending), as well as the build file being in DAT_FEMB_QC_hermes/build. If you downloaded the source code onto the WIB but did not download the build file, run make in the parent directory.
 3. Copy wib_zu6cg/wib_zu6cg.runs/impl_zu6_mono/wib_top.bin over to the WIB.
 4. fpgautil -b wib_top.bin
	 - You need to readjust the FEMB I2C phase adjustment at this point, eg. python3 wib_startup.py
5. Configure FEMBs and trigger spy buffer readout.
6. python3 adc_hist.py [# of samples]
	- A data file will be saved in [cwd]/tmp.
7. python3 adc_hist_plot.py ADC_histfilename.bin
	- A plot of all channel histogram data superimposed will be saved as [cwd]/tmp/adc_hist.jpg.
	- The Python file contains the code necessary to extract histogram data from the binfile.