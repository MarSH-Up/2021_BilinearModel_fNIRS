function [Y] = BilinearModel_Optics_Naive(pj, qj, U,A)
%% Version V1
% Authors - Mario De Los Santos, Felipe Orihuela-Espina, Javier Herrara-Vega
% Date - October, 2021
% Email - madlsh3517@gmail.com
% Based on: 2015 Stak DCM for fNIRS.
%
%% Input Parameters
% q - HbR - Rate of deoxy-hemoglobin
% p - HbT - Total Hemoglobin
%
%% Output Parameters
% y- optical density changes 
%
%% 
nRegions  = size(A,1);
simulationLength = size(U,2);
% optics parameters
%--------------------------------------------------------------------------
%   N(1) - oxygen saturation                                            SO2
%   N(2) - baseline total-hb concentration [mM]                          P0
%   N(3) - cortical weighting factor                                      w
%--------------------------------------------------------------------------
N = [0.65 71 2]; 
P0 = N(2);
% baseline dxy-hb concentration 
base_hbr = N(2) .* (1 - N(1)); 


dq = zeros(nRegions, simulationLength);
dp = zeros(nRegions, simulationLength);
dh = zeros(nRegions, simulationLength);

M1 = zeros(3, simulationLength);
SMA = zeros(3, simulationLength);

Y_R1 = zeros(nRegions, simulationLength);
Y_R2 = zeros(nRegions, simulationLength);

%
% We are using as L1 = 780nm and as L2 = 850nm (same as STak for the
% second one)
%Based on: Giannoni, L., Lange, F., & Tachtsidis, I. (2020). Investigation of the quantification 
% of hemoglobin and cytochrome-c-oxidase in the exposed cortex with near-infrared hyperspectral imaging: 
% a simulation study. Journal of biomedical optics, 25(4), 046001.
F_P =[(0.0007358251*7.5) (0.001104714*6.5);(0.001159306*7.5) (0.0007858993*6.5)]; 
%735.8251 1104.715  = 780nm
%1159.306 785.8993 = 850nm
%disp(cond(F_P));
    for t = 1:simulationLength
        % calculate changes in hemoglobin concentration
        dp(:,t) = (pj(:,t) - 1) * P0; % total Hb
        dq(:,t) = (qj(:,t)-1) * base_hbr; % dxy-Hb
        dh(:,t) = dp(:,t) - dq(:,t); % oxy-Hb
        
        dhq_r1 = [dh(1,t);dq(1,t)]; %DH y DQ de M1
        dhq_r2 = [dh(2,t);dq(2,t)]; %DH y DQ de SMA
        
        M1(:,t) = [dp(1,t);dq(1,t);dh(1,t)];
        SMA(:,t) = [dp(2,t);dq(2,t);dh(2,t)];
        
        %Optics
        
        Y_R1(:,t) = F_P * dhq_r1; 
        Y_R2(:,t) = F_P * dhq_r2;
    end
    
    %noiseSigma = 0.8* Y_R1;
    %noise = noiseSigma .* randn(1, length(Y_R1));
    %Y_R1 = Y_R1 + noise;
    figure
    plot(transpose(Y_R1), 'LineWidth', 1);
    title('M1  Optical density changes');
    legend({'Lambda 1','Lambda 2'},'Location','southwest');
    ylabel('Delta Optical Density'); 
    xlabel('Time (Seconds)');
    shg;
    
    %noiseSigma1 = 0.8* Y_R2;
    %noise1 = noiseSigma1 .* randn(1, length(Y_R2));
    %Y_R2 = Y_R2 + noise1;
    figure
    plot(transpose(Y_R2), 'LineWidth', 1);
    title('SMA Optical density changes');
    legend({'Lambda 1','Lambda 2'},'Location','southwest');
    ylabel('Delta Optical Density'); 
    xlabel('Time (Seconds)');
    shg;


    figure
    plot(transpose(M1), 'LineWidth', 4);
    title('M1 Heamoglobin Concentration');
    legend({'HbT','HbR', 'HbO_2'},'Location','southwest');
    ylabel('Relative Heamoglobin Concentration [\mu M]'); 
    xlabel('Time (Seconds)');
    shg;
    figure
    plot(transpose(SMA),'LineWidth', 4);
    title('SMA Heamoglobin Concentration');
    legend({'HbT','HbR', 'HbO_2'},'Location','southwest');
    ylabel('Relative Heamoglobin Concentration [\mu M]'); 
    xlabel('Time (Seconds)');
    shg;
    
    
    Y = [Y_R1; Y_R2];
end

