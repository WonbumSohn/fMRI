%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-2nd-2023
%   To make masks wanted.

%%  Make masks
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started making GM mask >>>>>>>>>>\n') ;

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
        func_data = fullfile(func_folder_path, func_data_full_name) ;

        %   
        for seg_iter = 1:length(seg_types)

            %   Load now mask type name
            seg_prefix = seg_types{seg_iter} ;

            %   Select a segmentation result file based on the mask type
            switch seg_prefix
                case 'wc1'
                    now_mask_type = 'GM' ;
                case 'wc2'
                    now_mask_type = 'WM' ;
                case 'wc3'
                    now_mask_type = 'CSF' ;
            end

            %   Show a session being done.
            cprintf('black', '<< %s (%d/%d) >>\n', now_mask_type, seg_iter, length(seg_types))
        
            %   Set anatomical data folder locations.
            anat_folder_path = fullfile(now_subj_path, sess_lists(sess_iter).name, anat_folder_name) ;
            %   Specify the name of the anatomical data to use
            anat_data_full_name = [seg_prefix anat_data_name] ;
            %   Set full name with the location of the anatomical data
            anat_data = fullfile(anat_folder_path, anat_data_full_name) ;

            %   When existing previous now mask data, delete the files for initialization first.
            if isfile([func_data '_' now_mask_type '_spm_mask.nii'])
                cprintf('red', 'There is previous %s spm mask file, so it is removed.\n', now_mask_type) ;
                delete ([func_data '_' now_mask_type '_spm_mask.nii']) ;
            end
    
            matlabbatch{1}.spm.util.imcalc.input = {
                                                    [func_data '.nii,1']
                                                    [anat_data '.nii']
                                                    };
            matlabbatch{1}.spm.util.imcalc.output = [func_data_full_name '_' now_mask_type '_spm_mask.nii'] ;
            matlabbatch{1}.spm.util.imcalc.outdir = {func_folder_path};
            matlabbatch{1}.spm.util.imcalc.expression = ['i2>' num2str(threshold_value)] ;
            matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{1}.spm.util.imcalc.options.mask = 0;
            matlabbatch{1}.spm.util.imcalc.options.interp = 1;
            matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
    
            %   Run
            spm_jobman('run', matlabbatch);



            %%% Save progress so far in case that error occur.
            file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
            content_format = ['Path: %s.\n' ...
                              'Making %s mask   (%s (%d/%d) -   %s  (%d/%d)).\n'] ;         %   Set up a form to fill in the txt file
            fprintf(file_ID, content_format, func_folder_path, now_mask_type, subj_list(subji).name, subji, length(subj_list), ...
                    sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;            %   Enter values in txt file
            fclose(file_ID) ;

            %   Remove the variables repeating or not necessary
            clear matlabbatch now_mask_type seg_prefix anat_folder_path anat_data_full_name anat_data
            clear file_ID content_format 
        end

        %   Remove the variables repeating or not necessary
        clear func_folder_path func_data_full_name func_data     
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists
end

%
cprintf('red', '<<<<<<<<<< Finished making GM mask >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
content_format = 'The duration time of making masks is %d seconds.\n' ;         %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                        %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of making masks is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart tEnd file_ID content_format
