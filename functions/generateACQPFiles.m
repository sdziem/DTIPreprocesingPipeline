function [pathToDWIACQP, pathToEPIACQP] = generateACQPFiles(pathToSubject, subjectID, includetopup)
%generateDWIACQPFile.m generates subject specific acqp file
%   This functions reads the dwi.json file to read out the total read out
%   time and saves the corresponding acqp file in the subjects dwi folder.
%   The function returns the fullpath to the generated file if generation
%   was successfull otherwhite the path is empty.
%
% Input:
%   pathToSubject  : string, absolute path to subjects BIDS folder
%   subjectID      : char, the full subject ID
%   includetopup   : boolean, indicating of topup will be applied
%
% Output:
%   pathToDWIACQP     : full path to ACPQ file of the DWI scan
%   pathToEPUACQP     : full path to ACPQ file of merged EPI (AP, PA) scans

dwiDir = dir([pathToSubject,'/dwi']);
dwiFileName = regexp(string(char(dwiDir.name)), '(\S*acq-64dir_dwi.json)', 'match');

pathToEPIACQP = [];
pathToDWIACQP = [];
 
if ~isempty(dwiFileName)
    dwiFileIdx = find(~cellfun(@isempty, dwiFileName), 1);
    dwiFileName = char(string(dwiFileName(dwiFileIdx)));
    
    val = jsondecode(fileread([pathToSubject 'dwi/' dwiFileName]));
    ES = val.DerivedVendorReportedEchoSpacing;
    if ~isempty(ES)
        EPIF = val.AcquisitionMatrixPE;
        t = ES*(EPIF-1);
    else
        if contains(pathToSubject, 'Site-SI')
            t = 0.0684;
        elseif contains(pathToSubejct, 'Site-RU')
            t = 0.08549;
        elseif contains(pathToSubject, 'Site-CBIC')
            t = 0.08034;
        end
    end
    
    fileID = fopen([pathToSubject 'dwi/' subjectID '_acqp.txt'],'w');
    fprintf(fileID,'0 -1 0 %1.4f\n',t);
    fclose(fileID);
    pathToDWIACQP = [pathToSubject  'dwi/' subjectID '_acqp.txt'];
else 
    pathToDWIACQP = [];
end

if includetopup
    fmapDir = dir([pathToSubject,'/fmap']);
    fmapFileAP = regexp(string(char(fmapDir.name)), '(sub-\w*-AP_acq-dwi_epi.json)|(sub-\w*-dwi*run-01*epi.json)', 'match');
    fmapFilePA = regexp(string(char(fmapDir.name)), '(sub-\w*-PA_acq-dwi_epi.json)|(sub-\w*-dwi*run-02*epi.json)', 'match');
    if ~(isempty(fmapFileAP) || isempty(fmapFilePA))
        fmapAPFileIdx = find(~cellfun(@isempty, fmapFileAP), 1);
        fmapFileAP = char(string(fmapFileAP(fmapAPFileIdx)));
        fmapPAFileIdx = find(~cellfun(@isempty, fmapFilePA), 1);
        fmapFilePA = char(string(fmapFilePA(fmapPAFileIdx)));
    end
    
    if ~(isempty(fmapFileAP) || isempty(fmapFilePA))
        
        valAP = jsondecode(fileread([pathToSubject 'fmap/' fmapFileAP]));
        valPA = jsondecode(fileread([pathToSubject 'fmap/' fmapFilePA]));
        ESAP = valAP.DerivedVendorReportedEchoSpacing;
        ESPA = valPA.DerivedVendorReportedEchoSpacing;
        
        if ~(isempty(ESAP) || isempty(ESPA))
            EPIFAP = valAP.AcquisitionMatrixPE;
            tAP = ESAP*(EPIFAP-1);
            EPIFPA = valPA.AcquisitionMatrixPE;
            tPA = ESPA*(EPIFPA-1);
        else
            if contains(pathToSubject, 'Site-SI')
                tAP = 0.0684;
                tPA = 0.0684;
            elseif contains(pathToSubejct, 'Site-RU')
                tAP = 0.08549;
                tPA = 0.08549;
            elseif contains(pathToSubject, 'Site-CBIC')
                tAP = 0.08034;
                tPA = 0.08034;
            end
        end
        
        fileID = fopen([pathToSubject 'fmap/' subjectID '_acqp.txt'],'w');
        fprintf(fileID,'0 -1 0 %1.4f\n',tAP);
        fprintf(fileID,'0 1 0 %1.4f\n',tPA);
        fclose(fileID);
        pathToEPIACQP = [pathToSubject  'fmap/' subjectID '_acqp.txt'];
    else
        pathToEPIACQP = [];
    end
end


