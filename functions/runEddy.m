function success = runEddy(pathToSubject, subjectID, site, pathToIndex, includetopup)
%runEddy.m runt eddy current and motion correction
%   This functions runs the newest version of eddy current and motion
%   correction if include topup is used. Then also succeptibility induced
%   distortions that shange with the subjects motion are excluded. This
%   version also runs with the CNR maps flag. 
%
% Input:
%   pathToSubject  : string, absolute path to subjects BIDS folder
%   subjectID      : char, the full subject ID
%   site           : acquisition site the data was recorded: SI, RU, or CB
%   pathToIndex    : full path to index file that is the same for all sub
%   includetopup   : boolean, indicating of topup will be applied
%
% Output:
%   success        : boolean indicating success of processing


generateSlspecFile(pathToSubject, subjectID, site);

cd([pathToSubject 'derivatives/'])
mkdir('eddy_cuda');
outname = ['eddy_cuda/' subjectID '_eddy_cuda'];
pathToDwi = [pathToSubject 'dwi/'];

if includetopup
    cmd = sprintf(['/usr/local/fsl_corrected/fsl/bin/eddy_cuda9.1 --imain=%s_acq-64dir_dwi_denoised.nii.gz --acqp=%s%s_acqp.txt --index=%s --mask=%s_topup_b0_brain_mask.nii.gz --bvecs=%s%s_acq-64dir_dwi.bvec --bvals=%s%s_acq-64dir_dwi.bval --topup=%s_topup_results --out=%s --estimate_move_by_susceptibility --niter=8 --fwhm=10,6,4,2,0,0,0,0 --repol --ol_type=both --mporder=8 --s2v_niter=8  --cnr_maps  --slspec=slspec.txt --very_verbose'], ...
        subjectID, pathToDwi, subjectID, pathToIndex, subjectID, pathToDwi, subjectID, pathToDwi, subjectID, subjectID, outname);
else
    disp('running no include topup of eddy')
    cmd = sprintf(['/usr/local/fsl_corrected/fsl/bin/eddy_cuda9.1 --imain=%s_acq-64dir_dwi_denoised.nii.gz --acqp=%s%s_acqp.txt --index=%s --mask=%s_dwi_b0_brain_mask.nii.gz --bvecs=%s%s_acq-64dir_dwi.bvec --bvals=%s%s_acq-64dir_dwi.bval --out=%s --niter=8 --fwhm=10,6,4,2,0,0,0,0 --repol --ol_type=both --mporder=8 --s2v_niter=8  --cnr_maps  --slspec=slspec.txt --very_verbose'], ...
        subjectID, pathToDwi, subjectID, pathToIndex, subjectID, pathToDwi, subjectID, pathToDwi, subjectID, outname);
end

[status, ~] = system(cmd);
if status~=0
    success = false;
else
    success = true;
end

end