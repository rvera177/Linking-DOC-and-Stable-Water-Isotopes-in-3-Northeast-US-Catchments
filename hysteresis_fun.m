function [q_Norm,c_Norm, HI_Ave, FI] = hysteresis_fun(Q, C, nt)
%This function returns the hystersis loop normalized C and Q values based
%on an input time series. nt equals the number of increments to solve for.
        
        % Remove any flow values in the recession that drop below the
        % initial, starting flow rate (unless that would leave the last
        % value in the array as the maximum Q --> thus making hysteresis
        % impossible)
      if max(Q) ~= Q(end-1) 
        clean_idx = find(Q<Q(1));
        Q(clean_idx) = []; C(clean_idx) = [];
      end 
        
        % Normalizing streamflow and concentration
        Q_N = mat2gray(Q); %normalize between 0 and 1
        C_N = mat2gray(C); %normalize between 0 and 1

        % Rising limb calculations      
        Krs = linspace(0,1,nt+1)';   % Rising limb increments

        ind_Max = max(find(Q_N==max(Q_N))); %Finding the index of maximum Streamflow
        Q_Ris = Q_N(1:ind_Max); %Rising portion of streamflow
        Q_Fal = [Q_N(ind_Max:length(Q_N));0];
        C_Fal = [C_N(ind_Max:length(Q_N));0];
        Q_Per = Krs*(max(Q_N)-min(Q_N))+min(Q_N); % Finding streamflow increments
        Q_Per(Q_Per<Q_N(length(1))) = [];
        Q_PerInd = zeros(length(Q_Per),1);
        C_PerInt = zeros(length(Q_Per)-1,1);

        j=1;
        for s=1:length(Q_Per)
            while (Q_Ris(j)<= Q_Per(s) && j<ind_Max)
                j=j+1;
            end
            Q_PerInd(s,1) = j-1;
        end
        Q_PerInd(length(Q_Per)) = j;

        Krs(1:(nt+1)-length(Q_Per)) = [];

        for t = 1:length(Q_Per)
    % Ensure that indices are within bounds
    if Q_PerInd(t) >= 1 && Q_PerInd(t)+1 <= length(C_N)
        % Calculate C_PerInt only if indices are valid
        C_PerInt(t,1) = (C_N(Q_PerInd(t)+1)-C_N(Q_PerInd(t)))*((Q_Per(t)-Q_N(Q_PerInd(t)))/(Q_N(Q_PerInd(t)+1)-Q_N(Q_PerInd(t))))+C_N(Q_PerInd(t));
    else
        % Handle cases where indices are out of bounds
        % You can set C_PerInt to some default value or handle it differently based on your requirement
        C_PerInt(t,1) = NaN; % For example, setting it to NaN
    end
end

        
        C_PerInt_N = (C_PerInt-min(C_N))/(max(C_N)-min(C_N));

        % Falling limb calculations
        Kfl = linspace(1-1/nt, 1/nt,nt-1)'; 
        Q_PerF = Kfl*(max(Q_N)-min(Q_N))+min(Q_N);
        Q_PerF(Q_PerF<=Q_N(length(Q_N))) = [];
        Kfl(length(Q_PerF)+1:length(Kfl)) = [];
        Q_PerIndF = zeros(length(Q_PerF),1);
        C_PerIntF = zeros(length(Q_PerF)-1,1);

        j = 1;
        for u=1:length(Q_PerF)
            while (Q_Fal(j)>Q_PerF(u) && j<length(Q_Fal))
                j=j+1;
            end
            Q_PerIndF(u,1) = j-1;
        end


        for u=1:length(Q_PerF)
            C_PerIntF(u,1) = (C_Fal(Q_PerIndF(u))-C_Fal(Q_PerIndF(u)+1))*((Q_PerF(u)-Q_Fal(Q_PerIndF(u)+1))/(Q_Fal(Q_PerIndF(u))-Q_Fal(Q_PerIndF(u)+1)))+C_Fal(Q_PerIndF(u)+1);
        end
       
        C_PerIntF_N = (C_PerIntF-min(C_N))/(max(C_N)-min(C_N));

        targetSize = [1 nt]; %since our Kfl's are not always 50, we need to resize  
        
        k = [Krs' Kfl']; %Organize rising and falling increments
        k = imresize(k, targetSize); %Resize to 100 cell values 
        k = mat2gray(k); %Normalize to between 0 and 1

        Cj = [C_PerInt_N' C_PerIntF_N'];
        Cj = imresize(Cj, targetSize);
        Cj = mat2gray(Cj);
        

        hi_beg = max(length(Krs)  - length(Kfl),1); %Here we choose where to start the HI calculations on the rising limb (in case the falling limb ends before Q returns to baseflow conditions)
        hi_end = min(length(Kfl), length(Krs)-1); %Here we choose where to end the HI calculations, in case the ending discharge exceeds the starting event discharge
        HI = C_PerInt_N(hi_beg:end-1)-flip(C_PerIntF_N(1:hi_end)); %calculation of HI at each increment

       
        HI_Ave = mean(HI);
        FI = C_N(ind_Max) - C_N(1);
        q_Norm = k; 
        c_Norm = Cj; 

end

