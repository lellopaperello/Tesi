function V = vt(dv, phi1, phi2, model)
global rho_a mu g
switch model
    case 'Test'
        V = phi1 * dv ^ phi2;
        return
    case 'Ganser'
        % Indipendent shape parameters for Ganser's model
        Phi = phi1;     dn = phi2 * dv;
        
        % Aspect ratio ~ V / S
        Ar = 2/3 * dv^3 / (dn^2);
        
        % Stokes shape factor
        K1 = (dn/(3*dv) + 2/(3*sqrt(Phi)))^(-1);
        
        % Newton shape factor
        K2 = 10^(1.8148*(abs(log(Phi))^0.5743));
        
        % Reynolds number per unit velocity
        Re_v = rho_a * dv / mu;
        
        % Generalized Reynolds number (per unit velocity)
        RE_v = Re_v * K1 * K2;
        
        % Drag coefficient model
        cD =@(v) K2* (24 / (RE_v*v) * (1 + 0.1118 * (RE_v*v)^0.6567) ...
                      + 0.4305 / (1 + 3305 / (RE_v*v)));
    case 'Holtzer&Sommerfeld'
        % Indipendent shape parameters for Holtzer and Sommerfeld model
        Phi = phi1;     Phi_perp = phi2;
        
        % Aspect ratio ~ V / S
        Ar = 2/3 * dv * Phi_perp;
        
        % Reynolds number per unit velocity
        Re_v = rho_a * dv / mu;

        % Drag coefficient model
        cD =@(v) 8 /(Re_v*v * sqrt(Phi_perp)) + 16 /(Re_v*v * sqrt(Phi)) ...
            + 3 /(sqrt(Re_v*v) * Phi^(3/4)) + 0.421^(0.4*((-log(Phi))^0.2)) / Phi_perp;
end

% Equilibrium equation 
equilibrium =@(vt) 1/2 * vt^2 * cD(vt) + (rho_a - rho_snow(dv))/rho_a * Ar * g;

% Solution
V = fzero(equilibrium, [1e-10 1e3]);


