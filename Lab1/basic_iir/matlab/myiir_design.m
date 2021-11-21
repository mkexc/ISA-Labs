function [bi, ai, bq, aq, ci, cq]=myiir_design(N,nb)
%% function myiir_design(N,nb)
%% N is order of the filter
%% nb is the number of bits
%% bi,ai taps represented as integers
%% bq,aq quantized taps
%% ci and cq are array with the coefficients after 1-unrolling

close all;

f_cut_off = 2000; % 2kHz
f_sampling = 10000; % 10kHz

f_nyq = f_sampling/2; % Nyquist frequency
f0 = f_cut_off/f_nyq; % Normalized cut-off frequency

[b,a]=butter(N, f0) % get filter coefficients
[h1, w1]=freqz(b,a); % get the transfer function of the designed filter

bi=floor(b*2^(nb-1)) % convert b coefficients into nb-bit integers
bq=bi/2^(nb-1); % convert back b coefficients as nb-bit real values
ai=floor(a*2^(nb-1)) % convert a coefficients into nb-bit integers
aq=ai/2^(nb-1); % convert back a coefficients as nb-bit real values
[h2, w2]=freqz(bq,aq); % get the transfer function of the quantized filter

%% Coefficients after 1-unrolling of filter
c=[0,0,0,0]; %initialize the array
c(1)=b(1);            %B0
c(2)=b(2)-a(2)*b(1);  %B1-A1*B1
c(3)=-a(2)*b(2);      %-A1*B1  
c(4)=a(2)^2;          %A2^2

ci=floor(c*2^(nb-1)); % convert c coefficients into nb-bit integers
cq=ci/2^(nb-1); % convert back c coefficients as nb-bit real values

%% show the transfer functions
plot(w1/pi, 20*log10(abs(h1)));
hold on;
plot(w2/pi, 20*log10(abs(h2)),'r--');
grid on;
xlabel('Normalized frequency');
ylabel('dB');
title("Filter transfer function");