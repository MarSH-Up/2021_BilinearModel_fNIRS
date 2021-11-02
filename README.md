# Bilinear Neurovascular Model

This repository implements the forward model proposed for STak in 2015 in the paper Dynamic Causal Modelling for FNIRS. The bilinear model presents a generative model of how interactions among hidden neuronal states cause observed fNIRS data. The exchange of the Ordinary Differential Equations are solved right now using the Euler Method: Zn+1 = Zn + h * f(Xn, Zn)


## Little background:
Functional near-infrared spectroscopy (fNIRS) is a non-invasive method for monitoring hemodynamic changes in the brain. In a nutshell, fNIRS can observe changes in light photon density that reaches the detectors. That corresponds to changes in the optical properties of the tissue, reflecting changes in oxy and deoxyhemoglobin (HbO and HbR). We can use the loss of light levels to calculate the changes in hemoglobin concentrations in underlying brain regions. 

![FNIRS-EXAMPLE](/Images/2021_Thesis_fNIRS_Source-dector.png)


## Generative Model for FNIRS:

The model is composed of three stages: 
1. Neurodynamics; Neuronal activity in terms of inter-regional interactions.
2. Hemodynamics; Linking neural activity with the changes in total hemoglobin and deoxyhemoglobin. (The model follows the Ballon Model, Friston, et al. 2000). 
3. Optics; The model relates the Hemodynamic sources to optical density changes. (This part needs more love). 


The following describes a big picture of the equations that represent the model. All the rights are for S.Tak. I took the diagram from his paper. 

<p align="center">
  <img width="470" src="/Images/2021_BilinearModel.PNG">
</p>


## Using the Bilinear Model code

The code (kind of) follows the OOPs philosophy, and of course, it can be improved.  Each stage brief described in the list is a function. You can find the requirements of each part in the source code, but here is an introduction:
1. BilinearModel_StimulusTrainGenerator; This function creates the stimulus train U to feed the Neurodynamics stage. Right now, we make two identical stimuli. You can modify this function to generate the stimulus train your application needs. How to call it? 
  ```
  % Outputs; U will be your stimulus, and Timestamps= Time sequence for the stimulus train.
  % Inputs; Freq = Sampling Frequency, Action Time = Activition Time, Rest Time = Rest period, 
  %         and Cycles = Number of events per instruction (task period + rest period)
  
  [U, timestamps] = BilinearModel_StimulusTrainGenerator(freq, action_time, rest_time, cycles) 
  ```
