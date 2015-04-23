#
# AWK Functions, Oceanographic, Chemical and Geophysical
#

# Functions for calculating physical properties of Seawater, 
# mostly modified from Phil Morgan's Matlab utilities for which see
#   http://www.marine.csiro.au/~morgan/seawater
#

#--------------------------------------------------------------------
# Solubility of oxygen in seawater (ml/l) wrt an atmosphere of 20.95% oxygen
# and 100% relative humidity at a total atmospheric pressure of 860mmHg
# Source? Riley and Skirrow?
function oxysat ( S,T,   C)
{ T+=273.15
  C=exp( -173.4292 + 249.6339 *(100/T) + 143.3483*log(T/100) -21.8492*(T/100) + S*( -0.033096 +0.014259*(T/100) -0.0017*(T/100)*(T/100) ))
  return C
} 
#--------------------------------------------------------------------
# Verification function
# Values from Gill 1982. Diffs should be less than 1e-5
# Author: CMDR
#
function sw_test( \
	S,T,P,D,Dt,PR,DPTH,LAT)
{
# SW_DENS, SW_SECK, SW_DENS0 (Gill 1982)
	S=0; T=5; P=0; D=999.96675;
		Dt=sw_dens(S,T,P); print "D(sw_dens(" S "," T "," P "))=\t" Dt-D;
	S=35; T=5; P=0; D=1027.67547;
		Dt=sw_dens(S,T,P); print "D(sw_dens(" S "," T "," P "))=\t" Dt-D;
	S=35; T=25; P=10000; D=1062.53817;
		Dt=sw_dens(S,T,P); print "D(sw_dens(" S "," T "," P "))=\t" Dt-D;
# SW_FP (Unesco 1983)
	S=40; P=500; D=-2.588567;
		Dt=sw_fp(S,P); print "D(sw_fp(" S "," P "))=\t" Dt-D;
# SW_PTMP (Unesco 1983)
	S=40; T=40; P=10000; PR=0; D=36.89073; 
		Dt=sw_ptmp(S,T,P,PR); print "D(sw_ptmp(" S "," T "," P "," PR "))=\t" Dt-D;
# SW_SVEL (Unesco 1983)
	S=40; T=40; P=10000; D=1731.995;
		Dt=sw_svel(S,T,P); print "D(sw_svel(" S "," T "," P "))=\t" Dt-D;
	LAT=30; P=10000; D=9712.653;
	Dt=sw_dpth(P,LAT); print "D(sw_dpth(" P "," LAT "))=\t" Dt-D;

# SPICE
	P=0;T=15;S=33; print "D(spice(" S "," T "," P ")) =\t" spice(S,T,P)-0.54458641375;

	return
}
#--------------------------------------------------------------------
# SW_DENS    Density of sea water
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_dens( S,T,P \
	,K,densP0,dens)
{
	densP0 = sw_dens0(S,T);
	K      = sw_seck(S,T,P);
	P      = P/10;
	dens   = densP0/(1-P/K);
	return dens
}
#--------------------------------------------------------------------
# SW_SECK    Secant bulk modulus (K) of sea water
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_seck(S,T,P  \
	,h3,h2,h1,h0,AW,k2,k1,k0,BW,e4,e3,e2,e1,e0,KW,j0,i2,i1,i0,SR \
	,A,m2,m1,m0,B,f3,f2,f1,f0,g2,g1,g0,K0,K )
{
P = P/10;

h3 = -5.77905E-7;
h2 = +1.16092E-4;
h1 = +1.43713E-3;
h0 = +3.239908;

AW  = h0 + (h1 + (h2 + h3*T)*T)*T;

k2 =  5.2787E-8;
k1 = -6.12293E-6;
k0 =  +8.50935E-5;

BW  = k0 + (k1 + k2*T)*T;

e4 = -5.155288E-5;
e3 = +1.360477E-2;
e2 = -2.327105;
e1 = +148.4206;
e0 = 19652.21;

KW  = e0 + (e1 + (e2 + (e3 + e4*T)*T)*T)*T;

j0 = 1.91075E-4;
i2 = -1.6078E-6;
i1 = -1.0981E-5;
i0 =  2.2838E-3;

SR = sqrt(S);

A  = AW + (i0 + (i1 + i2*T)*T + j0*SR)*S; 

m2 =  9.1697E-10;
m1 = +2.0816E-8;
m0 = -9.9348E-7;

B = BW + (m0 + (m1 + m2*T)*T)*S;

f3 =  -6.1670E-5;
f2 =  +1.09987E-2;
f1 =  -0.603459;
f0 = +54.6746;

g2 = -5.3009E-4;
g1 = +1.6483E-2;
g0 = +7.944E-2;

K0 = KW + (  f0 + (f1 + (f2 + f3*T)*T)*T + (g0 + (g1 + g2*T)*T)*SR )*S;

K = K0 + (A + B*P)*P;

return K
}
#----------------------------------------------------------------------------
# SW_DENS0   Density of sea water at atmospheric pressure
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_dens0(S,T \
	,b0,b1,b2,b3,b4,c0,c1,c2,d0,dens)
{
b0 =  8.24493e-1;
b1 = -4.0899e-3;
b2 =  7.6438e-5;
b3 = -8.2467e-7;
b4 =  5.3875e-9;

c0 = -5.72466e-3;
c1 = +1.0227e-4;
c2 = -1.6546e-6;

d0 = 4.8314e-4;

dens = sw_smow(T) + (b0 + (b1 + (b2 + (b3 + b4*T)*T)*T)*T)*S  \
                   + (c0 + (c1 + c2*T)*T)*S*sqrt(S) + d0*S*S;	       

return dens
}
#----------------------------------------------------------------------------
# SW_SMOW    Density of standard mean ocean water (pure water)
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_smow(T \
	,a0,a1,a2,a3,a4,a5,dens)
{
a0 = 999.842594;
a1 =   6.793952e-2;
a2 =  -9.095290e-3;
a3 =   1.001685e-4;
a4 =  -1.120083e-6;
a5 =   6.536332e-9;

dens = a0 + (a1 + (a2 + (a3 + (a4 + a5*T)*T)*T)*T)*T;

return dens
}
#--------------------------------------------------------------------
# SW_FP      Freezing point of sea water
# Function modified from Matlab Seawater Library Ver 1.2e, by Morgan
function sw_fp(S,P \
	,a0,a1,a2,b,fp)
{
a0 = -0.0575;
a1 = 1.710523e-3;
a2 = -2.154996e-4;
b  = -7.53e-4;

fp = a0*S + a1*S*sqrt(S) + a2*S*S  + b*P;

return fp
}
#--------------------------------------------------------------------
# SW_PTMP    Potential temperature
# Function modified from Matlab Seawater Library Ver 1.2e, by Morgan
function sw_ptmp(S,T,P,PR \
	,del_P,del_th,th,q,PT)
{
# theta1
del_P  = PR - P;
del_th = del_P*sw_adtg(S,T,P);
th     = T + 0.5*del_th;
q      = del_th;

# theta2
del_th = del_P*sw_adtg(S,th,P+0.5*del_P);
th     = th + (1 - 1/sqrt(2))*(del_th - q);
q      = (2-sqrt(2))*del_th + (-2+3/sqrt(2))*q;

# theta3
del_th = del_P*sw_adtg(S,th,P+0.5*del_P);
th     = th + (1 + 1/sqrt(2))*(del_th - q);
q      = (2 + sqrt(2))*del_th + (-2-3/sqrt(2))*q;

# theta4
del_th = del_P*sw_adtg(S,th,P+del_P);
PT     = th + (del_th - 2*q)/6;

return PT
}
#--------------------------------------------------------------------
# SW_ADTG    Adiabatic temperature gradient
# Function modified from Matlab Seawater Library Ver 1.2e, by Morgan
function sw_adtg(S,T,P \
	,a0,a1,a2,a3,b0,b1,c0,c1,c2,c3,d0,d1,e0,e1,e2)
{
a0 =  3.5803E-5;
a1 = +8.5258E-6;
a2 = -6.836E-8;
a3 =  6.6228E-10;

b0 = +1.8932E-6;
b1 = -4.2393E-8;

c0 = +1.8741E-8;
c1 = -6.7795E-10;
c2 = +8.733E-12;
c3 = -5.4481E-14;

d0 = -1.1351E-10;
d1 =  2.7759E-12;

e0 = -4.6206E-13;
e1 = +1.8676E-14;
e2 = -2.1687E-16;

ADTG =      a0 + (a1 + (a2 + a3*T)*T)*T \
         + (b0 + b1*T)*(S-35)  \
	 + ( (c0 + (c1 + (c2 + c3*T)*T)*T) + (d0 + d1*T)*(S-35) )*P \
         + (  e0 + (e1 + e2*T)*T )*P*P;

return ADTG
}
#-------------------------------------------------------------------
# SW_SVEL    Sound velocity of sea water
# Function modified from Matlab Seawater Library Ver 1.2e, by Morgan
function sw_svel(S,T,P \
	,c00,c01,c02,c03,c04,c05,c10,c11,c12,c13,c14,c20,c21,c22,c23, \
	c24,c30,c31,c32,Cw,a00,a01,a02,a03,a04,a10,a11,a12,a13,a14,a20,a21, \
	a22,a23,a30,a31,a32,A,b00,b01,b10,b11,B,d00,d10,D,svel )
{
P = P/10;

c00 = 1402.388;
c01 =    5.03711;
c02 =   -5.80852e-2;
c03 =    3.3420e-4;
c04 =   -1.47800e-6;
c05 =    3.1464e-9;

c10 =  0.153563;
c11 =  6.8982e-4;
c12 = -8.1788e-6;
c13 =  1.3621e-7;
c14 = -6.1185e-10;

c20 =  3.1260e-5;
c21 = -1.7107e-6;
c22 =  2.5974e-8;
c23 = -2.5335e-10;
c24 =  1.0405e-12;

c30 = -9.7729e-9;
c31 =  3.8504e-10;
c32 = -2.3643e-12;

Cw =    c00 + (c01 + (c02 + (c03 + (c04 + c05*T)*T)*T)*T)*T   \
     + (c10 + (c11 + (c12 + (c13 + c14*T)*T)*T)*T)*P          \
     + (c20 + (c21 + (c22 + (c23 + c24*T)*T)*T)*T)*P*P        \
     + (c30 + (c31 + c32*T)*T)*P*P*P;
 
a00 =  1.389;
a01 = -1.262e-2;
a02 =  7.164e-5;
a03 =  2.006e-6;
a04 = -3.21e-8;

a10 =  9.4742e-5;
a11 = -1.2580e-5;
a12 = -6.4885e-8;
a13 =  1.0507e-8;
a14 = -2.0122e-10;

a20 = -3.9064e-7;
a21 =  9.1041e-9;
a22 = -1.6002e-10;
a23 =  7.988e-12;

a30 =  1.100e-10;
a31 =  6.649e-12;
a32 = -3.389e-13;

A =     a00 + (a01 + (a02 + (a03 + a04*T)*T)*T)*T       \
     + (a10 + (a11 + (a12 + (a13 + a14*T)*T)*T)*T)*P    \
     + (a20 + (a21 + (a22 + a23*T)*T)*T)*P*P            \
     + (a30 + (a31 + a32*T)*T)*P*P*P;

 
b00 = -1.922e-2;
b01 = -4.42e-5;
b10 =  7.3637e-5;
b11 =  1.7945e-7;

B = b00 + b01*T + (b10 + b11*T)*P;

d00 =  1.727e-3;
d10 = -7.9836e-6;

D = d00 + d10*P;

svel = Cw + A*S + B*S*sqrt(S) + D*S*S;

return svel
}
#--------------------------------------------------------------------------
# SW_C3515   Conductivity at (35,15,0)
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_c3515() { return 42.914 }
#--------------------------------------------------------------------------
# SW_SALT    Salinity from cndr, T, P
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_salt(cndr,T,P 	\
	,R,rt,Rp,Rt,S)
{
R  = cndr;
rt = sw_salrt(T);
Rp = sw_salrp(R,T,P);
Rt = R/(Rp*rt);
S  = sw_sals(Rt,T);

return S
}
#--------------------------------------------------------------------
# SW_SALS    Salinity of sea water
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_sals(Rt,T	\
	,a0,a1,a2,a3,a4,a5,b0,b1,b2,b3,b4,b5,k,Rtx,del_T,del_S,S)
{
a0 =  0.0080;
a1 = -0.1692;
a2 = 25.3851;
a3 = 14.0941;
a4 = -7.0261;
a5 =  2.7081;

b0 =  0.0005;
b1 = -0.0056;
b2 = -0.0066;
b3 = -0.0375;
b4 =  0.0636;
b5 = -0.0144;

k  =  0.0162;

Rtx   = sqrt(Rt);
del_T = T - 15;
del_S = (del_T/(1+k*del_T))*(b0+(b1+(b2+(b3+(b4+b5*Rtx)*Rtx)*Rtx)*Rtx)*Rtx);
	
S = a0+(a1+(a2+(a3+(a4+a5*Rtx)*Rtx)*Rtx)*Rtx)*Rtx;

S = S + del_S;

return S
}
#----------------------------------------------------------------------
# SW_SALRP   Conductivity ratio   Rp(S,T,P) = C(S,T,P)/C(S,T,0)
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_salrp(R,T,P		\
	,d1,d2,d3,d4,e1,e2,e3,Rp)
{
d1 =  3.426e-2;
d2 =  4.464e-4;
d3 =  4.215e-1;
d4 = -3.107e-3;

e1 =  2.070e-5;
e2 = -6.370e-10;
e3 =  3.989e-15;

Rp = 1 + ( P*(e1 + e2*P + e3*P*P) ) / (1 + d1*T + d2*T*T+(d3 + d4*T)*R);
 
return Rp
}
#-----------------------------------------------------------------------
# SW_SALRT   Conductivity ratio   rt(T)     = C(35,T,0)/C(35,15,0)
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_salrt(T		\
	,c0,c1,c2,c3,c4,rt)
{
c0 =  0.6766097;
c1 =  2.00564e-2;
c2 =  1.104259e-4;
c3 = -6.9698e-7;
c4 =  1.0031e-9;

rt = c0 + (c1 + (c2 + (c3 + c4*T)*T)*T)*T;

return rt
}
#--------------------------------------------------------------------
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_dpth(P,LAT		\
	,DEPTHM,top_line,bot_line,X,gam_dash,c4,c3,c2,c1,DEG2RAD)
{
DEG2RAD = pi()/180;
c1 = +9.72659;
c2 = -2.2512E-5;
c3 = +2.279E-10;
c4 = -1.82E-15;
gam_dash = 2.184e-6;

LAT = abs(LAT);
X   = sin(LAT*DEG2RAD);
X   = X*X;
bot_line = 9.780318*(1.0+(5.2788E-3+2.36E-5*X)*X) + gam_dash*0.5*P;
top_line = (((c4*P+c3)*P+c2)*P+c1)*P;
DEPTHM   = top_line/bot_line;

return DEPTHM
}
#--------------------------------------------------------------------
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_pres( DEPTH,LAT		\
	,pres , DEG2RAD,x,c1)

