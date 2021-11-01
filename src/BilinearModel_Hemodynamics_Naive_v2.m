function [Sj, Vj, qj,pj] = BilinearModel_Hemodynamics_Naive_v2(Z, U, P_SD, A, Step)
%% Version V4
% Authors - Mario De Los Santos, Felipe Orihuela-Espina, Javier Herrara-Vega
% Date - October 19th, 2021
% Email - madlsh3517@gmail.com
% Based on: 2015 Stak DCM for fNIRS.
%
%% Input Parameters
% Z - Neurodynamics. Sized <nRegions x simulationLength>
% U_Timestamps - Time sequence for the stimulus train.
% P_SD - Prior Parameters (Using now the estimated by STak,2015)
%
%% Output Parameters
% 
% qj - Rate HbR - Rate Deoxy-hemoglobin
% pj - Rate HbT - Rate Total Hemoglobin
%  
%
%% 
    %Simulation size definition
    nRegions  = size(A,1);
    simulationLength = size(U,2);
    
    %Vasodilatory Signal variable
    Sj = nan(nRegions,simulationLength);
    Sj(:,1) = [0;0];
   
    %Rate of blood volume
    Vj =  zeros(nRegions,simulationLength);
    Vj(:,1) = exp([0;0]);
   
    %HbT concentration (Rate)
    pj = nan(nRegions, simulationLength);
    pj(:,1) = exp([0;0]);
    
    %HbR concentration (Rate)
    qj = nan(nRegions, simulationLength);
    qj(:,1) = exp([0;0]);
    
    %Inflow
    fjin = nan(nRegions,simulationLength);
    fjin = exp([0;0]);
%--------------------------------------------------------------------------
%   H(1) - signal decay                 - Kj                           
%   H(2) - autoregulation               - Yj
%   H(3) - transit time                 - Tj                     
%   H(4) - exponent for Fout(v)         - phi                  
%   H(5) - resting oxygen extraction    - alpha                   
%   H(6) - viscoelastic time constant   - Tjv           
%--------------------------------------------------------------------------
    H = [0.64 0.32 2.00 0.32 0.32 2.00];
    
    Kj = H(1)*exp(P_SD(1)); 
    Yj = H(2)*exp(P_SD(2)); 
    Tj = H(3)*exp(P_SD(3));
    Tjv = H(6)*exp(P_SD(4));
    phi = H(4);
 
    for t = 2:simulationLength
        Sj_dot = Z(:,t-1) - Kj.*Sj(:,t-1) - Yj.*(fjin(:,t-1)-1);
        fjin_dot = Sj(:,t-1);
       
        
        fv_s = Vj(:,t-1) .^ (1/phi); 
        Vj_dot = (fjin(:,t-1) - fv_s) ./ ((Tj.*Tjv).* Vj(:,t-1));
      
        
        fjout = fv_s + Tjv .* Vj(:,t-1).* Vj_dot;       
        Efp = (1 - (1 - H(5)).^(1./fjin(:,t-1)))/H(5);
        
        
        qj_dot = (fjin(:,t-1) .* Efp - fjout .* qj(:,t-1) ./ Vj(:,t-1)) ./ (Tj .* qj(:,t-1));
        
        pj_dot   = (fjin(:,t-1) - fjout  .* pj(:,t-1) ./ Vj(:,t-1))./ (Tj .* pj(:,t-1));

        %Euler steps 
        Sj(:,t) = Sj(:,t-1) + Step * Sj_dot;
        Vj(:,t) = Vj(:,t-1) + Step * Vj_dot;
        fjin(:,t) = fjin(:,t-1) + Step * fjin_dot;
        qj(:,t) = (qj(:,t-1) + Step * qj_dot);
        pj(:,t) = (pj(:,t-1) + Step * pj_dot);
    end 
    %{
    figure
    plot(transpose(pj), 'LineWidth', 4);
    title('Rate Total Hemoglobin');
    shg;
    figure
    plot(transpose(qj), 'LineWidth', 4);
    title('Deoxy Hemoglobin');
    shg;
    %}
end