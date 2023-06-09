%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-2nd-2023
%   For preprocessing of ABIDE dataset
%   Reorientation -> Cut time -> Realignment -> Framewise displacement -> Skull strip -> Coregistration ->
%   Segmentation & Dartel -> Normalization -> PCA with mask -> Temporal regression -> Smoothing -> Filtering
%
%   You Sould download the 'cprintf' function file before starting this.
%   https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-command-window#version_history_tab

%%  Initialization
clear; clc; spm quit ;

%%  Setting File Location (Should check these variables every time !!!!!)
%   Path of experiment folder
data_drive = 'f' ;
script_path = fullfile('USE', '001_Mine', '002_ASD', 'Scripts', 'ABIDE') ;
data_path = fullfile('USE', '001_Mine', '002_ASD', 'Data') ;
selected_path = fullfile('001_ABIDE_I', 'NYU_Langone_Medical_Center') ;

%   Set common name of all subjects folder
common_subj_name = '5' ;
common_sess_name = 'session_' ;

%   Set functional and anatomical data folder name
func_folder_name = 'func' ;     %   Funcational folder
anat_folder_name = 'anat' ;     %   Anatomical folder

%   Set functional and anatomical data basic file name
func_data_name = 'rest' ;       %   Funcational data name
anat_data_name = 'mprage' ;     %   Anatomical data name

%   TR time(ms) (Should check separately by using AFNI(3dinfo))
TR_value = 2 ;

%   Voxel size of functional data
voxel_value = 3 ;

%   Basic SPM12 location
% spm_path = fullfile('Users', 'sohnw', 'Use', 'For_MATLAB', 'spm12', 'spm12', 'tpm') ;
spm_path = fullfile('Users', 'sohnw', 'Use', 'For_MATLAB', 'spm12', 'tpm') ;

%%  Check experiment options
%   Select operating system
sys_ques_ans = questdlg('What operating system is the current program running on?',...
                        'System options', ...
                        'Windows', 'Ubuntu',...
                        'Windows') ;
switch sys_ques_ans
    case 'Windows'
        cprintf('blue', 'Now operating system is %s.\n', sys_ques_ans) ;
        system_type = ':' ;
    case 'Ubuntu'
        cprintf('blue', 'Now operating system is %s.\n', sys_ques_ans) ;
        system_type = '/mnt' ;
end

%   Select age group
age_ques_ans = questdlg('Which age group do you want to analyse?',...
                        'Age group options', ...
                        'Children', 'Adolescents', 'Adults',...
                        'Children') ;
switch age_ques_ans
    case 'Children'
        cprintf('blue', 'Now age group is %s.\n', age_ques_ans) ;
        age_grp = 'Children' ;
    case 'Adolescents'
        cprintf('blue', 'Now age group is %s.\n', age_ques_ans) ;
        age_grp = 'Adolescents' ;
    case 'Adults'
        cprintf('blue', 'Now age group is %s.\n', age_ques_ans) ;
        age_grp = 'Adults' ;
end

%   Select experiment group
exp_ques_ans = questdlg('Which experiment group do you want to analyse?',...
                        'Experiment group options', ...
                        'ASD', 'TC',...
                        'ASD') ;
switch exp_ques_ans
    case 'ASD'
        cprintf('blue', 'Now age group is %s.\n\n\n', exp_ques_ans) ;
        exp_grp = 'ASD' ;
    case 'TC'
        cprintf('blue', 'Now age group is %s.\n\n\n', exp_ques_ans) ;
        exp_grp = 'TC' ;
end

%%  Automatically define them by the above setted variables
%   Full path of important folders
switch sys_ques_ans
    case 'Windows'
        script_basic_path = fullfile([data_drive system_type], script_path) ;
        data_basic_path = fullfile([data_drive system_type], data_path) ;
        spm_location = fullfile(['c' system_type], spm_path) ;
    case 'Ubuntu'
        script_basic_path = fullfile(system_type, data_drive, script_path) ;
        data_basic_path = fullfile(system_type, data_drive, data_path) ;
        spm_location = fullfile(system_type, 'c', spm_path) ;
end

%   Full address of age group
work_basic_path = fullfile(data_basic_path, selected_path, age_grp) ;
%   Full address of experiment group
now_grp_path = fullfile(work_basic_path, exp_grp) ;

%   Canonical space
adults_tpm = fullfile(spm_location, 'TPM.nii,') ;
child_adole_tpm = fullfile(spm_location, 'nihpd_asym_04.5-18.5_nifti') ;    %   Asymmetry
% child_adole_tpm = fullfile(spm_location, 'nihpd_sym_04.5-18.5_nifti') ;     %   Symmetry
tpm_basic_name = 'nihpd_asym_04.5-18.5_' ;
% tpm_basic_name = 'nihpd_sym_04.5-18.5_' ;

