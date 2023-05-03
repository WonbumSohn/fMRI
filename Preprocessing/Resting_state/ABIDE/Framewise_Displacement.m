%%  Explanation
%   
%   By Wonbum Sohn
%   Ver. May-2nd-2023
%   To move variables that do not change regardless of the for loop outside the for loop
%   Ver. April-30th-2023
%   To exclude functional data having severe head motion.

%%  Do calculation maximum and mean value of translation and rotation.
%   For calculation of duration time
tStart = tic ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   
cprintf('red', '<<<<<<<<<< Started Framewise Displacement >>>>>>>>>>\n') ;

%   Specify the name of the functional data to use
func_data_full_name = [input_prefix func_data_name] ;

%   Loop all subjects in this group
for subji = 1:length(subj_list)

    %   Show a subject being done.    
    cprintf('black', '<<<<< %s (%d/%d) >>>>>\n', subj_list(subji).name, subji, length(subj_list)) ;
 
    %   Set and move now subject location
    now_subj_path = fullfile(now_grp_path, subj_list(subji).name) ;
    cd(now_subj_path) ;

    %   Check the list of sessions in each subject folder.
    sess_lists = dir([common_sess_name '*']) ;
    %   Save this subject name and the session lists to exclude the sessions having severe head motion.
    total_lists{subji, 1} = subj_list(subji).name ;
    total_lists{subji, 2} = sess_lists ;

    %   Loop all sessions in this subject
    for sess_iter = 1:length(sess_lists)
    
        %   Show a session being done.
        cprintf('black', '<< %s (%d/%d) >>\n', sess_lists(sess_iter).name, sess_iter, length(sess_lists))

        %   Set functional data folder locations.
        func_folder_path = fullfile(now_subj_path, sess_lists(sess_iter).name, func_folder_name) ;
        

        %   Load a file having translation and rotation information text file.
        rp_txt = load(fullfile(func_folder_path, [func_data_full_name '.txt']));

        %   Calculate framewise displacement
        fd_trans = fd_calc(rp_txt(:,1:3)) ;                     %   Translation
        fd_rotat = fd_calc(rp_txt(:,4:6) * (180/pi)) ;          %   Rotation

        %   Calculate the maximum value
        fd_max_trans(sess_iter,1) = max(fd_trans) ;             %   Translation
        fd_max_rotat(sess_iter,1) = max(fd_rotat) ;             %   Rotation
        fd_max{subji, 1} = [fd_max_trans fd_max_rotat] ;

        %   Calculate the mean value
        fd_mean_trans(sess_iter,1) = mean(fd_trans) ;           %   Translation
        fd_mean_rotat(sess_iter,1) = mean(fd_rotat) ;           %   Rotation
        fd_mean{subji, 1} = [fd_mean_trans fd_mean_rotat] ;
        
        %%% Save progress so far in case that error occur.
        file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;          %   Set up txt file location and name
        content_format = ['Path: %s.\n' ...
                          'Framewise Displacement   (%s (%d/%d) -   %s  (%d/%d)).\n'] ;     %   Set up a form to fill in the txt file
        fprintf(file_ID, content_format, func_folder_path, subj_list(subji).name, subji, length(subj_list), ...
                sess_lists(sess_iter).name, sess_iter, length(sess_lists)) ;                %   Enter values in txt file
        fclose(file_ID) ;

        %   Remove the variables repeating or not necessary
        clear func_folder_path rp_txt fd_trans fd_rotat
        clear file_ID content_format
    end

    %   Remove the variables repeating or not necessary
    clear now_subj_path sess_lists fd_max_trans fd_max_rotat fd_mean_trans fd_mean_rotat
end

%%  Do framewise displacement

%   
cprintf('black', '<<<<<<<<<< Started excluding the sessions or subjects having severe head motions. >>>>>>>>>>\n') ;

%   Move to now group locations (Ex. ASD or TC)
cd(now_grp_path) ;

%   Loop all subjects in this group
for subji = 1:length(subj_list)

    %   Show a subject being done.    
    cprintf('black', '<<<<< %s (%d/%d) >>>>>\n', subj_list(subji).name, subji, length(subj_list)) ;
    
    %   Load maximum and mean matrix related to this subject.
    now_fd_max = fd_max{subji, 1} ;
    now_fd_mean = fd_mean{subji, 1} ;

    %   Exclude subjects having head motion with maximum translation and rotation value above than 1.5.
%     included = find(fd_max_trans<1.5&fd_max_rotat<1.5);
    excluded = find(now_fd_max(:, 1)>1.5|now_fd_max(:, 2)>1.5|now_fd_mean(:, 1)>0.2|now_fd_mean(:, 2)>0.2);

    %   Show the sessions having severe head motion.
    sess_lists = total_lists{subji, 2} ;
    for excji = 1:length(excluded)
        cprintf('red', 'Excluded [ %s ] sessions of [ %s ] subject.\n', sess_lists(excluded(excji)).name, subj_list(subji).name) ;
    end
    
    %   Exclude the sessions having severe head motion.
    sess_lists(excluded) = [] ;
    total_lists{subji, 2} = sess_lists ;
end

%   Exclude subjects from which all sessions have been removed.
empty_cells = cellfun('isempty', total_lists(:, 2)) ;
total_lists(empty_cells, :) = [] ;

%
cprintf('black', '<<<<<<<<<< Finished excluding the sessions or subjects having severe head motions. >>>>>>>>>>\n') ;

%   When existing previous adjusted subject lists file, delete the files for initialization first.
if isfile(fullfile(now_grp_path, 'adjusted_subj_lists.mat'))
    cprintf('red', 'There is previous adjusted subject lists file, so it is removed.\n') ;
    delete (fullfile(now_grp_path, 'adjusted_subj_lists.mat')) ;
end
%   Save the adjusted subject lists after the framewise displacement
save('adjusted_subj_lists.mat', "total_lists")

%
cprintf('red', '<<<<<<<<<< Finished Framewise Displacement >>>>>>>>>>\n') ;

%   For calculation of duration time
tEnd = toc(tStart) ;
%   Save the duration time of this step.
file_ID = fopen(fullfile(data_basic_path, 'processing_record.txt'), 'a') ;              %   Set up txt file location and name
content_format = 'The duration time of the framewise displacement is %d seconds.\n' ;   %   Set up a form to fill in the txt file
fprintf(file_ID, content_format, tEnd) ;                                                %   Enter values in txt file
fclose(file_ID) ;
%
cprintf('black', 'The duration time of the framewise displacement is %d seconds.\n\n\n', tEnd) ;

%   Remove the variables repeating or not necessary
clear tStart func_data_full_name tEnd file_ID content_format

%%  The function to calculate framewise displacement
function fd = fd_calc(Y)
    Y_diff = diff(Y) ;
    multp = Y_diff * Y_diff' ;
    fd = sqrt(diag(multp)) ;
end

