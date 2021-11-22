%Script to test the BilinearModel
% Authors: Mario de los Santos, Felipe Orihuela-Espina, Javier Herrara-Vega
%
%% Log:
% October, 2021: MDLS
%   
%%
clear; 
close all;
clc;

%Latent connectivity. Square matrix. Sized <nRegions x nRegions>
A = [-0.16 -0.49; -0.02 -0.33]; 

%Induced connectivity. Square matrix. Sized <nRegions x nRegions x nStimulus>
B1 = [0 0; 0 0]; %There must be a B per stimulus
B2 = [-0.02 -0.77; 0.33 -1.31];
B(:,:,1) = B1;
B(:,:,2) = B2;
% Extrinsic influences of inputs on neuronal activity.
C = [0.08 0; 0.06 0];

%Sample Frequency. This version use the Frequency as H integration step for Euler ODE Method.
freq = 10.4;
%Step for Euler ODE Method H
    step = 1/freq;
    %%
    %Stimulus train
    [U_stimulus, timestamps] = BilinearModel_StimulusTrainGenerator(freq, 5, 25, 2); 
    %%
    %Neurodynamics
    [Z] = BilinearModel_Neurodynamics_Z(A,B,C, U_stimulus, step);
    %%
    %HEMODYNAMICS
    P_SD = [[0;0.05] [0;0.05] [0;0.05] [0;1]];
    [Sj,Vj,qj,pj] = BilinearModel_Hemodynamics_Naive_v2(Z, U_stimulus, P_SD, A, step);
    %%
    %OPTICS
    Noise = 0.4;
    [Y] = BilinearModel_Optics_Naive(pj, qj,U_stimulus,A, Noise);
    %%
    %Just plotting
    figure;
    subplot(211);
    plot(timestamps,U_stimulus(1,:),'LineWidth',2);
    xlabel('Time (s)');
    ylabel('Task (U_{1})');
    subplot(212);
    plot(timestamps,U_stimulus(2,:),'LineWidth',2);
    xlabel('Time (s)');
    ylabel('Task (U_{2})');
    title('Stimulus');
    Zm1  = Z(1,:);
    Zsma = Z(2,:);  
    figure
    ax1 = subplot(2,1,1); % top subplot
    plot(ax1,timestamps,Zm1,'LineWidth',2);
    title(ax1,'Zm1');
    xlabel(ax1,'Time');
    ax2 = subplot(2,1,2); % bottom subplot
    plot(ax2,timestamps,Zsma,'LineWidth',2);
    title(ax2,'Zsma');
    xlabel(ax2,'Time');

    
