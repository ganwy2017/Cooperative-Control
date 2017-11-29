function [yawRef, ASV] = straightLinePath(ASV, ref)      
    %% Process Path
    [m, c, yawD] = processLine(ref.start,ref.finish);

    %% Path Error
    % find nearest point's x
    if m == -1
        % adjusting for sigularity in xD function
        xD = (ASV.X - ASV.Y)/2;
    else
        % standard case
        xD = (ASV.X + ASV.Y - c)/(m + 1);
    end

    % find nearest point's y
    yD = m*xD + c;

    closestPoint = [xD;yD];

    % find cross track error
    crossTrack = sqrt((xD - ASV.X)^2 + (yD - ASV.Y)^2);

    path = m*ASV.X + c;
    if ASV.Y < path
        crossTrack = - crossTrack;
    end

    ASV.error_crossTrack = crossTrack;

    %% Integral
    ASV.error_crossTrack_int = ASV.error_crossTrack_int + ASV.error_crossTrack * ASV.Ts;

    %% Yaw error
    ASV.error_yaw = yawD - ASV.Yaw;

    %% Provide Yaw Ref
    % gain values
    K1 =  10.0; %yaw proportional
    K2 =  5.0; %cross-track proportional
    K4 =  0.2; %integral

    if ASV.X > 0
        direc = -1;
    else
        direc = 1;
    end

    % delta term
    yawDel = K1*ASV.error_yaw + direc * K2 * crossTrack / ref.uRef ...
             + direc * K4 * ASV.error_crossTrack_int;
    yawRef = yawD + yawDel;
    
    %% Coordination state
    L    = sqrt((ref.finish(1,1) - ref.start(1,1))^2 +(ref.finish(2,1) - ref.start(2,1))^2);
    Lpos = sqrt((ASV.X - ref.start(1,1))^2 +(ASV.Y - ref.start(2,1))^2);
    
    ASV.gamma = Lpos/L;
    
end
