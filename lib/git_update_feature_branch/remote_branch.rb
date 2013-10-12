require 'git_update_feature_branch/git_interface'

class RemoteBranch

  extend GitInterface

  def self.list_remote_branches
    exec_git "git fetch", "Could not fetch. Aborting..."
    remote_branches = exec_git "git branch -r", "Cannot find remote branches. Aborting..."
    remote_branches = find_branches remote_branches
  end

  def self.delete_updated
  end


  private 

  def self.strip_branches(branches)
    branches.split(/\n/).map{ |item|
      item.gsub(/\s+/,'') 
    }.reject{|item|
      # not interested in other remotes than $origin and also not in HEAD
      !item.match(/\A#{$origin}\//) or item.include?('HEAD')
    }.reject{|item|
      !item.include?($branch)
    }
  end
  
  def self.find_branches(str_list)
    strip_branches(str_list).reject{ |item|
      !item.match(/\A#{$origin}\/fb__/) or !item.match(/__\d+\Z/)
    }
  end

end

