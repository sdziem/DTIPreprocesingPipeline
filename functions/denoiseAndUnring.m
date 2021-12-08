function denoiseAndUnring(pathToSubject, subjectID)
%denoiseAndUnring.m performs denoising and gibbsion unringing
%   This functions used the absolute file path to the subject dwi scan to 
%   perform denoising and Gibbsion ringing artefact corrections. The output
%   will be saved in the afq_data folder. 
%
% Input:
%   pathToSubject  : string, absolute path to subjects BIDS folder 
%   subjectID      : char, the full subject ID
%
        data = load_untouch_nii([pathToSubject 'dwi/' subjectID '_acq-64dir_dwi.nii.gz']);
        [data_denoised, ~] = MPdenoising(data.img, [], [], 'fast');
        data.img = data_denoised;
        data.img = unring(data.img);
        data.hdr.dime.glmax = max(data.img(:));
        save_untouch_nii(data, [pathToSubject 'derivatives/' subjectID '_acq-64dir_dwi_denoised.nii.gz']);
end