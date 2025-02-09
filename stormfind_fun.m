function [Storms, Storm_Info] = stormfind_fun(Q, multiplier, buffer)
%This function identifies storm events that meet a certain criteria. 
%'Storms' returns a cell array of discharge values for each storm
%'Storm_Info' returns six columns, which represent: 
%   (1) starting Q for an event, (2) max Q for an event, (3) ending Q for an event, 
%   (4) index for event start, (5) index for event max Q, (6) index for event end 

Storms = {};  % Initialize Storms as an empty cell array
Storm_Num = 1; % Storm number (start w/ 1)
i = 1;         % Streamflow index
l = 1;         % Temporary index
Store(1) = Q(i); % Temporary array for each identified storm
j = Store(1);

while Q(i+1)>=Q(i) && i<(length(Q)-1)
    Store(l+1) = Q(i+1);
    if Q(i+1)>=multiplier*j
        fprintf('Storm %d is detected\n', Storm_Num);
        Storm_Info(Storm_Num,1) = Store(1);
        Storm_Info(Storm_Num,4) = i-length(Store)+2;
        while Q(i+1)>=Q(i)
            Store(l+1) = Q(i+1);
            i = i+1;
            l = l+1;
        end
        Storm_Info(Storm_Num,2) = Store(l);
        Storm_Info(Storm_Num,5) = i;
        
        % Check if storm duration exceeds one month
        while ((i+buffer)<=length(Q) && (min(diff(Q(i:i+buffer)))<0) && Q(i+1)>Store(1))
            % Add check for storm duration not exceeding one month
            if (i+buffer) - (i - length(Store) + 2) > 30
                fprintf('Storm duration exceeds one month. Limiting duration to one month.\n');
                buffer = 30 - ((i - length(Store) + 2) - i + buffer);
            end
            
            Store(l+1) = Q(i+1);
            i = i+1;
            l = l+1;
        end
        
        Storm_Info(Storm_Num,3) = Store(l);
        Storm_Info(Storm_Num,6) = i;
        Storms{Storm_Num} = [Store'];
        Storm_Num = Storm_Num+1;
        Store = [];
        l=1;
        Store(l) = Q(i+1);
        j = Store(1);
    end
    i = i+1;
    l = l+1;
    while Q(i+1)<Q(i) && i<(length(Q)-1)
        Store = [];
        Store(1) = Q(i+1);
        l = 1;
        j = Store(1);
        i = i+1;
    end
end

end
