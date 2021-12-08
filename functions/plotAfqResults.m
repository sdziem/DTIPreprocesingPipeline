function plotAfqResults(pathToSubject, subjectID)

% Plot all fibers
% wholebrainFG = AFQ_WholebrainTractography(dt,'test');
wholebrainFG = load([pathToSubject '/derivatives/dtifit_eddy_cuda/fibers/WholeBrainFG.mat']);
fg = wholebrainFG.fg;
dt = dtiLoadDt6([pathToSubject '/derivatives/dtifit_eddy_cuda/dt6.mat']);

% color fibers according to FA value
vals = dtiGetValFromFibers(dt.dt6, fg, inv(dt.xformToAcpc), 'fa');
rgb = vals2colormap(vals);
AFQ_RenderFibers(fg, 'numfibers', 1000, 'color', rgb)

% add a sagittal slice from the subject's b0 image to the plot

anatDir = dir([pathToSubject,'anat']);
anatFile = regexp(string(char(anatDir.name)), '(\w*_T1w_acpc.nii.gz)|(\w*_acq-HCP_T1w_acpc.nii.gz)|(\w*_acq-HCP_run-01_T1w_acpc.nii.gz)|(\w*_acq-VNavNorm_T1w_acpc.nii.gz)', 'match');
if ~isempty(anatFile)
    anatFileIdx = find(~cellfun(@isempty, anatFile), 1);
    anatFile = char(string(anatFile(anatFileIdx)));
end
t1 = readFileNifti([pathToSubject,'anat/sub-' anatFile]);

% add the slice X = -2 to the 3d rendering
AFQ_AddImageTo3dPlot(t1,[-1, 0, 0]);

saveas(gcf, [pathToSubject 'derivatives/afq_results/' subjectID '_WholeBrainTractography.png'])
savefig(gcf, [pathToSubject 'derivatives/afq_results/' subjectID '_WholeBrainTractography.fig'])

end
