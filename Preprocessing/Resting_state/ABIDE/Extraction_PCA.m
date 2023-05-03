%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-3rd-2023
%   To move variables that do not change regardless of the for loop outside the for loop
%   Ver. May-2nd-2023
%   To extract first few PCA components from GM, WM or/and CSF mask.

%%  Extract frist few PCA components
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started extracting first %s PCA components >>>>>>>>>>\n', num2str(num_pca)) ;

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

        %   When existing previous PCA data, delete the files for initialization first.
        if isfile([func_data '_covariance.mat'])
            cprintf('red', 'There is previous PCA file, so it is removed.\n') ;
            delete ([func_data '_covariance.mat']) ;
        end

        %
        v_pair_REST = spm_vol([func_data '.nii,']) ;
        [total_time, ~] = size(v_pair_REST) ;
           
        %   
        for mask_iter = 1:length(mask_types)

            %   Load now mask type name
            now_mask_type = mask_types{mask_iter} ;

            %   Show a session being done.
            cprintf('black', '<< %s (%d/%d) >>\n', now_mask_type, mask_iter, length(mask_types))

            %   Load now type mask and reshape it into 2D matrix
            now_mask = spm_vol([func_data '_' now_mask_type '_' mask_opt '_mask.nii']) ;                            %   1x1 struct
            now_mask_files  = spm_read_vols(now_mask) ;                                                             %   mask volume
            now_mask_dim = now_mask.dim ;                                                                           %   volume size
            now_mask_reshaped  = reshape(now_mask_files, now_mask_dim(1)*now_mask_dim(2)*now_mask_dim(3), 1) ;      %   Nx1
      
            %   Load each time point one at a time and stack into a matrix.
            for imagei = 1:total_time
        
                now_rest_list = spm_vol([func_data '.nii,' num2str(imagei)]);
                now_rest_files = spm_read_vols(now_rest_list);
                now_rest_dim = now_rest_list.dim;
                now_rest_reshaped = reshape(now_rest_files, now_rest_dim(1)*now_rest_dim(2)*now_rest_dim(3),1);
        
                masked_rest(:,imagei) = now_rest_reshaped(find(now_mask_reshaped > 0.5)); %%%% time series extracted within the GM mask.
                
                %   Remove the variables repeating or not necessary
                clear now_rest_list now_rest_files now_rest_dim now_rest_reshaped
            end

            %   Make sure all NaN values are set to 0 before pca calculation
            nan_to_0 = isnan(masked_rest) ;     %   For example, isnan([pi NaN Inf -Inf]) is [0 1 0 0].
            nan_loc = find(nan_to_0 > 0) ;      %   Extract only the location where 1 is stored because of Nan.
            masked_rest(nan_loc) = 0 ;          %   Replace from NaN to 0

            %   Perform the PCA analysis of time series of masked rest data
            [c_masked_rest, pca_masked_rest] = pca(masked_rest') ;
            %   Extract only the first few principal components
            pca_masked_rest  = pca_masked_rest (:, 1:num_pca) ;
    
            %   Make cell to save the first few principal components
            total_pca_lists{mask_iter, 1} = now_mask_type ;
            total_pca_lists{mask_iter, 2} = pca_masked_rest ;
            
    
            %   Remove the variables repeating or not necessary
            clear now_mask_type now_mask now_mask_files now_mask_dim now_mask_reshaped
            clear nan_to_0 nan_loc masked_rest c_masked_rest pca_masked_rest
        end

        %   Save the pca cell files
        save ([func_data '_covariance.mat'], 'total_pca_lists');
  


        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;                      %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Extracting first %d PCA components   (%s (%d/%d) -   %s  (%d/%d)).\n'] ;     %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, func_folder_path, num_pca, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;                            %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear func_folder_path func_data v_pair_REST total_time total_pca_lists
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists
end

%
cprintf('red', '<<<<<<<<<< Finished extracting first %s PCA components >>>>>>>>>>\n', num2str(num_pca)) ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;                           %   Set up txt file location and name
content_format = 'The duration time of extracting first %d PCA components is %d seconds.\n' ;        %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, num_pca, tEnd) ;                                                    %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of extracting first %d PCA components is %d seconds.\n', num_pca, tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart func_data_full_name tEnd file_ID content_format
