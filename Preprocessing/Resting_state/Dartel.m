%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. April-30th-2023
%   For dartel of anatomical data.

%%  Do Dartel
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started Dartel >>>>>>>>>>\n') ;

%   Loop all masks selected
for mask_iter = 1:length(mask_types)

    %   Load now mask type name
    now_mask_type = mask_types{mask_iter} ;
    %   Show a session being done.
    cprintf('black', '<< %s (%d/%d) >>\n', now_mask_type, mask_iter, length(mask_types))

    %   Select a segmentation result file based on the mask type
    switch now_mask_type
        case 'GM'
            seg_prefix = 'rc1' ;
        case 'WM'
            seg_prefix = 'rc2' ;
        case 'CSF'
            seg_prefix = 'rc3' ;
    end

    %   Set up variables to store segmentation results cumulatively in cell rows
    cell_iter = 0 ;

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
            anat_data_full_name = [anat_input_prefix anat_data_name] ;
    
            %   Increase cell row number
            cell_iter = cell_iter + 1 ;
            %   Save now specific segmentation result
            now_dartel{cell_iter,1} = (fullfile(anat_folder_path, [seg_prefix anat_data_full_name '.nii']));
    
            %   When existing previous dartel data, delete the files for initialization first.
            %   The result was saved in the first session of the first subject so checking previous files is added here.
            if isfile(fullfile(anat_folder_path, ['u_' seg_prefix anat_data_full_name '_' now_mask_type '.nii']))
                cprintf('red', 'There are previous dartel files, so they are removed.\n') ;
                delete (fullfile(anat_folder_path, ['u_' seg_prefix anat_data_full_name '_' now_mask_type '.nii'])) ;
            end
            for ts_iter = 0:6
                if isfile(fullfile(anat_folder_path, [now_mask_type '_' int2str(ts_iter) '.nii']))
                delete (fullfile(anat_folder_path, [now_mask_type '_' int2str(ts_iter) '.nii'])) ;
                end
            end
    
            %   Remove the variables repeating or not necessary
            clear anat_folder_path anat_data_full_name
        end
    
        %   Remove the variables repeating or not necessary
        clear now_subj_path sess_lists
    end
    
    %   Move to now group locations (Ex. ASD or TC)
    cd(now_grp_path) ;
    
    matlabbatch{1}.spm.tools.dartel.warp.images = {now_dartel}' ;
    matlabbatch{1}.spm.tools.dartel.warp.settings.template = now_mask_type ;
    matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;
    
    %   Run
    spm_jobman('run',matlabbatch)
    
    
    %%% Save progress so far in case that error occur.
    file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
    content_format = 'Dartel of %s finished.\n' ;                                   %   Set up a form to fill in the txt file
    fprintf(file_ID, content_format, now_mask_type) ;                               %   Enter values in txt file
    fclose(file_ID) ;
    
    %
    cprintf('blue', 'cell iter is %d.\n', cell_iter)
    %   Remove the variables repeating or not necessary
    clear matlabbatch now_mask_type seg_prefix now_dartel cell_iter
    clear file_ID content_format

end

%
cprintf('red', '<<<<<<<<<< Finished Dartel >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
content_format = 'The duration time of dartel is %d seconds.\n' ;               %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                        %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of dartel is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart tEnd file_ID content_format
