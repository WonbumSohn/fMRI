%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-1rst-2023
%   To cut the first few times for magentic stabilization.

%%  Cut the first few times
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started Cutting Times >>>>>>>>>>\n') ;

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
        %   Specify the name of the functional data to use
        func_data_full_name = [func_input_prefix func_data_name] ;
        %   Set full name with the location of the functional data
        func_data = fullfile(func_folder_path, [func_data_full_name '.nii,']) ;
        
        %   Calculate the total TR time of the functional data.
        init_spm_rest = spm_vol(func_data) ;
        [total_time, ~] = size(init_spm_rest) ;

        %   When existing previous cutting time data, delete the files for initialization first.
        if isfile(fullfile(func_folder_path, [output_prefix func_data_full_name '.nii']))
            cprintf('red', 'There is previous file cutting the frist few time, so it is removed.\n') ;
            delete(fullfile(func_folder_path, [output_prefix func_data_full_name '.nii'])) ;
        end
        
        %   
        for image_iter = 1:(total_time - cut_time)

            %   For saving functional data information.
            V.dim   = init_spm_rest(image_iter + cut_time, :).dim ; % this variable holds the image dimensions
            V.dt    = init_spm_rest(image_iter + cut_time, :).dt ;
            V.mat   = init_spm_rest(image_iter + cut_time, :).mat ;
            V.pinfo = init_spm_rest(image_iter + cut_time, :).pinfo ;
            V.descrip = init_spm_rest(image_iter + cut_time, :).descrip ;
            V.n = [image_iter 1] ;
            V.fname = fullfile(func_folder_path, [output_prefix func_data_full_name '.nii']) ;
            now_spm_rest = spm_vol([func_data num2str(image_iter + cut_time)]) ;
            cut_rest_data(:, :, :, image_iter) = spm_read_vols(now_spm_rest) ;
            V = spm_write_vol(V, cut_rest_data(:, :, :, image_iter)) ; %%% Saving the 4D matrix of residuals into a .nii file called 'REG_wrrest.nii' after adding the mean back
        end

        %%% Check length
        cut_func_data = fullfile(func_folder_path, [output_prefix func_data_full_name '.nii']) ;
        cut_spm_rest = spm_vol(cut_func_data) ;
        [cut_num_time, ~] = size(cut_spm_rest) ;

        if cut_num_time ~= (total_time - cut_time)
            cprintf('red', 'The cutting was not done well.\n') ;
        elseif cut_num_time == (total_time - cut_time)
            cprintf('red', 'The cutting was done well.\n') ;
        end

        

        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;              %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Cutting the start %d times   (%s (%d/%d) -   %s  (%d/%d)).\n'] ;     %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, func_folder_path, cut_time, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;                    %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear func_folder_path func_data_full_name func_data init_spm_rest total_time image_iter V now_spm_rest cut_rest_data
        clear cut_func_data cut_spm_rest cut_num_time
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists
end

%
cprintf('red', '<<<<<<<<<< Finished Cutting Times >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;                  %   Set up txt file location and name
content_format = 'The duration time of cutting the start %d times is %d seconds.\n' ;       %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, cut_time, tEnd) ;                                          %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of cutting the start %d times is %d seconds.\n\n\n', cut_time, tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart tEnd file_ID content_format