%   Calculate cut time
cut_time = ceil(10 / TR_value) ;
% cut_time = 0 ;

%   Make list of subject folders
cd(now_grp_path) ;
subj_list = dir(['*' common_subj_name '*']) ;

%%  01. Unzip from .nii.gz to .nii

%   Run this step
run(fullfile(script_basic_path, 'Unzip_gz_files.m'))

%%  02_1. Reorient the T1 images (manual)

cd(now_grp_path) ;
spm fmri

%%  02_2. End spm

spm quit

%%  03. Cut the original functional file by a number of time points.
% TR=2 then first 5 should do the trick. TR=2.5 then cut the first 4 time points.
% TR=3 then cut the first 4 time points.

%   Set common input file name since the input name is different when doing this step.
func_input_prefix = '' ;
%   Set common output file name.
output_prefix = 'c_' ;

%   Run this step
run(fullfile(script_basic_path, 'Cut_times.m'))

%%  04. Realignment

%   Set common input file name since the input name is different when doing this step.
func_input_prefix = 'c_' ; % input_prefix
%   Set common output file name.
output_prefix = 'r' ;

%   Run this step
run(fullfile(script_basic_path, 'Realignment.m'))

%%  05. Head Motion Assessment using Framewise Displacement.

%   Set common input file name since the input name is different when doing this step.
input_prefix = 'rp_c_' ;

%   Run this step
run(fullfile(script_basic_path, 'Framewise_Displacement.m'))

%%  06. Reload subj_list made by the framewize displacement !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;
%   Load new subjects and sessions list after the framewize displacement.
total_lists = load(fullfile(now_grp_path, 'adjusted_subj_lists.mat'), 'total_lists') ;
total_lists = total_lists.total_lists ;
%   Save the subjects list separately.
subj_list = cell2struct(total_lists(:, 1), {'name'}, 2) ;
%
cprintf('red', '<<<<<<<<<< Finished Reload the adjusted subject lists >>>>>>>>>>\n') ;

%%  07_1. Skull strip

%   Set common input file name since the input name is different when doing this step.
anat_input_prefix = '' ;
%   Set common output file name.
output_prefix = 'ss_' ;

%   Run this step
run(fullfile(script_basic_path, 'Skull_Strip.m'))

%%  07_1_2. Skull strip of mean func

% %   Set common input file name since the input name is different when doing this step.
% input_prefix = 'meanc_' ;
% %   Set common output file name.
% output_prefix = 'ss_' ;
% 
% %   Run this step
% run([script_basic_path 'U_Skull_Strip_func.m'])

%%  07_2. Check skull strip

cd(now_grp_path) ;
spm fmri

%%  07_3. End spm

spm quit

%%  08_1. Coregistration

%   Set common input file name since the input name is different when doing this step.
func_input_prefix = 'rc_' ;             %   Functional data
source_input_prefix = 'meanc_' ;        %   Source data
% source_input_prefix = 'ss_mean' ;
anat_input_prefix = 'ss_' ;           %   Anatomical data

%   Run this step
run(fullfile(script_basic_path, 'Coregistration.m'))

%%  08_2. Check coregistration

cd(now_grp_path) ;
spm fmri

%%  08_2. End spm

spm quit

%%  09_1. Segmentation

%   Set common input file name since the input name is different when doing this step.
anat_input_prefix = '' ;     % Ex. 'ss_'

%   Depending an age group, we would need different canonical image for the segmentation.
if strcmp(age_grp, 'Children') | strcmp(age_grp, 'Adolescents')   %   Children or adolescents
    cprintf('red', 'Children or adolescents segmentation (%s).\n', age_grp)
%     run(fullfile(script_basic_path, 'Segmentation_children.m'))
    run(fullfile(script_basic_path, 'Segmentation.m'))
elseif strcmp(age_grp, 'Adults')                                   %   Adults
    cprintf('red', 'Adults segmentation (%s).\n', age_grp)
    run(fullfile(script_basic_path, 'Segmentation.m'))
end

%%  09_2. Check segmentation

cd(now_grp_path) ;
spm fmri

%%  09_3. End spm

spm quit

%%  09_4. Dartel

%   Set mask type wanted
mask_types = {'GM', 'WM', 'CSF'} ;
%   Set common input file name since the input name is different when doing this step.
anat_input_prefix = '' ;

%   Dartel method will be used when children and adolescents data.
if strcmp(age_grp, 'Children') | strcmp(age_grp, 'Adolescents')
    run(fullfile(script_basic_path, 'Dartel.m'))
end 

%%  09_5. Check dartel

cd(now_grp_path) ;
spm fmri

%%  09_6. End spm

spm quit

