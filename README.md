# Bilinear Neurovascular Model

This repository implements the forward model proposed for STak in 2015 in the paper Dynamic Causal Modelling for FNIRS. The bilinear model presents a generative model of how interactions among hidden neuronal states cause observed fNIRS data. The exchange of the Ordinary Differential Equations are solved right now using the Euler Method: $Zn+1 = Zn + h * f(Xn, Zn)$


## Little background:
Functional near-infrared spectroscopy (fNIRS) is a non-invasive method for monitoring hemodynamic changes in the brain. In a nutshell, fNIRS can observe changes in light photon density that reaches the detectors. That corresponds to changes in the optical properties of the tissue, reflecting changes in oxy and deoxyhemoglobin (HbO and HbR). We can use the loss of light levels to calculate the changes in hemoglobin concentrations in underlying brain regions. 
