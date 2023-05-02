%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. April-30th-2023
%   For normalization.

%%  Do Normalization
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started Normalization >>>>>>>>>>\n') ;

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
        %   Specify the name of the functional data to use
        func_data_full_name = [func_input_prefix func_data_name] ;
        %   Set full name with the location of the functional data
        func_data = fullfile(func_folder_path, [func_data_full_name '.nii,']) ; 
        %   Set anatomical data folder locations.
        anat_folder_path = fullfile(now_subj_path, sess_lists(sess_iter).name, anat_folder_name) ;
        %   Specify the name of the anatomical data to use
        anat_data_full_name = [anat_input_prefix anat_data_name] ;
        %   Set full name with the location of the anatomical data
        anat_data = fullfile(anat_folder_path, [anat_data_full_name '.nii']) ; 

        %   When existing previous normalization data, delete the files for initialization first.
        if isfile(fullfile(func_folder_path, [out_prefix func_data_full_name '.nii']))
            cprintf('red', 'There is a previous normalization file, so it is removed.\n') ;
            delete (fullfile(func_folder_path, [out_prefix func_data_full_name '.nii'])) ;
        end

        %   Calculate the total TR time of the functional data.
        v_pair_rest = spm_vol(func_data) ;
        [total_time, ~] = size(v_pair_rest) ;

        %   Store functional nii file names
        for imagei = 1:total_time
            func_list{imagei,1} = [func_data, num2str(imagei)] ;
        end

        matlabbatch{1}.spm.spatial.normalise.write.subj.def = {anat_data} ;
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = func_list ;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                                  78 76 85] ;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = voxel_size ;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4 ;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = out_prefix ;

        %   Run
        spm_jobman('run', matlabbatch);



        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Normalization    (%s (%d/%d) -   %s  (%d/%d)).\n'] ;         %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, func_folder_path, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;            %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear matlabbatch func_folder_path func_data_full_name func_data anat_folder_path anat_data_full_name anat_data
        clear v_pair_rest total_time imagei func_list
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists
end

%
cprintf('red', '<<<<<<<<<< Finished Normalization >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
content_format = 'The duration time of normalization is %d seconds.\n' ;        %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                        %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of normalization is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart tEnd file_ID content_format
