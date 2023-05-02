%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. April-30th-2023
%   To unzip nii.gz files.

%%  Unzip nii.gz files
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Start to unzip .gz files. >>>>>>>>>>\n')

%   Loop all subjects in this group
for subji=1:length(subj_list)

    %   Show a subject being done.
    cprintf('black', '<<<<< %s (%d/%d) >>>>>\n', subj_list(subji).name, subji, length(subj_list)) ;

    %   Set and move now subject location
    now_subj_path = fullfile(now_grp_path, subj_list(subji).name) ;
    cd(now_subj_path) ;

    %   Check the list of sessions in each subject folder.
    sess_lists = dir('session_*') ;

    %   Loop all sessions in this subject
    for sess_iter = 1:length(sess_lists)

        %   Show a session being done.
        cprintf('black', '<< %s (%d/%d) >>\n', sess_lists(sess_iter).name, sess_iter, length(sess_lists))

        %   Set functional and anatomical data folder locations.
        func_folder_path = fullfile(now_subj_path, sess_lists(sess_iter).name, func_folder_name) ;    %   Functional
        anat_folder_path = fullfile(now_subj_path, sess_lists(sess_iter).name, anat_folder_name) ;    %   Anatomical
        
        %%% Functional data
        %   Move to the functional location
        cd(func_folder_path) ;
    
        %   Set variables to unzip from .gz to .nii
        file_names = dir(['*' func_data_name '.nii*']) ;
    
        %   To extract the names of existing nii.gz files
        file_name = file_names.name ;               %   Ex: file name.nii.gz
        separate_name = split(file_name, '.') ;     %   Ex: 3×1 cell array: {'file name'} {'nii'        } {'gz'         }
        data_name = char(separate_name(1)) ;        %   Ex: file name
        data_type = char(separate_name(2)) ;        %   Ex: nii
    
        %   If there is unzipped .nii file, skip this unzipping step
        if ~isfile([data_name '.' data_type])       %   If there is not nii file
            if isfile([file_name])                  %   If there is gz file
                gunzip([file_name])
                cprintf('red', 'Complete unziping of functional data in %s.\n', file_name)
            elseif ~isfile([file_name])             %   If there is not gz file also
                cprintf('red', 'You need a .nii or a .gz file of functional data for further processing.\n')
            end
        elseif isfile([data_name '.' data_type])    %   If there is nii file already
            cprintf('red', 'You have already a .nii file of functional data, so you do not need to unzip a .gz file.\n')
        end
    
        %   Remove the variables repeating or not necessary
        clear file_names file_name separate_name data_name data_type

        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Unzipped (%s (%d/%d) -   %s  (%d/%d)).\n'] ;                 %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, func_folder_path, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;            %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear file_ID content_format



        %%% Anatomical data
        %   Move to the anatomical location
        cd(anat_folder_path) ;

        %   Set variables to unzip from .gz to .nii
        file_names = dir(['*' anat_data_name '.nii*']) ;
    
        %   To extract the names of existing nii.gz files
        file_name = file_names.name ;               %   Ex: file name.nii.gz
        separate_name = split(file_name, '.') ;     %   Ex: 3×1 cell array: {'file name'} {'nii'        } {'gz'         }
        data_name = char(separate_name(1)) ;        %   Ex: file name
        data_type = char(separate_name(2)) ;        %   Ex: nii
    
    
        %   If there is unzipped .nii file, skip this unzipping step
        if ~isfile([data_name '.' data_type])       %   If there is not nii file
            if isfile([file_name])                  %   If there is gz file
                gunzip([file_name])
                cprintf('red', 'Complete unziping of anatomical data in %s.\n', file_name)
            elseif ~isfile([file_name])             %   If there is not gz file also
                cprintf('red', 'You need a .nii or a .gz file of anatomical data for further processing.\n')
            end
        elseif isfile([data_name '.' data_type])    %   If there is nii file already
            cprintf('red', 'You have already a .nii file of anatomical data, so you do not need to unzip a .gz file.\n')
        end
    

        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Unzipped (%s (%d/%d) -   %s  (%d/%d)).\n'] ;                 %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, anat_folder_path, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;            %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear func_folder_path anat_folder_path file_names file_name separate_name data_name data_type
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists
end

%
cprintf('red', '<<<<<<<<<< Finished unziping .gz files >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
content_format = 'The duration time of unzipping is %d seconds.\n' ;            %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                        %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of unzipping is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart tEnd file_ID content_format
