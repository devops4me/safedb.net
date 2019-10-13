#!/usr/bin/ruby

module SafeDb


    # Provision the git branch involved in our present working directory.
    # The [present directory] may not relate to version control at all or
    # it may relate to the master or other branch in the source mgt tool.
    class Github


        # Make the folder at the given path a git repository if it is not
        # one already. If the folder is already under git management then
        # this call has no effect.
        #
        # @param repo_path [String] folder path to the desired git repository
        def self.init repo_path

            git_init_cmd = "git init #{repo_path}"
            log.info(x) { "[git] add command => #{git_init_cmd}" }
            cmd_output = %x[#{git_init_cmd}];

            log.info(x) { "[git] initializing git repository at path #{repo_path}" }
            log.info(x) { "[git] init command output : #{cmd_output}" }

        end



        # Log the files (names and/or content) that either do not come under the
        # wing of git or have been added to git repository management but are yet
        # to be committed into the repository. Also an files are logged that have
        # either been updated, deleted or moved.
        #
        # @param repo_path [String] folder path to the desired git repository
        # @param by_line [Boolean]
        #     if set to true the log will list the changed lines fronted either
        #     with a plus or a minus sign. False will just list the file names
        def self.list( repo_path, by_line=false )

            path_to_dot_git = File.join( repo_path, ".git" )
            line_by_line = by_line ? "-v" : ""

            git_log_cmd = "git --git-dir=#{path_to_dot_git} --work-tree=#{repo_path} status #{line_by_line}"
            log.info(x) { "[git] status command => #{git_log_cmd}" }
            git_log_output = %x[#{git_log_cmd}]

            git_log_output.log_debug if by_line
            git_log_output.log_info unless by_line

        end



        # Stage all files that evoke some kind of difference between the
        # working copy and the local git repository so that they can all
        # be committed.
        #
        # Files that will be staged by this method can be
        #
        # - newly created files (that do not match gitignore patterns)
        # - modified files that are already under git version management
        # - files deleted in the working copy but not removed from the repository
        # - files renamed in the same folder or with their path changed too
        # - all the above but found recursively under the root repository path
        #
        # @param repo_path [String] folder path to the desired git repository
        def self.stage repo_path

            path_to_dot_git = File.join( repo_path, ".git" )
            git_add_cmd = "git --git-dir=#{path_to_dot_git} --work-tree=#{repo_path} add -A"
            log.info(x) { "[git] add command => #{git_add_cmd}" }
            %x[#{git_add_cmd}];
            log.info(x) { "[git] has recursively added resources to version management." }

        end



        # Commit all changes to the local git repository.
        #
        # @param repo_path [String] folder path to the desired git repository
        def self.commit( repo_path, commit_msg )

            path_to_dot_git = File.join( repo_path, ".git" )
            git_commit_cmd = "git --git-dir=#{path_to_dot_git} --work-tree=#{repo_path} commit -m \"#{commit_msg}\";"
            log.info(x) { "[git] commit command => #{git_commit_cmd}" }
            %x[#{git_commit_cmd}];
            log.info(x) { "[git] has committed resources into the local repository." }

        end



        # Remove a specific file from git management and also delete the
        # working copy version of the file.
        #
        # @param repo_path [String] folder path to the desired git repository
        # @param file_path [String] file to remove from the repo and working copy
        def self.del_file( repo_path, file_path )

            path_to_dot_git = File.join( repo_path, ".git" )
            git_rm_cmd = "git --git-dir=#{path_to_dot_git} --work-tree=#{repo_path} rm #{file_path}"
            log.info(x) { "[git] file remove command => #{git_rm_cmd}" }
            %x[#{git_rm_cmd}];
            log.info(x) { "[git] has removed #{file_path} from repo and working copy." }

        end



        # Add a specific file that exists in the working copy to the git
        # version controller.
        #
        # @param repo_path [String] folder path to the desired git repository
        # @param file_path [String] file to add to the git version controller
        def self.add_file( repo_path, file_path )

            path_to_dot_git = File.join( repo_path, ".git" )
            git_add_cmd = "git --git-dir=#{path_to_dot_git} --work-tree=#{repo_path} add #{file_path}"
            log.info(x) { "[git] single file add command => #{git_add_cmd}" }
            %x[#{git_add_cmd}];
            log.info(x) { "[git] has added #{file_path} into the git repository." }

        end





  # --
  # -- Check in whatever has changed in the local repository
  # -- at the path stated in the first parameter.
  # --
  # -- The text in the second parameter helps to distinguish
  # -- what was to be pushed up and forms part of the git
  # -- commit message.
  # --
  def self.push repo_root_dir, what_changed_string, time_stamp

    dot_git_path = File.join repo_root_dir, ".git"
    Throw.if_not_exists dot_git_path

    Dir.chdir repo_root_dir

    git_diff_cmd = "git status -vv; echo;"
    git_diff_output = %x[#{git_diff_cmd}]
    git_diff_output.log_lines

    git_add_cmd = "git add -A; echo;"
    git_add_output = %x[#{git_add_cmd}]
    git_add_output.log_lines

    git_commit_cmd = "git commit -m \"Writing #{what_changed_string} at #{time_stamp}.\";"
    git_commit_output = %x[#{git_commit_cmd}]
    git_commit_output.log_lines

    # --
    # -- This command may require input (username/password) from the
    # -- user hence we don't wrap inside output trapping executors.
    # --
    system "git push origin master"

  end


  # -- ------------------------------------------------- -- #
  # -- Return the branch name of a local git repository. -- #
  # -- ------------------------------------------------- -- #
  # -- Parameter                                         -- #
  # --   path_to_dot_git : local path to the .git folder -- #
  # --                                                   -- #
  # -- Dependencies and Assumptions                      -- #
  # --   git is installed on the machine                 -- #
  # -- ------------------------------------------------- -- #
  def self.wc_branch_name path_to_dot_git

    cmd = "git --git-dir=#{path_to_dot_git} branch";
    branch_names = %x[#{cmd}];
    branch_names.each_line do |line|
      return line[2, line.length].strip if line.start_with?('*')
    end
    raise ArgumentError.new "No branch name starts with asterix.\n#{cmd}\n#{branch_names}\n"

  end


  # -- ------------------------------------------------- -- #
  # -- Get the remote origin url of a git working copy.  -- #
  # -- ------------------------------------------------- -- #
  # -- Parameter                                         -- #
  # --   path_to_dot_git : local path to .git folder     -- #
  # --                                                   -- #
  # -- Dependencies and Assumptions                      -- #
  # --   git is installed on the machine                 -- #
  # --   working copy exists and has remote origin       -- #
  # -- ------------------------------------------------- -- #
  def self.wc_origin_url path_to_dot_git

    cmd = "git --git-dir=#{path_to_dot_git} config --get remote.origin.url"
    url = %x[#{cmd}];
    raise ArgumentError.new "No remote origin url.\n#{cmd}\n" if url.nil?
    
    return url.strip

  end


  # -- -------------------------------------------------- -- #
  # -- Get the uncut revision of a git repo working copy. -- #
  # -- -------------------------------------------------- -- #
  # -- Parameter                                          -- #
  # --   path_to_dot_git : local path to .git folder      -- #
  # --                                                    -- #
  # -- Dependencies and Assumptions                       -- #
  # --   git is installed on the machine                  -- #
  # --   working copy exists and has remote origin        -- #
  # -- -------------------------------------------------- -- #
  def self.wc_revision_uncut path_to_dot_git

    log.info(x) { "##### GitFlow path to dot git is => #{path_to_dot_git}" }
    repo_url = wc_origin_url path_to_dot_git
    log.info(x) { "##### The GitFlow repo url is => #{repo_url}" }

    ## Bug HERE - On Ubuntu the branch name is like => (HEAD detached at 067f9a3)
    ## Bug HERE - This creates a failure of => sh: 1: Syntax error: "(" unexpected
    ## Bug HERE - The unexpected failure occurs in the ls-remote command below
    ## Bug HERE - So hardcoding this to "master" for now
    # branch_name = wc_branch_name path_to_dot_git
    branch_name = "master"

    log.info(x) { "##### The GitFlow branch name is => #{branch_name}" }
    cmd = "git ls-remote #{repo_url} ls-remote -b #{branch_name}"
    log.info(x) { "##### The GitFlow get dirty rev command is => #{cmd}" }
    dirty_revision = %x[#{cmd}];
    log.info(x) { "##### The dirty revision is => #{dirty_revision}" }
    return dirty_revision.partition("refs/heads").first.strip;

  end


  # -- -------------------------------------------------- -- #
  # -- Get brief revision of repo from working copy path. -- #
  # -- -------------------------------------------------- -- #
  # -- Parameter                                          -- #
  # --   path_to_dot_git : local path to .git folder      -- #
  # --                                                    -- #
  # -- Dependencies and Assumptions                       -- #
  # --   we return the first 7 revision chars             -- #
  # --   git is installed on the machine                  -- #
  # --   working copy exists and has remote origin        -- #
  # -- -------------------------------------------------- -- #
  def self.wc_revision path_to_dot_git

    log.info(x) { "GitFlow path to dot git is => #{path_to_dot_git}" }
    Throw.if_not_exists path_to_dot_git

    uncut_revision = wc_revision_uncut path_to_dot_git
    log.info(x) { "GitFlow uncut full revision is => #{uncut_revision}" }

    # -- --------------------------------------------------------------------- -- #
    # -- Gits [short revision] hash has 7 chars. Note 4 is the usable minimum. -- #
    # -- For usage in stamps where space comes at a premium - 6 chars will do. -- #
    # -- --------------------------------------------------------------------- -- #
    ref_length = 7
    return "r" + uncut_revision[0..(ref_length - 1)];

  end


  # -- -------------------------------------------------- -- #
  # -- Clone the branch of a local git repo working copy. -- #
  # -- -------------------------------------------------- -- #
  # -- Parameter                                          -- #
  # --   src_gitpath : local path to .git folder          -- #
  # --   new_wc_path : path to new non-existent dir       -- #
  # --                                                    -- #
  # -- Dependencies and Assumptions                       -- #
  # --   git is installed on the machine                  -- #
  # --   working copy exists and has remote origin        -- #
  # -- -------------------------------------------------- -- #
  def self.do_clone_wc path_to_dot_git, path_to_new_dir

    # -- ----------------------------------------------------------- -- #
    # -- Why clone from a working copy (instead of a remote url).    -- #
    # -- ----------------------------------------------------------- -- #
    # --                                                             -- #
    # -- When actively [DEVELOPING] an eco plugin and you want to    -- #
    # --                                                             -- #
    # --   1 - [test] the behaviour without a git commit/git push    -- #
    # --   2 - test whatever [branch] the working copy is now at     -- #
    # --                                                             -- #
    # -- This use case requires us to clone from a working copy.     -- #
    # --                                                             -- #
    # -- ----------------------------------------------------------- -- #

###   Bug here - see getting branch name issue
###   Bug here - see getting branch name issue
###   Bug here - see getting branch name issue
###   Bug here - see getting branch name issue
###    branch_name = wc_branch_name path_to_dot_git
    branch_name = "master"
#####    cmd = "git clone #{path_to_dot_git} -b #{branch_name} #{path_to_new_dir}"
#####    cmd = "git clone #{path_to_dot_git} -b #{branch_name} #{path_to_new_dir}"
#####    cmd = "git clone #{path_to_dot_git} -b #{branch_name} #{path_to_new_dir}"
    cmd = "git clone #{path_to_dot_git} #{path_to_new_dir}"
    clone_output = %x[#{cmd}];

    log.info(x) { "[gitflow] cloning working copy" }
    log.info(x) { "[gitflow] repo branch name  : #{branch_name}" }
    log.info(x) { "[gitflow] src dot git path  : #{path_to_dot_git}" }
    log.info(x) { "[gitflow] new wc dir path   : #{path_to_new_dir}" }
    log.info(x) { "[gitflow] git clone command : #{cmd}" }
    log.info(x) { "[gitflow] git clone output  : #{clone_output}" }

  end


  # --
  # -- Clone a remote repository at the specified [url] into
  # -- a [NON-EXISTENT] folder path.
  # --
  # -- ---------------------------------
  # -- What is a Non Existent Dir Path?
  # -- ---------------------------------
  # --
  # -- The parent directory of a non existent folder path
  # -- must [exist] whilst the full path itself does not.
  # -- The clone operation will create the final folder in
  # -- the path and then it [puts] the repository contents
  # -- within it.
  # --
  # -- -----------
  # -- Parameters
  # -- -----------
  # --
  # --   repo_url  : url ends in dot git f-slash
  # --   clone_dir : path to new non-existent dir
  # --
  # -- -----------------------------
  # -- Dependencies and Assumptions
  # -- -----------------------------
  # --
  # --   git is installed on the machine
  # --   repo exists and is publicly readable
  # --   the master branch is he one to clone
  # --   the current Dir.pwd() is writeable
  # --
  def self.do_clone_repo repo_url, non_existent_path

    cmd = "git clone #{repo_url} #{non_existent_path}"
    clone_output = %x[#{cmd}];

    log.info(x) { "[gitflow] cloning remote repository" }
    log.info(x) { "[gitflow] git repository url : #{repo_url}" }
    log.info(x) { "[gitflow] git clone dir path : #{nickname non_existent_path}" }
    log.info(x) { "[gitflow] git clone command  : #{cmd}" }
    log.info(x) { "[gitflow] git clone output   : #{clone_output}" }

  end


  # -- ----------------------------------------------------- -- #
  # -- Clone [many] git repositories given an array of urls  -- #
  # -- along with a corresponding array of the working copy  -- #
  # -- folder names and a [parental] base (offset) folder.   -- #
  # -- ----------------------------------------------------- -- #
  # -- Parameter                                             -- #
  # --   repo_urls  : array of git repository urls           -- #
  # --   base_names : array of cloned repo base names        -- #
  # --   parent_dir : path to local [parent] folder          -- #
  # --                                                       -- #
  # -- Dependencies and Assumptions                          -- #
  # --   arrays have equiv corresponding entries             -- #
  # --   parent dir is created if not exists                 -- #
  # --   repos exist and are publicly readable               -- #
  # --   master branches are the ones to clone               -- #
  # -- ----------------------------------------------------- -- #
  def self.do_clone_repos repo_urls, base_names, parent_dir

    Dir.mkdir parent_dir unless File.exists? parent_dir
    Throw.if_not_found parent_dir, "clone repos"

    repo_urls.each_with_index do | repo_url, repo_index |

      git_url = repo_url if repo_url.end_with? @@url_postfix
      git_url = "#{repo_url}#{@@url_postfix}" unless repo_url.end_with? @@url_postfix

      proj_folder = File.join parent_dir, base_names[repo_index]

      log.info(x) { "[clone repos] proj [index] => #{repo_index}" }
      log.info(x) { "[clone repos] repo url 1st => #{repo_url}" }
      log.info(x) { "[clone repos] repo url 2nd => #{git_url}" }
      log.info(x) { "[clone repos] project name => #{base_names[repo_index]}" }
      log.info(x) { "[clone repos] project path => #{proj_folder}" }

      GitFlow.do_clone_repo git_url, proj_folder

    end

  end


  # -- ------------------------------------------------ -- #
  # -- Move assets from a git repo to a local zip file. -- #
  # -- ------------------------------------------------ -- #
  # --                                                  -- #
  # -- Parameter                                        -- #
  # --   repo_url     : the url of the git repository   -- #
  # --   path_offset  : FWD-SLASH ENDED PATH in repo    -- #
  # --   target_dir   : the target folder for new zip   -- #
  # --   zip_filename : extensionless name of the zip   -- #
  # --                                                  -- #
  # -- Return                                           -- #
  # --   path to the zip file created in a tmp folder   -- #
  # --                                                  -- #
  # -- ------------------------------------------------ -- #
  # -- Dependencies and Assumptions                     -- #
  # -- ------------------------------------------------ -- #
  # --                                                  -- #
  # --   END PATH OFFSET WITH A FORWARD SLASH           -- #
  # --   IF NO OFFSET SEND "/" for path_offset          -- #
  # --   git is installed on the machine                -- #
  # --   the repo exists with path offset               -- #
  # --   the master branch is archived                  -- #
  # --   name is unique as used to create a dir         -- #
  # --                                                  -- #
  # -- ------------------------------------------------ -- #
  def self.git2zip repo_url, path_offset, target_dir, zip_basename

    log.info(x) { "[git2zip] ------------------------------------------- -- #" }
    log.info(x) { "[git2zip] archiving repo assets at path offset        -- #" }
    log.info(x) { "[git2zip] ------------------------------------------- -- #" }
    log.info(x) { "[git2zip] git repository url    : #{repo_url}" }
    log.info(x) { "[git2zip] slash tail dir offset : #{path_offset}" }
    log.info(x) { "[git2zip] target zip directory  : #{target_dir}" }
    log.info(x) { "[git2zip] zip file [base] name  : #{zip_basename}" }

    clone_dir = File.join Dir.tmpdir(), zip_basename
    do_clone_repo repo_url, clone_dir
    dot_git_path = File.join clone_dir, ".git"
    dst_zip_path = File.join target_dir, "#{zip_basename}.zip"

    the_offset = path_offset
    the_offset = "" if path_offset.length == 1
    cmd = "git --git-dir=#{dot_git_path} archive -o #{dst_zip_path} HEAD:#{the_offset}"
    clone_output = %x[#{cmd}];

    log.info(x) { "[git2zip] tmp clone src folder  : #{clone_dir}" }
    log.info(x) { "[git2zip] cloned dot git path   : #{dot_git_path}" }
    log.info(x) { "[git2zip] target zip full path  : #{dst_zip_path}" }
    log.info(x) { "[git2zip] git archive command   : #{cmd}" }
    log.info(x) { "[git2zip] ------------------------------------------- -- #" }
    log.info(x) { "#{clone_output}" }
    log.info(x) { "[git2zip] ------------------------------------------- -- #" }

    return dst_zip_path

  end


  # -- ------------------------------------------------- -- #
  # -- Return an array of simple file names in the repo. -- #
  # -- ------------------------------------------------- -- #
  # -- Parameter                                         -- #
  # --   repo_url : the url of the repository to read    -- #
  # --                                                   -- #
  # -- Dependencies and Assumptions                      -- #
  # --   we are not interested in folders                -- #
  # --   trawl is recursive (infinite depth)             -- #
  # --   git is installed on the machine                 -- #
  # -- ------------------------------------------------- -- #
  def self.file_names repo_url

    random_text = SecureRandom.urlsafe_base64(12).delete("-_").downcase
    cloned_name = "eco.repo.clone.#{random_text}"
    cloned_path = File.join Dir.tmpdir(), cloned_name

    do_clone_repo repo_url, cloned_path
    dot_git_path = File.join cloned_path, ".git"

    cmd = "git --git-dir=#{dot_git_path} ls-tree -r master --name-only"
    filename_lines = %x[#{cmd}];
    names_list = Array.new
    filename_lines.each_line do |line|
      names_list.push line.strip
    end

    log.info(x) { "[git2files] ----------------------------------------------" }
    log.info(x) { "[git2files] [#{names_list.length}] files in [#{repo_url}]" }
    log.info(x) { "[git2files] ----------------------------------------------" }
    log.info(x) { "[git2files] Random Text : #{random_text}" }
    log.info(x) { "[git2files] Cloned Name : #{cloned_name}" }
    log.info(x) { "[git2files] Cloned Path : #{cloned_path}" }
    log.info(x) { "[git2files] Repo Folder : #{dot_git_path}" }
    log.info(x) { "[git2files] Reading Cmd : #{cmd}" }
    log.info(x) { "[git2files] ----------------------------------------------" }
    pp names_list
    log.info(x) { "[git2files] ----------------------------------------------" }

    return names_list

  end


  end

end