# SW_PRES    Pressure from depth
{
DEG2RAD = pi()/180;
x       = sin(abs(LAT)*DEG2RAD);
c1      = 5.92e-3 + x^2 * 5.25e-3;
pres    = ((1-c1)-sqrt(((1-c1)^2)-(8.84e-6 * DEPTH)))/4.42e-6;

return pres
}
#--------------------------------------------------------------------
# Function modified from Matlab Seawater Library Ver 1.2b, by Morgan
function sw_pden( S,T,P,PR	\
	,ptmp )

# SW_PDEN    Potential density
{
ptmp=sw_ptmp(S,T,P,PR);
return sw_dens(S,ptmp,PR)
}
#===========================================================================

function spice(s,t,p	\
	,B,sp, S,T)
#SPICE - spiciness by Flament	
# 
#USAGE -	spiciness = spice(s,t,p)
#
#EXPLANATION -	
#		s,t,p = the usual. 
#
#SEE ALSO -	
#

#PROGRAM - 	MATLAB code by c.m.duncombe rae
#
#CREATED -	2006/08/02 downloaded
#
#PROG MODS -	
#
#DISCLAIMER -	No responsibility can be accepted for failure or 
#		incorrect operation of this code. No guarantee, express 
#		or implied, is given. 
#
# function spiciness = spice(p,t,s)
# adapted from algorithm developed by
# P. Flament.
#
# SCKennan(Dec92)
#
# Home page at http://www.satlab.hawaii.edu/spice/

