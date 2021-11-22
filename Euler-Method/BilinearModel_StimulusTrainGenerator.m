function [U, timestamps] = BilinearModel_StimulusTrainGenerator(freq, action_time, rest_time, cycles)
%% Version V2
% Authors - Mario De Los Santos, Felipe Orihuela-Espina, Javier Herrara-Vega
% Date - August 28th, 2021
% Email - madlsh3517@gmail.com
%
%% Input Parameters
%   - Freq          + Sampling Frequency.
%   - Action Time   + Activation time
%   - Rest Time     + Rest period
%   - Cycles        + Number of events per instruction (task period + rest period)
%
%% Output Parameters
%
%   - U             + Stimulus train. Sized <nStimulus x simulationLength>
%   - Timestamps    + Time sequence for the stimulus train.
%
%%   
    rest  = rest_time * freq;
        activation = action_time * freq;
        activation_ = activation;
        Time_period  = (action_time + rest_time) * cycles;
        simulationLength = Time_period * freq;
        U = zeros(2,simulationLength);

        lvel = 1;
        for i = 1:cycles
            for x = lvel:activation_
                U(:,x) = 1; 
                lvel = lvel + 1;
            end
            lvel = (activation+rest)*i;
            activation_ =  ((activation+rest)*i)+activation;
        end    

        timestamps = [0:1/freq:Time_period];
        timestamps(end)=[];
end