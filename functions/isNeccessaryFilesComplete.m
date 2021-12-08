function complete = isNeccessaryFilesComplete(pathToSubject, includetopup)
%checkNeccessaryFilesComplete.m checks if subject folder contains all files 
%needed for the pipeline
%   This functions checks if the subjects BIDS folder contains a dwi scan
%   and any t1-weighted image. If the include topup is true, then it also 
%   checks for both epi scans. These need to come in pairs, AP and PA or 
%   run-01 and run-02 respectively. If all are complete if returns a list 
%   with the absolute paths to the files, otherwise if any is missing it 
%   returns an empty list.
%
% Input:
%   pathToSubject  : string, absolute path to subjects BIDS folder
%   includetopup   : boolean, indicating if to seach for epi files
%
%Output:
%   complete       : boolean indicating the status if all needed files are
%                    complete


dwiDir = dir([pathToSubject, 'dwi']);
dwiFile = regexp(string(char(dwiDir.name)), '(\S*_acq-64dir_dwi.nii.gz)', 'match');
if ~isempty(dwiFile)
    dwiFileIdx = find(~cellfun(@isempty, dwiFile), 1);
    dwiFile = char(string(dwiFile(dwiFileIdx)));
end
anatDir = dir([pathToSubject,'anat']);
anatFile = regexp(string(char(anatDir.name)), '(\w*_T1w.nii.gz)|(\w*_acq-HCP_T1w.nii.gz)|(\w*_acq-HCP_run-01_T1w.nii.gz)|(\w*_acq-VNavNorm_T1w.nii.gz)', 'match');
if ~isempty(anatFile)
    anatFileIdx = find(~cellfun(@isempty, anatFile), 1);
    anatFile = char(string(anatFile(anatFileIdx)));
end

if includetopup
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
else
    fmapFileAP = 'void';
    fmapFilePA = 'void';
end

if (isempty(dwiFile) || isempty(anatFile) || isempty(fmapFileAP) || isempty(fmapFilePA))
    complete = false;
else
    complete = true;
end

end