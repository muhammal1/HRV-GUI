# HRV-GUI: A Cross-Species MATLAB Workflow for Heart Rate Variability Analysis

**Developed by:** M. Khawar Ali  
**Affiliation:** University of Michigan, Ann Arbor, USA

## Overview

HRV-GUI is a MATLAB-based graphical user interface developed for ECG-derived heart rate variability (HRV) analysis in preclinical and clinical research.

The software integrates ECG visualization, signal preprocessing, R-peak detection, manual peak correction, RR interval extraction, HRV computation, and visualization within a single graphical environment.

It supports the analysis of human and rat ECG recordings with species-specific processing settings.

## Key Features

- Interactive ECG visualization and segment selection
- Automated R-peak detection with adjustable thresholds
- Manual addition and removal of detected R-peaks
- RR interval extraction and visualization
- Time-domain, frequency-domain, and nonlinear HRV analysis
- Human and rat analysis modes
- Poincaré plots and stress index visualization
- Export of HRV parameters and RR intervals to Excel
- Saving and loading analysis sessions

## HRV Parameters

The software includes the following measures:

**Time-domain:** Heart rate, SDNN, RMSSD, SDSD, SDANN, SDNN Index, and pNN50.

**Frequency-domain:** LF power, HF power, LF/HF ratio, normalized LF and HF, and RSA derived from HF power.

**Nonlinear and additional measures:** SD1, SD2, SD2/SD1, and stress index.

## Requirements

- MATLAB
- MATLAB Signal Processing Toolbox

Compatibility with specific MATLAB releases is being documented.

## Installation and Usage

1. Download `HRV_GUI.m` from this repository.
2. Open MATLAB and navigate to the directory containing the file.
3. Run the following command:

   `HRV_GUI`

4. Select Human or Rat mode.
5. Load an ECG recording in WAV format, or an RR interval file in XLSX format containing an `RR_ms` column.
6. Perform signal processing, RR extraction, and HRV analysis using the graphical interface.
7. Export the results as needed.

## Research Applications

HRV-GUI is intended to support quantitative analysis of autonomic cardiac activity across experimental and clinical research settings.

Relevant research applications and publications will be documented here.

## Software Status

The software is undergoing final verification of numerical calculations and testing for reproducible research use.

It is intended for research purposes and is not a clinical diagnostic tool.

## Citation

Citation information will be updated following publication of the accompanying HRV-GUI manuscript.

## License

Software distribution and licensing information will be provided following institutional review and approval.# HRV-GUI
MATLAB-based GUI for ECG-derived heart rate variability analysis in preclinical and clinical research
