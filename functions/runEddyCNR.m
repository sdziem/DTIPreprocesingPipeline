function runEddyCNR(pathToSubject, subjectID, pathToIndex)
%runEddy.m runt eddy current and motion correction
%   This functions runs the newest version of eddy current and motion
%   correction with the cnr_maps flag enabled
%
% Input:
%   pathToSubject  : string, absolute path to subjects BIDS folder
%   subjectID      : char, the full subject ID
%   pathToIndex    : full path to index file that is the same for all sub


cd([pathToSubject 'derivatives/'])
mkdir('eddy_cuda_cnr');
outname = ['eddy_cuda_cnr/' subjectID '_eddy_cuda'];
pathToDwi = [pathToSubject 'dwi/'];


disp('running no include topup of eddy')
cmd = sprintf(['/usr/local/fsl_corrected/fsl/bin/eddy_cuda9.1 --imain=%s_acq-64dir_dwi_denoised.nii.gz --acqp=%s%s_acqp.txt --index=%s --mask=%s_dwi_b0_brain_mask.nii.gz --bvecs=%s%s_acq-64dir_dwi.bvec --bvals=%s%s_acq-64dir_dwi.bval --out=%s --niter=8 --fwhm=10,6,4,2,0,0,0,0 --repol --ol_type=both --mporder=8 --s2v_niter=8 --cnr_maps --slspec=slspec.txt --very_verbose'], ...
        subjectID, pathToDwi, subjectID, pathToIndex, subjectID, pathToDwi, subjectID, pathToDwi, subjectID, outname);

system(cmd)
end
