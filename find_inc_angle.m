function [inc_angle diagS] = find_inc_angle(dataZ,dataR)
%% function to calculate the incident angle using covariance matrix decomponsation

[U,S,V] = svd(cov(dataZ(:),dataR(:)));
diagS = diag(S);

inc_angle = angle(-U(1,1)-i*U(2,1));
inc_angle = rad2deg(inc_angle);
