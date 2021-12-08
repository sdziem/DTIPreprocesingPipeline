function success = correctEpiDistortions(pathToSubject, subjectID, pathToEPIACQP)
%correctEpiDistortions.m corrects for suseptibility induces distortions
%   This functions performs the EPI distortion correction that estimates
%   suseptibility induced distortions based on the first b0 images that is
%   acquired in the dwi scan. These distortions are removed from all 
%   following dwi volumes. EPI distortion correction is performed using the
%   fsl tools topup and applytopup.
%
% Input:
%   pathToSubject   : string, absolute path to subjects BIDS folder
%   subjectID       : char, the full subject ID
%   pathToACQP      : absolute path to subjects acqp file
%
% Output:
%   success         : boolean, indicating if fsl commands completed 
%                     successfully

% epi files need to come in pairs AP and PA or run01 (AP) and run02 (PA)
fmapDir = dir([pathToSubject,'fmap']);
fmapFileAP = regexp(string(char(fmapDir.name)), '(sub-\w*-AP_acq-dwi_epi.nii.gz)|(sub-\w*_acq-dwi_run-01_epi.nii.gz)', 'match');
fmapFilePA = regexp(string(char(fmapDir.name)), '(sub-\w*-PA_acq-dwi_epi.nii.gz)|(sub-\w*_acq-dwi_run-02_epi.nii.gz)', 'match');
if ~(isempty(fmapFileAP) || isempty(fmapFilePA))
    fmapAPFileIdx = find(~cellfun(@isempty, fmapFileAP), 1);
    fmapFileAP = char(string(fmapFileAP(fmapAPFileIdx)));
    fmapPAFileIdx = find(~cellfun(@isempty, fmapFilePA), 1);
    fmapFilePA = char(string(fmapFilePA(fmapPAFileIdx)));
end

% merge both blips
cd([pathToSubject,'fmap'])
cmd = sprintf('fslmerge -t %s-both_acp-dwi_epi %s %s', subjectID, fmapFileAP, fmapFilePA);
[status, ~] = system(cmd);
if status~=0
    success = false;
    return
end

cd([pathToSubject, 'derivatives'])
% run topup and save results in derivatives folder
cmd = sprintf('topup --imain=%sfmap/%s-both_acp-dwi_epi --datain=%s --config=b02b0.cnf --out=%s_topup_results --iout=%s_topup_b0', ...
        pathToSubject, subjectID, pathToEPIACQP, subjectID, subjectID); 
[status, ~] = system(cmd);
if status~=0
    success = false;
    return
end

success = true;

end