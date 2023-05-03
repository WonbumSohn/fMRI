%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-2nd-2023
%   To move variables that do not change regardless of the for loop outside the for loop
%   Ver. April-30th-2023
%   To realign functional data.

%%  Do realigment
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started Realignment >>>>>>>>>>\n') ;

%   Specify the name of the functional data to use
func_data_full_name = [func_input_prefix func_data_name] ;

%   Loop all subjects in this group
for subji=1:length(subj_list)
    
    %   Show a subject being done.    
    cprintf('black', '<<<<< %s (%d/%d) >>>>>\n', subj_list(subji).name, subji, length(subj_list)) ;
 
    %   Set and move now subject location
    now_subj_path = fullfile(now_grp_path, subj_list(subji).name) ;
    cd(now_subj_path) ;

    %   Check the list of sessions in each subject folder.
    sess_lists = dir([common_sess_name '*']) ;

    %   Loop all sessions in this subject
    for sess_iter = 1:length(sess_lists)

        %   Show a session being done.
        cprintf('black', '<< %s (%d/%d) >>\n', sess_lists(sess_iter).name, sess_iter, length(sess_lists))

        %   Set functional data folder locations.
        func_folder_path = fullfile(now_subj_path, sess_lists(sess_iter).name, func_folder_name) ;
        %   Set full name with the location of the functional data
        func_data = fullfile(func_folder_path, [func_data_full_name '.nii,']) ;
        
        %   When existing previous realignment data, delete the files for initialization first.
        if isfile(fullfile(func_folder_path, [func_data_full_name '.mat']))
            cprintf('red', 'There is previous mat file, so it is removed.\n') ;
            delete (fullfile(func_folder_path, [func_data_full_name '.mat'])) ;
        end
        if isfile(fullfile(func_folder_path, ['mean' func_data_full_name '.nii']))
            cprintf('red', 'There is previous mean file, so it is removed.\n') ;
            delete (fullfile(func_folder_path, ['mean' func_data_full_name '.nii'])) ;
        end
        if isfile(fullfile(func_folder_path, ['r' func_data_full_name '.nii']))
            cprintf('red', 'There is previous r file, so it is removed.\n') ;
            delete (fullfile(func_folder_path, ['r' func_data_full_name '.nii'])) ;
        end
        if isfile(fullfile(func_folder_path, ['rp_' func_data_full_name '.txt']))
            cprintf('red', 'There is previous rp file, so it is removed.\n') ;
            delete (fullfile(func_folder_path, ['rp_' func_data_full_name '.txt'])) ;
        end
        
        %   Calculate the total TR time of the functional data.
        v_pair_rest = spm_vol(func_data) ;
        [total_time, ~] = size(v_pair_rest) ;
        
        %   Store functional nii file names
        for imagei = 1:total_time
            realign_list{imagei,1} = [func_data, num2str(imagei)] ;
        end
    
        matlabbatch{1}.spm.spatial.realign.estwrite.data = {realign_list} ;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = output_prefix ;
        
        %   Run
        spm_jobman('run', matlabbatch);
        


        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Realignment  (%s (%d/%d) -   %s  (%d/%d)).\n'] ;             %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, func_folder_path, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;            %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear matlabbatch func_folder_path func_data realign_list v_pair_rest total_time
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists
end

%
cprintf('red', '<<<<<<<<<< Finished Realignment >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
content_format = 'The duration time of realignment is %d seconds.\n' ;          %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                        %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of realignment is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart func_data_full_name tEnd file_ID content_format