#		notes: vectorizing is possible when s and t are
#		integers. When s and t are vectors or matrix then
#		wingnut here has the easiest way I think.
#
# vectorize by S=(s-35).^[0:5];T=t.^[0:4];spic=(B*T) *S; or
# something.
{
B[1,1] = 0;
B[1,2] = 7.7442e-001;
B[1,3] = -5.85e-003;
B[1,4] = -9.84e-004;
B[1,5] = -2.06e-004;

B[2,1] = 5.1655e-002;
B[2,2] = 2.034e-003;
B[2,3] = -2.742e-004;
B[2,4] = -8.5e-006;
B[2,5] = 1.36e-005;

B[3,1] = 6.64783e-003;
B[3,2] = -2.4681e-004;
B[3,3] = -1.428e-005;
B[3,4] = 3.337e-005;
B[3,5] = 7.894e-006;

B[4,1] = -5.4023e-005;
B[4,2] = 7.326e-006;
B[4,3] = 7.0036e-006;
B[4,4] = -3.0412e-006;
B[4,5] = -1.0853e-006;

B[5,1] = 3.949e-007;
B[5,2] = -3.029e-008;
B[5,3] = -3.8209e-007;
B[5,4] = 1.0012e-007;
B[5,5] = 4.7133e-008;

B[6,1] = -6.36e-010;
B[6,2] = -1.309e-009;
B[6,3] = 6.048e-009;
B[6,4] = -1.1409e-009;
B[6,5] = -6.676e-010;

# N=nargin;
# if N==1, 
# 	if size(N,2)<=3,
# 		p=s(:,3);
# 		t=s(:,2);
# 		s=s(:,1);
# 	end;
# end;
		
# [r,c] = size(t);
# sp = zeros(r,c);
sp=0;
s = s - 35;
T = 1;
for (i = 1;i<=6;i++){
	S=1;
	for (j = 1;j<=5;j++){
        	sp = sp + B[i,j] *T *S;
		S = S*s;
		}
    	T = T*t;
}

return sp;
}

#===========================================================================


