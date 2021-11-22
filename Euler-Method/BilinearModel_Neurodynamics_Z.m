function [Z] = BilinearModel_Neurodynamics_Z(A, B, C, U, step)

%% Version V3
% Authors - Mario De Los Santos, Felipe Orihuela-Espina, Javier Herrara-Vega
% Date - August 28th, 2021
% Email - madlsh3517@gmail.com
%
%% Input Parameters
%
% - A       + Latent connectivity. Square matrix. Sized <nRegions x nRegions>
%             This is the first order connectivity matrix. It represents
%             the intrinsic coupling in the absence of experimental
%             perturbations.
%             It represents the connectivity from region j to region i in the
%             absence of experimental input
% - B       + Induced connectivity. Square matrix. Sized <nRegions x nRegions x nStimulus>
%             Effective change in coupling induced by the j-th input
%             Change in connectivity from region j to region i induced by k-th input;
% - C       + Extrinsic influences of inputs on neuronal activity.
%
% - U       + Stimuli. Sized <nStimuli x nTimeSamples>
%
% - step    + Integration step.
%
%% Output Parameters
%
% - Z       + Neurodynamics. Sized <nRegions x simulationLength>
%%

   nRegions  = size(A,1);
   M = size(U,1); %nStimuli
   simulationLength = size(U,2);
   
   assert(M == size(B,3),...
            'Unexpected number of induced connectivity parameters B.');
   
   Z0 = [0;0];
   
   Z = nan(nRegions,simulationLength);
   Z(:,1) = Z0;

   for t = 2:simulationLength
       T = zeros(nRegions); %nRegions x nRegions
       for uu = 1:M % Sum (Uj * Bj)
           tmp = U(uu,t)*B(:,:,uu);
       %Please notice that S.Tak mentioned that the the use of the latent
       %variabls  A and B ensures that self connections J are negative
       %(typically with a value of 0.5). 
           T = -0.5*exp(T + tmp);
           
       end
       %One neuronal state per regrion: diag(A) is a log self-inhibition:
       SI = diag(A); %Temp variable for self-inhibition
       A =  A - diag(exp(SI)/2 + SI);
       % Equation Zdot = (A + U2 *B)*Zt-1 + CU
       %(Friston,2003, pag 1279)
       Zdot = (A  + T) * Z(:,t-1) + C*U(:,t-1); 
       %Euler method
       %ref: Zn+1 = Zn + h * f(Xn, Zn)
	   Z(:,t) = Z(:,t-1) + step * Zdot;
   end   
   
 
   
end