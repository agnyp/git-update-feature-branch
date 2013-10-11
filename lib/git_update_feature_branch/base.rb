require "git_update_feature_branch/git_interface"

class Base 

  include GitInterface

  def run
    branch = nil
    origin_branch=nil
    ARGV.each_with_index { |a, i| 
      if i == 0
        branch=a 
      end
      origin_branch="origin/#{branch}"
      if i == 1
        origin_branch="origin/#{a}"
      end
    }
    puts "Working with \'#{branch}\'"
    puts "Remote branch \'#{origin_branch}\'"

    # Testing if according branch exists and is a good one
    if branch == "master"
      puts "Using master as a feature branch is not permitted!"
      exit 1
    end 
    checkout_branch branch

    check_for_dirty_directory

    # 1. Step - checkout master and get latest version
    puts "Pulling master and rebasing your feature-branch..."
    checkout_branch "master"
    exec_git "git fetch","Could not fetch."
    exec_git "git pull origin master", "Could not pull master"

    checkout_branch branch
    exec_git "git rebase master", "Rebasing your bransch \'#{branch}\' with master failed. Could not update your work."

    # Step 2 - Updating remote feature-branch to our master 
    puts "Rebasing feature-branch from origin onto local master ..."
    updated_origin_branch="#{branch}_from_origin"
    exec_git "git checkout #{origin_branch}","Could not checkout #{origin_branch}"
    exec_git "git rebase master","Error..."
    exec_git "git branch -f #{updated_origin_branch}","Could not create tempory branch #{updated_origin_branch}"
    exec_git "git checkout #{updated_origin_branch}","Could not checkout tempory branch #{updated_origin_branch}"

    # Step 3 - Rebasing our work to origin feature-branch
    puts "Rebasing lokal feature-branch with origin ..."
    checkout_branch branch
    exec_git "git rebase #{updated_origin_branch}","Step 3 - Could not rebase with remote-branch."
    exec_git "git branch -D #{updated_origin_branch}","Step 3 - Could not delete temporary branch #{updated_origin_branch}"

    puts
    puts "Successfully updated your feature-branch '#{branch}'."
    exit 0
  end

  private 

  def check_for_dirty_directory
    # checking for a dirty directory
    puts "Checking wc clean ..."
    out = `git status --porcelain` ; suc = $?.success?
    if out.length > 0 
      puts "You seem to have a dirty directory. Please commit or stage your changes and start over."
      exit 1
    end unless !suc
  end

end

