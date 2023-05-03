%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-3rd-2023
%   To move variables that do not change regardless of the for loop outside the for loop
%   Ver. May-1st-2023
%   For temporal regression.

%%  Do Temporal regression
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started Temporal Regression >>>>>>>>>>\n') ;

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
        func_data = fullfile(func_folder_path, func_data_full_name) ; 

        %   Obtain NIFTII header and image information
        v_rest = spm_vol([func_data '.nii,']) ;
        %   Save the image dimensions
        rest_dim = v_rest.dim ;
        %   Save the experiment time
        [total_time, ~] = size(v_rest) ;

        %
        cprintf('black', 'First loading the motion parameters.\n')

        %   Load the 6 motion parameter file from the realignment stage
        rp_rest = load(fullfile(func_folder_path, [rp_prefix func_data_name '.txt'])) ;
        %   z-scoring the values.
        rp_rest_z = zscore(rp_rest) ;
        rp_previous_rest = [0 0 0 0 0 0 ;
                            rp_rest_z(1:end-1,:)] ;
        %   Create the Friston's 24-parameter model
        rp_auto_rest = [rp_rest_z rp_rest_z.^2 rp_previous_rest rp_previous_rest.^2] ;
        
        %   
        cprintf('black', 'Now loading pca components.\n')

        %   Load the first few PC of some masks which were generated using the Extraction_PCA.m script
        cov_file = load([func_data '_covariance.mat'], 'total_pca_lists') ;
        cov_file = cov_file.total_pca_lists ;
        mask_pca = cov_file(:, 2)' ;
        mask_pca = cell2mat(mask_pca) ;
        
        cprintf('black', 'Loading of covariates complete.\n')

        %   
        for image_iter = 1:total_time
            now_v_rest = spm_vol([func_data '.nii,' num2str(image_iter)]) ;
            now_rest(:, :, :, image_iter) = spm_read_vols(now_v_rest) ;
        end
        clear image_iter
        
        %   Keep the mean before regression if one is inclined to add the mean back after temporal regression.
        mean_image_rest = mean(now_rest, 4) ;
        
        %   
        cprintf('blue', 'Starting regression. However brace yourself! It taks a huge amount of time.\n')
        
        %   Masks and motion regressors
        for vi = 1:rest_dim(1)
            for vj = 1:rest_dim(2)
                for vk = 1:rest_dim(3)

                    %   This is basically generating the predictor matrix X for MATLAB's 'regress'
                    pred_matrix = zscore([mask_pca rp_auto_rest]); 
                    %   Check MATLAB's regress and match it with the commands here.
                    [pred_matrix, pred_matrix_int , rest_regressed(vi, vj, vk, :)] = ...
                        regress(shiftdim(now_rest(vi, vj, vk, :), 3), ...
                                [pred_matrix ones(total_time, 1)]) ;
                end
            end
        end
        
        %
        cprintf('blue', 'Finished regression.\n')
    
        %
        cprintf('black', 'Saving the results.\n')
        
        %   When existing previous temporal regression data, delete the files for initialization first.
        if isfile(fullfile(func_folder_path, [out_prefix func_data_full_name '.nii']))
            cprintf('red', 'There is a previous temporal regression file, so it is removed.\n') ;
            delete (fullfile(func_folder_path, [out_prefix func_data_full_name '.nii'])) ;
        end
        if isfile(fullfile(func_folder_path, [out_prefix func_data_full_name '_nomean.nii']))
            delete (fullfile(func_folder_path, [out_prefix func_data_full_name '_nomean.nii'])) ;
        end
       
        %   Save the 4D matrix of residuals with the mean
        for image_iter = 1:total_time
            %   For saving functional data information.
            V.dim   = v_rest(image_iter, :).dim ;
            V.dt    = v_rest(image_iter, :).dt ;
            V.mat   = v_rest(image_iter, :).mat ;
            V.pinfo = v_rest(image_iter, :).pinfo ;
            V.n = [image_iter 1] ;
            V.fname = fullfile(func_folder_path, [out_prefix func_data_full_name '.nii']) ;
            V = spm_write_vol(V, rest_regressed(:, :, :, image_iter) + mean_image_rest) ;
        end
        clear image_iter
        
        %   Save the 4D matrix of residuals without the mean
        for image_iter = 1:total_time
            %   For saving functional data information.
            V.dim   = v_rest(image_iter, :).dim ;
            V.dt    = v_rest(image_iter, :).dt ;
            V.mat   = v_rest(image_iter, :).mat ;
            V.pinfo = v_rest(image_iter, :).pinfo ;
            V.n = [image_iter 1] ;
            V.fname = fullfile(func_folder_path, [out_prefix func_data_full_name '_nomean.nii']) ;
            V = spm_write_vol(V, rest_regressed(:, :, :, image_iter)) ;
        end
        


        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Temporal regression  (%s (%d/%d) -   %s  (%d/%d)).\n'] ;     %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, func_folder_path, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;            %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear func_folder_path func_data v_rest rest_dim total_time
        clear rp_rest rp_rest_z rp_previous_rest rp_auto_rest cov_file mask_pca mean_image_rest vi vj vk V image_iter
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists sess_iter
end

%
cprintf('red', '<<<<<<<<<< Finished Temporal Regression >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;          %   Set up txt file location and name
content_format = 'The duration time of temporal regression is %d seconds.\n' ;      %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                            %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of temporal regression is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart func_data_full_name tEnd file_ID content_format subji
