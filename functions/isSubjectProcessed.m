function processed = isSubjectProcessed(pathToSubject)
%checkProcessingStatus.m checks the processingstatus of a single subject
%   This functions checks if the subjects results folders contains the 
%   afq_pec.mat file which is the ending file of the processing pipeline
%
%   Input: 
%       pathToSubject  : string, absolute path to subjects BIDS folder 
%
%   Output: 
%       processed      : boolean, indicating processing status

resultsDir = dir([pathToSubject filesep 'derivatives/afq_results/']);
afqPecFile = regexp(string(char(resultsDir.name)), '(afq_pec.mat)', 'match');
processed = ~isempty(afqPecFile);

end