function calculateWMTI(pathToSubject, dt, binMask, data)

akc = 'undefined';


% Calculate WMTI and export it (takes quiet some time)
mkdir([pathToSubject,'/derivatives/wmti_eddy_cuda'])
cd([pathToSubject,'/derivatives/wmti_eddy_cuda'])

data.hdr.dime.dim(1) = 3;
data.hdr.dime.dim(5) = 1;
data.hdr.dime.pixdim(5) = 0;
[awf, eas, ias] = wmti_parameters(dt, binMask);

if akc ~= 'undefined' % has to be like this because strcmp might not work if akc actually has a value
    [awf, ~] = repnan(awf, binMask, akc_out);
end
data.img = awf;
data.hdr.dime.glmax = max(awf(:));
save_untouch_nii(data,'awf.nii');
fields = fieldnames(ias);
for ff = 1:numel(fields)
    paramsii = getfield(ias, fields{ff});
    if akc ~= 'undefined'
        [paramsii, ~] = repnan(paramsii, binMask, akc_out);
    end
    savename = fullfile(pathToSubject, 'derivatives/wmti_eddy_cuda', ['ias_', fields{ff}, '.nii']);
    data.img = paramsii;
    data.hdr.dime.glmax = max(paramsii(:));
    save_untouch_nii(data, savename);
end
fields = fieldnames(eas);
for gg=1:numel(fields)
    paramsii = getfield(eas, fields{gg});
    if akc ~= 'undefined'
        [paramsii, ~] = repnan(paramsii, binMask, akc_out);
    end
    savename = fullfile(pathToSubject, 'derivatives/wmti_eddy_cuda', ['eas_', fields{gg}, '.nii']);
    data.img = paramsii;
    data.hdr.dime.glmax = max(paramsii(:));
    save_untouch_nii(data, savename);
end

end