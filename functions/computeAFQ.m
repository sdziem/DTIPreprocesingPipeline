function [afq0, afq1]  = computeAFQ(pathToSubject)

rmpath('/mnt/methlab-drive/toolboxes/spm8/external/fieldtrip/src/')
dt6dirs = {[pathToSubject ,'/derivatives/dtifit_eddy_cuda']};

% AFQ Create 0
afq0 = AFQ_Create('cutoff',[5 95], 'sub_dirs', dt6dirs, 'sub_group', zeros(size(dt6dirs,1),1), 'clip2rois', 0);
afq0.params.track.faThresh = 0.2;
afq0.params.track.faMaskThresh = 0.3;
afq0.params.track.angleThresh = 35;
afq0 = AFQ_run([],[],afq0);

% AFQ Create 1
afq1 = AFQ_Create('cutoff',[5 95], 'sub_dirs', dt6dirs, 'sub_group', zeros(size(dt6dirs,1),1), 'clip2rois', 1);
afq1.params.track.faThresh = 0.2;
afq1.params.track.faMaskThresh = 0.3;
afq1.params.track.angleThresh = 35;
afq1 = AFQ_run([],[],afq1);

end