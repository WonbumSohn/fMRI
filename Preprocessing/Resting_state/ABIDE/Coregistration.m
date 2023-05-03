%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-2nd-2023
%   To move variables that do not change regardless of the for loop outside the for loop
%   Ver. April-30th-2023
%   For coregistration between functional data and anatomical data.

%%  Do Coregistration
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started Coregistration >>>>>>>>>>\n') ;

%   Specify the name of the functional data to use
func_data_full_name = [func_input_prefix func_data_name] ;
%   Specify the name of the anatomical data to use
anat_data_full_name = [anat_input_prefix anat_data_name] ;
%   Specify the name of the anatomical data to use
source_data_full_name = [source_input_prefix func_data_name] ;

%   Loop all subjects in this group
for subji=1:length(subj_list)
    
    %   Show a subject being done.    
    cprintf('black', '<<<<< %s (%d/%d) >>>>>\n', subj_list(subji).name, subji, length(subj_list)) ;

    %   Set and move now subject location
    now_subj_path = fullfile(now_grp_path, subj_list(subji).name) ;
    cd(now_subj_path) ;

    %   Set the list of sessions in each subject folder.
    sess_lists = total_lists{subji, 2} ;

    %   Loop all sessions in this subject
    for sess_iter = 1:length(sess_lists)

        %   Show a session being done.
        cprintf('black', '<< %s (%d/%d) >>\n', sess_lists(sess_iter).name, sess_iter, length(sess_lists))

        %   Set functional data folder locations.
        func_folder_path = fullfile(now_subj_path, sess_lists(sess_iter).name, func_folder_name) ;
        %   Set anatomical data folder locations.
        anat_folder_path = fullfile(now_subj_path, sess_lists(sess_iter).name, anat_folder_name) ;
        %   Set full name with the location of the anatomical data as reference data
        ref_data = fullfile(anat_folder_path, [anat_data_full_name '.nii']) ;
        %   Set full name with the location of the mean functional data as source data
        source_data = fullfile(func_folder_path, [source_data_full_name '.nii']) ;
        %   Set full name with the location of the functional data
        func_data = fullfile(func_folder_path, [func_data_full_name '.nii,']) ; 
    
        %   Calculate the total TR time of the functional data.
        v_pair_REST = spm_vol(func_data) ;
        [total_time, ~] = size(v_pair_REST) ;

        %   Store functional nii file names
        for imagei = 1:total_time
            other_list{imagei,1} = [func_data, num2str(imagei)] ;
        end

        matlabbatch{1}.spm.spatial.coreg.estimate.ref = {ref_data} ;
        matlabbatch{1}.spm.spatial.coreg.estimate.source = {source_data} ;
        matlabbatch{1}.spm.spatial.coreg.estimate.other = other_list ;
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [5 5];

        %   Run
        spm_jobman('run', matlabbatch);



        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Coregistration   (%s (%d/%d) -   %s  (%d/%d)).\n'] ;         %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, now_subj_path, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;            %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear matlabbatch func_folder_path anat_folder_path  
        clear ref_data source_data func_data v_pair_REST total_time other_list
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists
end

%
cprintf('red', '<<<<<<<<<< Finished Coregistration >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
content_format = 'The duration time of coregistration is %d seconds.\n' ;       %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                        %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of coregistration is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart func_data_full_name anat_data_full_name source_data_full_name tEnd file_ID content_format
