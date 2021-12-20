# Bilinear Neurovascular Model

This repository implements the forward model proposed for STak in 2015 in the paper Dynamic Causal Modelling for FNIRS. The bilinear model presents a generative model of how interactions among hidden neuronal states cause observed fNIRS data. The exchange of the Ordinary Differential Equations are solved right now using the Euler Method: Zn+1 = Zn + h * f(Xn, Zn) .


## Little background:

Functional near-infrared spectroscopy (fNIRS) is a non-invasive method for monitoring hemodynamic changes in the brain. In a nutshell, fNIRS can observe light photon density changes that reach the detectors. That corresponds to changes in the optical properties of the tissue, reflecting changes in oxy and deoxyhemoglobin (HbO and HbR). We can use the loss of light levels to calculate the changes in hemoglobin concentrations in underlying brain regions. 

![FNIRS-EXAMPLE](/Images/2021_Thesis_fNIRS_Source-dector.png)


## Generative Model for FNIRS:

The model is composed of three stages: 

1. Neurodynamics; Neuronal activity in terms of inter-regional interactions.
2. Hemodynamics; Linking neural activity with the changes in total hemoglobin and deoxyhemoglobin. (The model follows the Ballon Model, Friston, et al. 2000). 
3. Optics; The model relates the Hemodynamic sources to optical density changes. (This part needs more love). 

The following describes a big picture of the equations that represent the model. All the rights are for S.Tak, and yes, I took the diagram from his paper.  
 

<p align="center">
  <img width="470" src="/Images/2021_BilinearModel.PNG">
</p>


## Using the Bilinear Model code

The code (kind of) follows the OOPs philosophy, and of course, it can be improved.  Each stage brief described in the list is a function. You can find the requirements of each part in the source code, but here is an introduction:

1. BilinearModel_StimulusTrainGenerator creates the stimulus train U to feed the Neurodynamics stage. Right now, we make two identical stimuli. You can modify this function to generate the stimulus train your application needs. How to call it? 
  ```
  % Outputs; U will be your stimulus, and Timestamps= Time sequence for the stimulus train.
  % Inputs; Freq = Sampling Frequency, Action Time = Activition Time, Rest Time = Rest period, 
  %         and Cycles = Number of events per instruction (task period + rest period)
  
  [U, timestamps] = BilinearModel_StimulusTrainGenerator(freq, action_time, rest_time, cycles) 
  ```
  <p align="center">
    <img width="470" src="/Images/Stimulus.png">
  </p>

2. Neurodynamics; Neural activity of the inter-regions interactions (Check Friston,2003). Basically, you will have the neural response of each region defined in your connectivity matrixes (We are using here the proposed by S.Tak)
  ```
  % Outputs; Z = Neurodynamics. Sized <nRegions x simulationLength> (Carefull with the nRegions, check the paper :D)
  % Inputs; A = Latent connectivity. Square matrix. Sized <nRegions x nRegions>, B = Induced connectivity, Square matrix. Sized <nRegions x nRegions x         %         nStimulus>, C = Extrinsic influences of inputs on neuronal activity, U = Stimuli. Sized <nStimuli x nTimeSamples> (Previous function), and 
  %         step = Integration step (h using Euler Method, consider that we need to validate the h with mathematical rigor, We will update next months). 

  [Z] = BilinearModel_Neurodynamics_Z(A, B, C, U, step)
  ```
  <p align="center">
    <img width="470" src="/Images/Neurodynamics.png">
  </p>

3. Hemodynamics; Total Hemoglobin and deoxyhemoglobin rates based on Ballon model. This part needs to be feed using the Neurodynamics states.
  ```
  % Outputs; qj = rate HbR,and pj = Rate HbT.
  % Inputs; Z = Neurodynamics, U = Stimuli, P_SD = Priory values (Using now the estimated by S.Tak), A = Latent connectivity                               
  %        ,and  step =  integration step.
  
  [qj,pj] = BilinearModel_Hemodynamics_Naive_v2(Z, U, P_SD, A, Step)
  ```
  <p align="center">
    <img width="470" src="/Images/M1_HEMO.png">
    <img width="470" src="/Images/SMA_Hemo.png">
  </p>
NOTE: This images are the transformation of the rates to actual values, based-on: 
  <p align="center">
    <img width="230" src="/Images/Hemo_transform.png">
  </p>
  
4.Optics; optical density changes relating to hemodynamic sources generate the hemodynamics function. T
  ```
  % Outputs; Y = Optical Density Changes
  % Inputs; qj = rate HbR, pj = Rate HbT, U = Stimulus, A = Latent connectivity, and Noise = noise, lol (We are trying to recreate the fnirs
  %     outputs, so that's why we include noise here. The value range is from 0 to 1, 0 will not have noise, and one will give you a challenge.) 
  
  [Y] = BilinearModel_Optics_Naive(pj, qj, U, A, Noise)
  ```
  <p align="center">
    <img width="470" src="/Images/M1_Optics.png">
    <img width="470" src="/Images/SMA_Optics.png">
  </p>
  
## Using the Bilinear Model on Simulink

We base the model on the code shown before. The difference is that we use the State-Space method to represent each equation natively on Simulink to optimize the system. We need that because even this is one of the fundamental parts of our Neurofeedback model (you can find that repository too on my profile). So State-space method, you take an nth order ODE and represent it with a single first-order matrix, and you can see it as: 

<p align="center">
  <img width="470" src="/Images/State-space.png">
</p>

Then, once you represent your model, you can quickly transfer it to a block control diagram, so following:  

<p align="center">
  <img width="470" src="/Images/State-space-block.png">
</p>

And taking Neurodynamics as an example, you will get something like: 

<p align="center">
  <img width="470" src="/Images/State-space-Z.png">
</p>

Notice the green rectangle; we keep that as a code block to implement an equation later there. Neurodynamics loos easy, but the complete model is a little more complex; the following image is the state-space model of the hemodynamics part.

<p align="center">
  <img width="470" src="/Images/State-space-hemo.png">
</p> 
