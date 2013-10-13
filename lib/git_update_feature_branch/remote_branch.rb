require 'git_update_feature_branch/git_interface'

class RemoteBranch
  class << self

    extend GitInterface

    def latest_remote_branch
      branches = list_remote_branches 
      return branches if branches.size <= 1
      highest = 0
      max = -1
      branches.each_with_index{ |br, ind|
        br0 = br.split('__').last.to_i
        if br0 > max
          highest = ind
          max = br0
        end
      }
      [branches[highest]]
    end

    def list_remote_branches
      exec_git "fetch", "Could not fetch. Aborting..."
      remote_branches = exec_git "branch -r", "Cannot find remote branches. Aborting..."
      remote_branches = find_branches remote_branches
    end

    def push_branch(nr)
      response = exec_git! "push origin feature-branch:fb__feature-branch__#{nr} --porcelain"
      response_arr = response.split(/\n/) 
      response_line = response_arr.find_index{ |line|
        line.match(/refs\/heads\/#{$branch}:/)
      }
      if response_line.nil? 
        raise "Did not find pushed branch. Worse!"
      end
      response_arr[response_line].split(/\s+/).first
    end

    def delete_updated
    end

    # Helper-functions
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

