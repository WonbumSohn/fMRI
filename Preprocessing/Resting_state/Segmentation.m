%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. April-30th-2023
%   For segmentation of anatomical data.

%%  Do Segmentation
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started Segmentation >>>>>>>>>>\n') ;

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

        %   Set anatomical data folder locations.
        anat_folder_path = fullfile(now_subj_path, sess_lists(sess_iter).name, anat_folder_name) ;
        %   Specify the name of the anatomical data to use
        anat_data_full_name = [input_prefix anat_data_name] ;
        %   Set full name with the location of the anatomical data
        anat_data = fullfile(anat_folder_path, [anat_data_full_name '.nii']) ;
    
        %   When existing previous segmentation data, delete the files for initialization first.
        if isfile(fullfile(anat_folder_path, [anat_data_full_name '_seg8.mat']))
            cprintf('red', 'There are previous segmentation files, so they are removed.\n') ;   %   The phrase is only inserted here because too many to delete.
            delete (fullfile(anat_folder_path, [anat_data_full_name '_seg8.mat'])) ;
        end
        if isfile(fullfile(anat_folder_path, ['BiasField_' anat_data_full_name '.nii']))
            delete (fullfile(anat_folder_path, ['BiasField_' anat_data_full_name '.nii'])) ;
        end
        if isfile(fullfile(anat_folder_path, ['y_' anat_data_full_name '.nii']))
            delete (fullfile(anat_folder_path, ['y_' anat_data_full_name '.nii'])) ;
        end
        if isfile(fullfile(anat_folder_path, ['iy_' anat_data_full_name '.nii']))
            delete (fullfile(anat_folder_path, ['iy_' anat_data_full_name '.nii'])) ;
        end
        if isfile(fullfile(anat_folder_path, ['m' anat_data_full_name '.nii']))
            delete (fullfile(anat_folder_path, ['m' anat_data_full_name '.nii'])) ;
        end
        for ts_iter = 1:6
            if isfile(fullfile(anat_folder_path, ['c' int2str(ts_iter) anat_data_full_name '.nii']))
            delete (fullfile(anat_folder_path, ['c' int2str(ts_iter) anat_data_full_name '.nii'])) ;
            end
            if isfile(fullfile(anat_folder_path, ['rc' int2str(ts_iter) anat_data_full_name '.nii']))
            delete (fullfile(anat_folder_path, ['rc' int2str(ts_iter) anat_data_full_name '.nii'])) ;
            end
            if isfile(fullfile(anat_folder_path, ['mwc' int2str(ts_iter) anat_data_full_name '.nii']))
            delete (fullfile(anat_folder_path, ['mwc' int2str(ts_iter) anat_data_full_name '.nii'])) ;
            end
            if isfile(fullfile(anat_folder_path, ['wc' int2str(ts_iter) anat_data_full_name '.nii']))
            delete (fullfile(anat_folder_path, ['wc' int2str(ts_iter) anat_data_full_name '.nii'])) ;
            end
        end
    
        matlabbatch{1}.spm.spatial.preproc.channel.vols = {anat_data};
        matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
        matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
        matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[adults_tpm '1']};
        matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
        matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[adults_tpm '2']};
        matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
        matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[adults_tpm '3']};
        matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[adults_tpm '4']};
        matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[adults_tpm '5']};
        matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[adults_tpm '6']};
        matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [1 1];
        matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
        matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
        matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
        matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
        matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
        matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];
        matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
        matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                      NaN NaN NaN];

        %   Run
        spm_jobman('run', matlabbatch);
        


        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Segmentation (%s (%d/%d) -   %s  (%d/%d)).\n'] ;             %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, anat_folder_path, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;            %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear matlabbatch anat_folder_path anat_data_full_name anat_data
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists
end

%
cprintf('red', '<<<<<<<<<< Finished Segmentation >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
content_format = 'The duration time of segmentation is %d seconds.\n' ;         %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                        %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of segmentation is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart tEnd file_ID content_format