% %%  09_7. Re-segmentation with dartel results
% 
% %   Set common input file name since the input name is different when doing this step.
% input_prefix = '' ;     % Ex. 'ss_'
% 
% %   Depending an age group, we would need different canonical image for the segmentation.
% if strcmp(age_grp, 'Children') | strcmp(age_grp, 'Adolescents')     %   Children or adolescents
%     cprintf('red', 'Children or adolescents segmentation with dartel results (%s).\n', age_grp)
%     run(fullfile(script_basic_path, 'Segmentation_Dartel.m'))
% elseif strcmp(age_grp, 'Adults')                                    %   Adults
%     cprintf('red', 'Adults segmentation with dartel results (%s).\n', age_grp)
%     run(fullfile(script_basic_path, 'Segmentation_Dartel.m'))
% end
% 
% %%  09_8. Check re-segmentation
% 
% cd(now_grp_path) ;
% spm fmri
% 
% %%  09_9. End spm
% 
% spm quit

%%  10_1. Normalization

%   Set common input file name since the input name is different when doing this step.
anat_input_prefix = 'y_' ;  %   anatomical data
func_input_prefix = 'rc_' ;   %   functional data
%   Set common output file name.
out_prefix = 'w' ;
%   Set normalization voxel size.
voxel_size = [voxel_value voxel_value voxel_value] ;

%   Run this step
run(fullfile(script_basic_path, 'Normalization.m'))

%%  10_2. Check normalization

cd(now_grp_path) ;
spm fmri

%%  10_3. End spm

spm quit

%%  11_1. Generate masks via SPM

%   Set common input file name since the input name is different when doing this step.
func_input_prefix = 'wrc_' ;
%   Set mask type wanted
seg_types = {'wc1', 'wc2', 'wc3'} ;
%   
threshold_value = {0.5, 0.4, 0.3} ;

%   Run this step
run(fullfile(script_basic_path, 'Mask_for_SPM.m'))

% %%  11_2. Generate masks via AFNI 
% 
% %   Set common input file name since the input name is different when doing this step.
% anat_input_prefix = '' ;
% func_input_prefix = 'wrc_' ;
% 
% %%% For GM mask
% mask_types = {'wc1'} ;
% %   Set common output file name.
% out_prefix = 'GM' ;
% 
% %   Run this step
% run(fullfile(script_basic_path, 'Mask_via_AFNI.m')) ;
% 
% %%% For WM mask
% mask_types = {'wc2'} ;
% %   Set common output file name.
% out_prefix = 'WM' ;
% 
% %   Run this step
% run(fullfile(script_basic_path, 'Mask_via_AFNI.m')) ;
% 
% %%% For CSF mask
% mask_types = {'wc3'} ;
% %   Set common output file name.
% out_prefix = 'CSF' ;
% 
% %   Run this step
% run(fullfile(script_basic_path, 'Mask_via_AFNI.m')) ;

%%  12. Extract first few PCA components from masks

%   Set common input file name since the input name is different when doing this step.
func_input_prefix = 'wrc_' ;
mask_types = {'WM', 'CSF'} ;
mask_opt = 'spm' ;
num_pca = 5 ;

%   Run this step
run(fullfile(script_basic_path, 'Extraction_PCA.m'))

%%  13. Temporal regression

%   Set common input file name since the input name is different when doing this step.
func_input_prefix = 'wrc_' ;
rp_prefix = 'rp_c_' ;
%   Set common output file name.
out_prefix = 'reg_' ;

%   Run this step
run(fullfile(script_basic_path, 'Temporal_Regression.m'))

%%  14_1. Smoothing

%   Set common input file name since the input name is different when doing this step.
func_input_prefix = 'reg_wrc_' ;
%   Set common output file name.
out_prefix = 's' ;

%   Run this step
run(fullfile(script_basic_path, 'Smoothing.m')) ;

%%  14_2. Check smoothing

cd(now_grp_path) ;
spm fmri

%%  14_2. End spm

spm quit

%%  15_1. Make masks for filtering

%   Set common input file name since the input name is different when doing this step.
anat_input_prefix = '' ;
func_input_prefix = 'sreg_wrc_' ;
mask_types = {'wc1', 'wc2', 'wc3'} ;
%   Set common output file name.
out_prefix = 'filter' ;

%   Run this step
run(fullfile(script_basic_path, 'Mask_via_AFNI.m')) ;

%%  15_2. Filtering

%   Set common input file name since the input name is different when doing this step.
func_input_prefix = 'sreg_wrc_' ;
mask_name = '_filter_afni_mask' ;
% original_frequency = '3.00' ;
%   Set common output file name.
output_prefix = 'f' ;

%   Run this step
run(fullfile(script_basic_path, 'Filtering.m')) ;


%%  15_3. Check filtering

cd(now_grp_path) ;
spm fmri

%%  15_4. End spm

spm quit
