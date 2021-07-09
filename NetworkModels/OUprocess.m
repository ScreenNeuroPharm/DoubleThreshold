function x = OUprocess(method, mu, tau, sigma, dt, NumHours)
% This function implemets the solution of the Ornstein-Uhlenbeck process.
% Two methods of resoluation are proposed: analyicial and in terms of
% integrals
% Typical neuronal parameters are:
% tau = 1 ms;
% mu = 25 pA;
% sigma = 9 pA;
% 
%               Paolo Massobrio - last update 18th May 2016
% 
t = 0:dt:60*60*NumHours;      % Time vector
x0 = 0;                       % Set initial condition
rng(1,'twister');             % Set random seed

if method == 'analytical'
    % analytical solution
    ex = exp(-tau * t);
    x = x0 * ex + mu * (1-ex) + sigma*ex.*cumsum([0 sqrt(diff(exp(2*tau*t)-1)).*randn(1,length(t)-1)])/sqrt(2*tau);
else
    % solution in terms of integral
    ex = exp(-tau * t);
    x = x0 * ex + mu * (1-ex) + sigma*ex.*cumsum(exp(tau*t).*[0 sqrt(dt)*randn(1,length(t)-1)]);
end