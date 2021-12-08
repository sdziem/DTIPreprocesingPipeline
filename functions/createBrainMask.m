function success = createBrainMask(pathToSubject, subjectID, includetopup)
%createBrainMask.m created brain masks from b0
%   This functions uses the output of topup to create brain masks using
%   fsl if topup was included, otherwise it uses the first b0 of the dwi
%   scan to create a brain mask and saved this b0 in the dwi folder.
%
% Input:
%   pathToSubject   : string, absolute path to subjects BIDS folder
%   subjectID       : char, the fulls subject ID
%   includetopup    : boolean, indicating if topup was included
%
% Output:
%   success         : boolean, indicating if fsl commands completed
%                     successfully


if includetopup
    cd([pathToSubject 'derivatives'])
    cmd = sprintf('Bet %s_topup_b0  %s_topup_b0_brain -f 0.1 -m', ...
        subjectID, subjectID);
    [status, ~] = system(cmd);
else
    dwiDir = dir([pathToSubject, 'dwi']);
    dwiFile = regexp(string(char(dwiDir.name)), '(\S*_acq-64dir_dwi.nii.gz)', 'match');
    dwiFileIdx = find(~cellfun(@isempty, dwiFile), 1);
    dwiFile = char(string(dwiFile(dwiFileIdx)));
    % first create a b0 out of the dwi scan
    cd([pathToSubject, 'dwi'])
    cmd = sprintf('fslroi %s %s_dwi_b0 0 1', dwiFile, subjectID);
    [status, ~] = system(cmd);
    
    if status==0
        %s_topup_b0  %s_topup_b0_brain -f 0.1 -m', ...
        cd([pathToSubject 'derivatives'])
        cmd = sprintf('Bet %sdwi/%s_dwi_b0  %s_dwi_b0_brain -f 0.1 -m', pathToSubject, subjectID, subjectID);
        [status, ~] = system(cmd); 
    end 
end

if status~=0
    success = false;
else
    success = true;
end
end