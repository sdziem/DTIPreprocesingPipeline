function extractAndExportDKIParameters(pathToSubject, dt, binMask, data)

% Extracting Parameters
[FA, MD, RD, AD, FE, MK, RK, AK, L1, L2, L3, V1, V2, V3] = dki_parameters(dt, binMask);

% Export DTI
mkdir([pathToSubject,'derivatives/dtifit_eddy_cuda'])
allDtiMaps = {'FA', 'MD', 'RD', 'AD', 'FE', 'L1', 'L2', 'L3', 'V1', 'V2', 'V3'};
allDtiVars = {FA, MD, RD, AD, FE, L1, L2, L3, V1, V2, V3};
for iDTIVar = 1:size(allDtiVars, 2)
    var = allDtiVars{1,iDTIVar};
    bgvalue = 0;
    var(isnan(var)) = bgvalue;
    nii = data;
    nii.hdr.dime.dim(2) = size(var, 1);
    nii.hdr.dime.dim(3) = size(var, 2);
    nii.hdr.dime.dim(4) = size(var, 3);
    nii.hdr.dime.dim(5) = size(var, 4);
    nii.hdr.dime.datatype = 16;
    nii.hdr.dime.bitpix = 32;
    nii.img = feval('single', var);
    save_untouch_nii(nii, [pathToSubject,'derivatives/dtifit_eddy_cuda/dti_'  allDtiMaps{1,iDTIVar} '.nii.gz']);
end

% Export DKI:
mkdir([pathToSubject,'derivatives/dkifit_eddy_cuda'])
allDkiMaps = {'MK', 'RK', 'AK'};
allDkiVars = {MK, RK, AK};
for iDKIVar = 1:size(allDkiVars, 2)
    var = allDkiVars{1, iDKIVar};
    bgvalue = 0;
    var(isnan(var)) = bgvalue;
    nii = data;
    nii.hdr.dime.dim(2) = size(var, 1);
    nii.hdr.dime.dim(3) = size(var, 2);
    nii.hdr.dime.dim(4) = size(var, 3);
    nii.hdr.dime.dim(5) = size(var, 4);
    nii.hdr.dime.datatype = 16;
    nii.hdr.dime.bitpix = 32;
    nii.img = feval('single', var);
    save_untouch_nii(nii, [pathToSubject,'derivatives/dkifit_eddy_cuda/dki_' allDkiMaps{1,iDKIVar} '.nii.gz']);
end
end