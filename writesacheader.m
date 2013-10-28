
clear;

%%  Get event information from HarvardCMT.mat file
load('harvardCMT.mat'); %loads the cmt structure

sta_list = {'AGAN','rotB','rotD','rotE','rotF','rotG','rotH','rotJ'};

eventtime = datenum(cmt.year,cmt.month,cmt.day);
[dist azi] = distance(cmt.lat,cmt.long,centloc(1),centloc(2));

goodev = find(eventtime > bgtime & eventtime < endtime ...
			& cmt.Mb > magrange(1) & cmt.Mb < magrange(2) ...
			& dist > distrange(1) & dist < distrange(2) ...
			& cmt.depth > depthrange(1) & cmt.depth < depthrange(2));

infoevs={'year','month','day','jjj','hour','minute','sec','lat','long','depth'};
for j=1:length(infoevs)
    assignin('base',char(infoevs(j)),eval(sprintf('cmt.%s(goodev)',char(infoevs(j)))));
    eval(sprintf('ev%s=%s;',char(infoevs(j)),char(infoevs(j))));
end

eventnum=0;
for ie=1:length(goodev)
    gcarc = distance(evlat(ie),evlong(ie),stla,stlo);
    if  gcarc > minang...
		&& gcarc < maxang...
%		&& datenum(evyear(ie),evmonth(ie),evday(ie)) > datenum(ondate)...
%		&& datenum(evyear(ie),evmonth(ie),evday(ie)) < datenum(offdate)...
%		&& evdepth(ie) < 100 

		eventid=[num2str(evyear(ie)), sprintf('%3s',num2str(jjj(ie))) ...
				, sprintf('%2s',num2str(evhour(ie))), sprintf('%2s',num2str(evminute(ie)))];
		eventid(find(eventid==' '))='0';

		filelist=dir(sprintf('./data/%s/',eventid));
		filenum=length(filelist)-2;
		if filenum > 10
			eventnum=eventnum+1;
			disp(eventid)
			% copy the file to gooddata folder
			system(sprintf('cp -r ./data/%s ./gooddata/',eventid));

			% generate sac macro file to fill the sac header as well as down-sample the data
			sacfp=fopen('sacmacrotemp.sh','w');
			fprintf(sacfp,'source ~/.bashrc\n');
			fprintf(sacfp,'sac<<!\n');
			fprintf(sacfp,'r ./gooddata/%s/*.sac.?\n',eventid);
			fprintf(sacfp,'ch LOVROK true\n');
			fprintf(sacfp,'ch evla %f\n',evlat(ie));
			fprintf(sacfp,'ch evlo %f\n',evlong(ie));
			fprintf(sacfp,'ch evdp %f\n',evdepth(ie));
			fprintf(sacfp,'ch nzyear %d\n',evyear(ie));
			fprintf(sacfp,'ch nzjday %d\n',evjjj(ie));
			fprintf(sacfp,'ch nzhour %d\n',evhour(ie));
			fprintf(sacfp,'ch nzmin %d\n',evminute(ie));
			fprintf(sacfp,'ch nzsec %d\n',evsec(ie));
			fprintf(sacfp,'ch nzmsec 0\n');
			fprintf(sacfp,'wh\n');
			fprintf(sacfp,'q\n');
			fprintf(sacfp,'!\n');
			fclose(sacfp);

			system('bash sacmacrotemp.sh');
		end

	end

end
