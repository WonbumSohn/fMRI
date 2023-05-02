%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-2nd-2023
%   To make masks via AFNI.

%%  Make masks
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started making masks of %s via AFNI >>>>>>>>>>\n', out_prefix) ;

%   Specify the name of the functional data to use
func_data_full_name = [func_input_prefix func_data_name] ;
%   Specify the name of the anatomical data to use
anat_data_full_name = [anat_input_prefix anat_data_name] ;
%
out_anat_mask_name = [anat_data_full_name '_' out_prefix '_afni_mask.nii'] ;
%
out_func_mask_name = [func_data_full_name '_' out_prefix '_afni_mask.nii'] ;
%
mask_num = length(mask_types) ;

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
        %   Set full name with the location of the functional data
        func_data = fullfile(func_folder_path, [func_data_full_name '.nii']) ;
        %   Set anatomical data folder locations.
        anat_folder_path = fullfile(now_subj_path, sess_lists(sess_iter).name, anat_folder_name) ; 
        %   
        out_anat_mask = fullfile(anat_folder_path, out_anat_mask_name) ;
        %   
        out_func_mask = fullfile(func_folder_path, out_func_mask_name) ;
    
        %   When existing previous mask data, delete the files for initialization first.
        if isfile(out_anat_mask)
            cprintf('red', 'There is previous anatomical mask file, so it is removed.\n') ;
            delete(out_anat_mask) ;
        end
        if isfile(out_func_mask)
            cprintf('red', 'There is previous functional mask file, so it is removed.\n') ;
            delete(out_func_mask) ;
        end
    
        %   
        switch mask_num
            case 1
                mask_1 = fullfile(anat_folder_path, [mask_types{1} anat_data_full_name '.nii']) ;
                command_anat = ['3dcalc' ' -a ' mask_1 ' -expr ' "'step(a-0.1)'" ' -prefix ' out_anat_mask] ;   %   0.1~0.2(10~20%)
                clear mask_1
            case 2
                mask_1 = fullfile(anat_folder_path, [mask_types{1} anat_data_full_name '.nii']) ;
                mask_2 = fullfile(anat_folder_path, [mask_types{2} anat_data_full_name '.nii']) ;
                command_anat = ['3dcalc' ' -a ' mask_1 ' -b ' mask_2 ' -expr ' "'step(a+b-0.1)'" ' -prefix ' out_anat_mask] ;
                clear mask_1 mask_2
            case 3
                mask_1 = fullfile(anat_folder_path, [mask_types{1} anat_data_full_name '.nii']) ;
                mask_2 = fullfile(anat_folder_path, [mask_types{2} anat_data_full_name '.nii']) ;
                mask_3 = fullfile(anat_folder_path, [mask_types{3} anat_data_full_name '.nii']) ;
                command_anat = ['3dcalc' ' -a ' mask_1 ' -b ' mask_2 ' -c ' mask_3 ' -expr ' "'step(a+b+c-0.1)'" ' -prefix ' out_anat_mask] ;
                clear mask_1 mask_2 mask_3
        end
    
        command_anat = join(command_anat) ;
        command_func = ['3dresample' ' -master ' func_data ' -input ' out_anat_mask ' -prefix ' out_func_mask] ;
    
        system(command_anat) ;
        system(command_func) ;
    
    
    
        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;              %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Making masks of %s via AFNI  (%s (%d/%d) -   %s  (%d/%d)).\n'] ;     %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, func_folder_path, out_prefix, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;                    %   Enter values in txt file
        fclose(file_ID) ;
    
        %   Remove the variables repeating or not necessary
        clear func_folder_path func_data anat_folder_path out_anat_mask out_func_mask command_anat command_func
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists 
end

%
cprintf('red', '<<<<<<<<<< Finished making masks of %s via AFNI >>>>>>>>>>\n', out_prefix) ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;                  %   Set up txt file location and name
content_format = 'The duration time of making masks of %s via AFNI is %d seconds.\n' ;      %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, out_prefix, tEnd) ;                                        %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of making masks of %s via AFNI is %d seconds.\n\n\n', out_prefix, tEnd) ;

%   Remove the variables repeating or not necessary
clear func_data_full_name anat_data_full_name out_anat_mask_name out_func_mask_name mask_num
clear tStart tEnd file_ID content_format
