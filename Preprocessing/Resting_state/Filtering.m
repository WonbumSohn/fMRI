%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-1st-2023
%   For filtering

%%  Do Filtering
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started Filtering >>>>>>>>>>\n') ;

%   Specify the name of the functional data to use
func_data_full_name = [func_input_prefix func_data_name] ;
%   Specify the name of the output data
out_data_name = [output_prefix func_data_full_name '.nii'] ;

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
        func_cp_data = fullfile(func_folder_path, ['cp_' func_data_full_name '.nii']) ;
        %   
        out_data = fullfile(func_folder_path, out_data_name) ;
        %   
        mask_data = fullfile(func_folder_path, [func_data_full_name mask_name '.nii']) ;

        %   When existing previous filtering data, delete the files for initialization first.
        if isfile(out_data)
            cprintf('red', 'There is a filtering file, so it is removed.\n') ;
            delete (out_data) ;
        end  

        %
        command_cp = ['cp' ' -r ' func_data ' ' func_cp_data] ;
        command_frq = ['3drefit' ' -TR ' int2str(TR_value) ' ' func_cp_data] ;
        command_bpf = ['3dBandpass' ' -prefix ' out_data ' -band ' '0.01 0.1' ' -mask ' mask_data ' ' func_cp_data] ;
        %   Remove the copy data
        command_rm = ['rm -f ' func_cp_data] ;
            
        system(command_cp) ;
        system(command_frq) ;
        system(command_bpf) ;
        system(command_rm) ;
    
        

        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Filtering    (%s (%d/%d) -   %s  (%d/%d)).\n'] ;             %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, func_folder_path, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;            %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear func_folder_path func_data out_data mask_data command_frq command_bpf
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists
end

%
cprintf('red', '<<<<<<<<<< Finished Filtering >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;      %   Set up txt file location and name
content_format = 'The duration time of filtering is %d seconds.\n' ;            %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                        %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of filtering is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear func_data_full_name out_data_name
clear tStart tEnd file_ID content_format
