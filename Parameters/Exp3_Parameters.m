r_P = 0.1; % radius of pulley
J_P = 0.003; % mass inertia of pulley around axis of rotation kgm^2
J_M = 5.5e-5; % mass moment of inertia
i_G = 62; % gear ratio 62:1
m_G = 2; % load mass
R_A = 2.443; % average armature resistance
L_A = 4.873e-3; % armature inductance 
k_M = 0.109316; % average machine constant
g = 9.81; %gravitational acceleration

%total mass inertia
J = J_M*i_G*i_G + J_P + m_G*r_P*r_P;

%transfer function for electrical circuit
num = 1;
den = [L_A R_A];
G = tf(num,den);

%1-D lookup table
LT1D_FRICTION = [-2.2947 -1.7077 -1.1313 -0.5431 -0.001 0 0.001 0.2934 0.8882 1.4761 2.0669;
                -3.4482 -3.2346 -3.0609 -2.7991 -2.7991 0 3.3451 3.3451 3.2970 3.3908 3.5920];

%with -0.001 and 0.001
%LT1D_FRICTION = [-2.2947 -1.7077 -1.1313 -0.001 0 0.001 0.8882 1.4761 2.0669;-3.4482 -3.2346 -3.0609 -2.7991 0 3.3451 3.2970 3.3908 3.5920];
