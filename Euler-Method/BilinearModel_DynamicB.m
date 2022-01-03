function [Bt] = BilinearModel_DynamicB(B, nRegions, U)
    %% Version V1
    Thershold = 0.2;
    if(U < Thershold) %Random Ucontrol to test
        min = -2; 
        max = 2;
        n = nRegions;
        r = min + rand(n)*(max-min);
        Bt(:,:,1) = [0 0; 0 0];
        Bt(:,:,2) = r(:,:);
    else
       Bt = B(:,:,:);
    end
end

