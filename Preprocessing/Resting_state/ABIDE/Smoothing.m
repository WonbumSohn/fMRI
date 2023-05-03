%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-3rd-2023
%   To move variables that do not change regardless of the for loop outside the for loop
%   Ver. May-1st-2023
%   For smoothing

%%  Do Smoothing
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started Smoothing >>>>>>>>>>\n') ;

%   Specify the name of the functional data to use
func_data_full_name = [func_input_prefix func_data_name] ;

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
        func_data = fullfile(func_folder_path, [func_data_full_name '.nii,']) ; 

        %   When existing previous smoothing data, delete the files for initialization first.
        if isfile(fullfile(func_folder_path, [out_prefix func_data_full_name '.nii']))
            cprintf('red', 'There is a smoothing file, so it is removed.\n') ;
            delete (fullfile(func_folder_path, [out_prefix func_data_full_name '.nii'])) ;
        end

        %   Calculate the total TR time of the functional data.
        v_pair_rest = spm_vol(func_data) ;
        [total_time, ~] = size(v_pair_rest) ;
        
        %
        for image_iter = 1:total_time
            smoothing_list{image_iter, 1} = [func_data, num2str(image_iter)] ;
        end
        
        %   Set the value of fwhm. (Voxel size x 3) Ex) 2mm -> [6 6 6] / 3mm -> [8 8 8]
        switch voxel_value
            case 2
                fwhm_value = [6 6 6];
            case 3
                fwhm_value = [8 8 8];
        end

        matlabbatch{1}.spm.spatial.smooth.data = smoothing_list ;
        matlabbatch{1}.spm.spatial.smooth.fwhm = fwhm_value ;
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = out_prefix ;

        %   Run
        spm_jobman('run', matlabbatch);



        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Smoothing    (%s (%d/%d) -   %s  (%d/%d)).\n'] ;             %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, func_folder_path, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;            %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear matlabbatch func_folder_path func_data
        clear v_pair_rest total_time image_iter smoothing_list
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists
end

%
cprintf('red', '<<<<<<<<<< Finished Smoothing >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
content_format = 'The duration time of smoothing is %d seconds.\n' ;            %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                        %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of smoothing is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart func_data_full_name tEnd file_ID content_format
