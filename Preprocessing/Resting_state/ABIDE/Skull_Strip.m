%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-2nd-2023
%   To move variables that do not change regardless of the for loop outside the for loop
%   Ver. April-30th-2023
%   To remove skull in anatomical T1 images in Ubuntu.

%%  Do Skull Strip
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started Skull Strip >>>>>>>>>>\n') ;

%   Specify the name of the anatomical data to use
anat_data_full_name = [anat_input_prefix anat_data_name] ;
%   Specify the name of the output data
out_data_name = [output_prefix anat_data_full_name] ;

%   Loop all subjects in this group
for subji = 1:length(subj_list)

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
        %   Set full name with the location of the anatomical data
        anat_data = fullfile(anat_folder_path, anat_data_full_name) ;
        %   Move to now anatomical folder location
        cd(anat_folder_path) ;

        %   When existing previous skull strip data, delete the files for initialization first.
        if isfile(fullfile(anat_folder_path, [out_data_name '.nii']))
            cprintf('red', 'There is previous skull strip result, so it is removed.\n') ;
            delete (fullfile(anat_folder_path, [out_data_name '.nii'])) ;
        end
        if isfile(fullfile(anat_folder_path, ['cp_' anat_data_full_name '.nii']))
            cprintf('red', 'There is previous copyed anatomical image, so it is removed.\n') ;
            delete (fullfile(anat_folder_path, ['cp_' anat_data_full_name '.nii'])) ;
        end
        if isfile([anat_data '_mask.nii'])
            cprintf('red', 'There is previous mask data, so it is removed.\n') ;
            delete ([anat_data '_mask.nii']) ;
        end

        %   Copy the anatomical data to remove skull
        command_cp = ['cp' ' -r ' anat_data_full_name '.nii'  ' ' 'cp_' anat_data_full_name '.nii'] ;
        system(command_cp) ;
        %   Make the mask data to remove skull
        command_mm = ['3dSkullStrip -input ' 'cp_' anat_data_full_name '.nii' ' -prefix ' anat_data_full_name '_mask.nii' ' -mask_vol'] ;
        system(command_mm) ;
        %   Remove the copy data
        command_rm = ['rm -f cp_' anat_data_full_name '.nii'] ;
        system(command_rm) ;
    
        matlabbatch{1}.spm.util.imcalc.input = {
                                            [anat_data '.nii']
                                            [anat_data '_mask.nii']
                                            };
        matlabbatch{1}.spm.util.imcalc.output = [out_data_name '.nii'] ;
        matlabbatch{1}.spm.util.imcalc.outdir = {anat_folder_path};
        matlabbatch{1}.spm.util.imcalc.expression = 'i1.*(i2>5)';
        matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 1;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
    
        %   Run
        spm_jobman('run', matlabbatch);
        


        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;  %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Skull strip  (%s (%d/%d) -   %s  (%d/%d)).\n'] ;         %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, anat_folder_path, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;        %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear matlabbatch anat_folder_path command_cp command_mm
        clear clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists
end

%
cprintf('red', '<<<<<<<<<< Finished Skull Strip >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
content_format = 'The duration time of skull strip is %d seconds.\n' ;          %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                        %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of skull strip is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart anat_data_full_name out_data_name tEnd file_ID content_format
