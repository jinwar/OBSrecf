% scripts try to fit direct P ray parameters with epidist

clear
epidists = 30:5:90;

for ie = 1:length(epidists)
	P_info = tauptime('mod','prem','ph','P','deg',epidists(ie),'dep',0);
	rayp(ie) = P_info(1).rayparameter;
	rayp(ie) = rayp(ie)./deg2km(1);
end

para = polyfit(epidists,rayp,3);

disp([sprintf('rayp = %e *d^3 + %e *d^2 + %e *d + %e',para(1),para(2),para(3),para(4))]);
