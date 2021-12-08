% This script it the DESIGNER preprocessing Workflow. It includes all steps
% and includes topup computations.
clear all

% set FSL environment
setenv('FSLDIR', '/usr/local/fsl_corrected/fsl');
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % setting output type
% other toolboxes
addpath(genpath('/mnt/methlab-drive/toolboxes/'));
% wrapper functions
addpath('/mnt/methlab-drive/methlab-analysis/sdziem/DKIRevised/functions')
addpath('/mnt/methlab-drive/methlab-analysis/sdziem/Utility')
%delete(gcp('nocreate'))
%sparpool(7, 'IdleTimeout',Inf)

allSites = ['SI'; 'RU'; 'CB'; 'CU'];

load('subjectsCorruptData.mat')
load('subjectsIncompDirCBIC.mat')

pathToIndex = '/mnt/methlab-drive/methlab-analysis/sdziem/DKIRevised/index.txt';
options.Kurtosis = 1;
includetopup = false;

for s = 2:2
    site = allSites(s, :);
    
    pathAllSubjects = ['/mnt/methlab-drive/methlab_data/HBN/MRI/Site-' site '/'];
    allSubjectIDs = dir([pathAllSubjects 'sub-*']);
    
    parfor iSub = 1:length(allSubjectIDs)
        iSub
        try
            pathToSubject = [allSubjectIDs(iSub).folder '/' allSubjectIDs(iSub).name '/'];
            subjectID = char(string(allSubjectIDs(iSub).name));
            
            % exclude corrupt data sets and subject where diff directions are
            % incompatible because only on half a sphere
            if ismember(string(subjectID), subjectsCorruptData)
                continue
            end
            if ismember(string(subjectID), subjectsIncompDirCBIC)
                continue
            end
            
            % step 0: log date and software versions used
            diary([pathToSubject filesep subjectID '_processingLog.txt']);
            diary on
            date
            version
            
            % step 1:
            disp('Checking subjects processing status.')
            if isSubjectProcessed(pathToSubject)
                continue
            end
            
            % step 2 :
            disp('Cheking neccessary files for pipeline.')
            if ~isNeccessaryFilesComplete(pathToSubject, includetopup)
                continue
            end
            mkdir([pathToSubject, 'derivatives'])
            
            
            % step 3:
            disp('Generate ACQP files based on DWI and EPI scan.')
            [pathToDWIACQP, pathToEPIACQP] = generateACQPFiles(pathToSubject, subjectID, includetopup);
            
            disp('Step 1+2: Denoising and Gibbson Unringing.')
            % DESIGNER pipeline step 1+2: Denoising and Gibbson Unringing
            denoiseAndUnring(pathToSubject, subjectID);
            
            
            % DESIGNER pipeline step 3: EPI distortion correction
            if includetopup
                disp('Step 3: EPI distortion correction.')
                if ~correctEpiDistortions(pathToSubject, subjectID, pathToEPIACQP)
                    continue
                end
            end
            
            % step 4: bet
            disp('Extracting brain.')
            if ~createBrainMask(pathToSubject, subjectID, includetopup)
                continue
            end
      
            % step 5: eddy cuda
            disp('Generating slspec.txt file and run eddy_cuda with cnr flag enabled.')
            if ~runEddy(pathToSubject, subjectID, site, pathToIndex, includetopup)
                continue
            end
           
            

            % step 6:
            disp('Importing data.')
            bvec = dlmread([pathToSubject 'derivatives/eddy_cuda/' subjectID '_eddy_cuda.eddy_rotated_bvecs']);
            bval = dlmread([pathToSubject 'dwi/' subjectID '_acq-64dir_dwi.bval']);
            bvec = bvec';
            bval = bval';
                        
            correctedDwiData = load_untouch_nii([pathToSubject 'derivatives/eddy_cuda/' subjectID '_eddy_cuda.nii.gz']);
            if includetopup
                binMask = load_untouch_nii([pathToSubject 'derivatives/' subjectID '_topup_b0_brain.nii.gz']);
            else
                binMask = load_untouch_nii([pathToSubject 'derivatives/' subjectID '_dwi_b0_brain.nii.gz']);
            end
            
            binMask = logical(binMask.img);
            
            % DESIGNER pipeline step 5: outlier detection
            disp('Detecting Outliers.')
            outliers = irlls(correctedDwiData.img, binMask, bvec, bval, [], options);
            
            % step 7: Tensor Fitting
            disp('Tensor Fitting.')
            [~, dt] = dki_fit(correctedDwiData.img, [bvec,bval], binMask, [0,1,0], outliers, Inf);
            
            % step 8: Extract DKI Parameters
            extractAndExportDKIParameters(pathToSubject, dt, binMask, correctedDwiData);
            
            % step 9: Calculate WMTI
            calculateWMTI(pathToSubject, dt, binMask, correctedDwiData);
            
            % step 10: Auto-align T1 to ACPC
            disp('Running AutoAlign.')
            anatDir = dir([pathToSubject,'anat']);
            anatFile = regexp(string(char(anatDir.name)), '(\w*_T1w.nii.gz)|(\w*_acq-HCP_T1w.nii.gz)|(\w*_acq-HCP_run-01_T1w.nii.gz)|(\w*_acq-VNavNorm_T1w.nii.gz)', 'match');
            anatFile = char(string(anatFile(find(~cellfun(@isempty, anatFile), 1))));
            mrAnatAutoAlignAcpcNifti([pathToSubject,'anat/sub-' anatFile], [pathToSubject,'anat/sub-' anatFile(1:end-7) '_acpc.nii.gz'])
            
            % step 11:Create dt6 file
            disp('Creating DT6 File.')
            
            if includetopup
                copyfile([pathToSubject 'derivatives/' subjectID '_topup_b0.nii.gz'], ...
                [pathToSubject 'derivatives/dtifit_eddy_cuda/dti_b0.nii.gz']);
            else
                copyfile([pathToSubject 'dwi/' subjectID '_dwi_b0.nii.gz'], ...
                [pathToSubject 'derivatives/dtifit_eddy_cuda/dti_b0.nii.gz']);
            end
            copyfile([pathToSubject 'anat/sub-' anatFile(1:end-7) '_acpc.nii.gz'], ...
                [pathToSubject 'derivatives/dtifit_eddy_cuda/T1w_acpc.nii.gz']);
            
            
            cd([pathToSubject 'derivatives/dtifit_eddy_cuda'])
            dtiMakeDt6FromFsl('dti_b0.nii.gz', 'T1w_acpc.nii.gz', 'dt6.mat');
            
            % step 12: Compute AFQ
            [afq0, afq1] = computeAFQ(pathToSubject);
            
            % step 13: save results
            mkdir([pathToSubject  'derivatives/afq_results/'])
            saveInParfor([pathToSubject  'derivatives/afq_results/'  subjectID '_afq_pec.mat'], subjectID, afq0, afq1)
            
            % step 14: plot tractography and save image: cannot be plotted
            % as not deep learning toolbox, can be plotted afterwards
            %plotAfqResults(pathToSubject, subjectID);
                      
        catch ME
            ME.message
            diary off
        end
        diary off
    end
end
