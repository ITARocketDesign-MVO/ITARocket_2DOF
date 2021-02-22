function flight_plot(t, X)
    global ROCKET
    global RAIL
    
    figure(1)
    subplot(231)
    plot(t, X(:,2)/0.3048, 'linewidth', 3)
    grid on
    xlabel('Time (s)')
    ylabel('Vertical position (ft)')
    
    subplot(234)
    plot(X(:,1), X(:,2), 'linewidth', 3)
    grid on
    xlabel('Horizontal position (m)')
    ylabel('Vertical position (m)')
    
    subplot(232)
    plot(t, X(:,3), 'linewidth', 3)
    grid on
    xlabel('Time (s)')
    ylabel('Horizontal velocity (m/s)')
    
    subplot(235)
    plot(t, X(:,4), 'linewidth', 3)
    grid on
    xlabel('Time (s)')
    ylabel('Vertical velocity (m/s)')
    
    g0 = ROCKET.G;
    accel = sqrt(diff(X(:,4)).^2 + diff(X(:,3)).^2)./(norm(g0)*diff(t));
    
    subplot(233)
    plot(t(2:end), accel , 'linewidth', 3);
    grid on
    xlabel('Time (s)')
    ylabel('Acceleration magnitude (G)')
    
    subplot(236)
    plot(t, sqrt(X(:,4).^2 + X(:,3).^2)./soundspeed(X(:,2)), 'linewidth', 3)
    grid on
    xlabel('Time (s)')
    ylabel('Mach number')
    
    traj_angle = atan2(X(:,4), X(:,3))*180/pi;
    traj_angle(1) = RAIL.Angle*180/pi;
    
%     figure(2)
%     plot(t, traj_angle, 'linewidth', 3)
%     grid on
%     xlabel('Time (s)')
%     ylabel('Trajectory angle (^o)')