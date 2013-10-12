require 'git_update_feature_branch/git_interface'

class RemoteBranch
  class << self

    extend GitInterface

    def list_remote_branches
      exec_git "git fetch", "Could not fetch. Aborting..."
      remote_branches = exec_git "git branch -r", "Cannot find remote branches. Aborting..."
      remote_branches = find_branches remote_branches
    end

    def latest_remote_branch
      branches = list_remote_branches 
      return branches if branches.size <= 1
      highest = -1
      branches.each_with_index{ |br, ind|
        if br.split('__').last.to_i > highest
          highest = ind
        end
      }
      [branches[highest]]
    end

    def delete_updated
    end

    def strip_branches(branches)
      branches.split(/\n/).map{ |item|
        item.gsub(/\s+/,'') 
      }.reject{|item|
        # not interested in other remotes than $origin and also not in HEAD
        !item.match(/\A#{$origin}\//) or item.include?('HEAD')
      }.reject{|item|
        !item.include?($branch)
      }
    end

    def find_branches(str_list)
      strip_branches(str_list).reject{ |item|
        !item.match(/\A#{$origin}\/fb__/) or !item.match(/__\d+\Z/)
      }
    end

  end
end

