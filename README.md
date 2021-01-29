# 3D-Indentation
This github contains Matlab code and general technical information corresponding to manuscript NCOMMS-20-20823-T.

For code related to the simulation of pollen grain indentations, please access the following github: https://github.com/GabriellaMosca/PollenGrain_indentation

Matlab evaluation of indentations:
The Matlab code has been used for the evaluation of mechanical characterisations of pollen grains as well as C. elegans. Using indentation-based characterisations, the local apparent stiffness of the corresponding specimen has been extracted.

For demonstration purposes, example data of two indentations performed on different regions of the same Lilium longiflorum pollen grain, i.e. on the intine as well as exine, is available on this repository. Additionally, indentations data for solid glass is available to detect the internal stiffness of the setup and allow for the corresponding correction of the experimental result. For the expected of the analysis, please have a look at the files *_result.jpg.

Setup information:
Furthermore, to simplify reproducibility of the experiments through interested readers, the technical drawing of the sensor holder (designed and fabricated by Daniel Bollier) and a .dwg-file of the mask used for the soft-lithography fabrication of the acoustic manipulation device (designed and fabrication by Nino Läubli) have been made available. Additionally, the source data of the graphs presented in NCOMMS-20-20823-T is provided in an Excel file.
Further information on the setup components can be found in Vogler et al. (2020), Chapter 17 - Simultaneous measurement of turgor pressure and cell wall elasticity in growing pollen tubes, in Plant Cell Biology (pp. 297 - 310), Academic Press, doi: 10.1016/bs.mcb.2020.04.002


# Instructions for Matlab Code
To calculate the system's internal stiffness, please run the following file in Matlab: Correction_of_system_stiffness.m
The extracted system stiffness (derived through the indentation of glass), is saved in system_stiffness.txt and plot (.png and .fig) are produced for each measurement to allow for manual check of possible errors or unsuitable linearisations.

Input the average value of the system's internal stiffness in AnalyzeGraph.m and specify the indentation experiment to be analysed.
The data of the indentation experiment will be plotted in combination with a smoothed version to reduce noise. Additionally, the force-distance curve will be linearised to allow for the extraction of the apparent stiffness and the result will be displayed in the generated .jpg file.

The code has been tested on Matlab R2020b and has a run time of less than 30 seconds.
