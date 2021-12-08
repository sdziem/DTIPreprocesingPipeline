function generateSlspecFile(pathToSubject, subjectID, site)

% create slspec-file for each subject
if site == 'RU'
    fp = fopen([pathToSubject '/dwi/' subjectID '_acq-64dir_dwi_merged.json'],'r');
    if fp < 0
        fclose all
        fp = fopen([pathToSubject '/dwi/' subjectID '_acq-64dir_dwi_mergedAvg.json'],'r');
    end
else
    fp = fopen([pathToSubject '/dwi/' subjectID '_acq-64dir_dwi.json'],'r');
end

fcont = fread(fp);
fclose(fp);
cfcont = char(fcont');
i1 = strfind(cfcont,'SliceTiming');
i2 = strfind(cfcont(i1:end),'[');
i3 = strfind(cfcont((i1+i2):end),']');
cslicetimes = cfcont((i1+i2+1):(i1+i2+i3-2));
slicetimes = textscan(cslicetimes,'%f','Delimiter',',');
[sortedslicetimes,sindx] = sort(slicetimes{1});
mb = length(sortedslicetimes)/(sum(diff(sortedslicetimes)~=0)+1);
slspec = reshape(sindx,[mb length(sindx)/mb])'-1;
dlmwrite([pathToSubject '/derivatives/slspec.txt'],slspec,'delimiter',' ','precision','%3d');

end