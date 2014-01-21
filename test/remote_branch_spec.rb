require 'git_update_feature_branch/remote_branch'

class ModuleWrapperForRemoteBranch
  include RemoteBranch
end

describe RemoteBranch do

  before :all do
    @casual_branches = <<BR
  origin/HEAD -> origin/master
  origin/as-gem
  origin/continue
  origin/master
BR
    @correct_fb = <<BR
  origin/HEAD -> origin/master
  origin/fb__feature-branch__0
  origin/continue
  origin/master
BR
    @incorrect_fbs = <<BR
  origin/HEAD -> origin/master
  origin/feature-branch__0
  origin/fb__feature-branch_
  origin/fb_feature-branch__0
  origin/fb__feature-branch
  origin/fb__feature-branch__a
  origin/continue
  origin/master
BR
    @three_fbs = <<BR
  origin/HEAD -> origin/master
  origin/fb__feature-branch__0
  origin/fb__feature-branch__1
  origin/fb__feature-branch__2
  origin/continue
  origin/master
BR
    @random_fbs = <<BR
  origin/HEAD -> origin/master
  origin/fb__feature-branch__154
  origin/fb__feature-branch__0
  origin/continue
  origin/fb__feature-branch__156
  origin/master
  origin/fb__feature-branch__153
BR

  end
  before :each do
    $origin = 'origin'
    $branch = "feature-branch"
    @brancher = ModuleWrapperForRemoteBranch.new
  end

  context '#list_remote_branches:' do

    context 'no remote branch' do
      before do
        $branch = "notInThere"
        @brancher.stub(:exec_git).with("fetch", kind_of(String))
        @brancher.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@casual_branches)
      end
      subject {@brancher.list_remote_branches}
      it 'should show an empty array' do
        subject.should be_empty
      end
    end

    context 'one correct remote branch' do
      before do
        @brancher.stub(:exec_git).with("fetch", kind_of(String))
        @brancher.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@correct_fb)
      end
      subject {@brancher.list_remote_branches}
      it 'should have one correct branch in array' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__0")
      end

    end

    context 'a lot of incorrect remote branches' do
      before do
        @brancher.stub(:exec_git).with("fetch", kind_of(String))
        @brancher.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@incorrect_fbs)
      end
      subject {@brancher.list_remote_branches}
      it 'should be empty' do
        subject.should be_empty
      end

    end

    context '3 remote branches' do
      before do
        @brancher.stub(:exec_git).with("fetch", kind_of(String))
        @brancher.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@three_fbs)
      end
      subject {@brancher.list_remote_branches}
      it 'should have 3 branches in array' do
        subject.size.should eql(3)
      end
    end

  end

  context '#latest_remote_branch' do

    context 'there are 3 branches' do
      before do
        @brancher.stub(:exec_git).with("fetch", kind_of(String))
        @brancher.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@three_fbs)
      end
      subject {@brancher.latest_remote_branch}
      it 'should give one branch with the highest number' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__2")
      end
    end

    context 'there are 3 non-consecutive branches' do
      before do
        @brancher.stub(:exec_git).with("fetch", kind_of(String))
        @brancher.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@random_fbs)
      end
      subject {@brancher.latest_remote_branch}
      it 'should give one branch with the highest number' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__156")
      end
    end

    context 'there is one branch' do
      before do
        @brancher.stub(:exec_git).with("fetch", kind_of(String))
        @brancher.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@correct_fb)
      end
      subject {@brancher.latest_remote_branch}
      it 'should give back this one branch' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__0")
      end
    end

    context 'there is no branch' do
      before do
        @brancher.stub(:exec_git).with("fetch", kind_of(String))
        @brancher.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@incorrect_fbs)
      end
      subject {@brancher.latest_remote_branch}
      it 'should give back empty array' do
        subject.should be_empty
      end
    end

  end

  context '#push_branch' do
    before :all do
@broken_branch = <<NEW
Total 0 (delta 0), reused 0 (delta 0)
To git@github.com:agnyp/git-update-feature-branch.git
* refs/heads/as-gem:refs/heads/as-gem__1  [new branch]
Done
NEW
@new_branch = <<NEW
Total 0 (delta 0), reused 0 (delta 0)
To git@github.com:agnyp/git-update-feature-branch.git
* refs/heads/feature-branch:refs/heads/fb__feature-branch__1  [new branch]
Done
NEW
@fast_forward_branch = <<EOS
Counting objects: 15, done.
  Delta compression using up to 3 threads.
  Compressing objects: 100% (8/8), done.
  Writing objects: 100% (8/8), 1.51 KiB, done.
  Total 8 (delta 6), reused 0 (delta 0)
To git@github.com:agnyp/git-update-feature-branch.git
  refs/heads/feature-branch:refs/heads/as-gem bd828f2..abcd35e
  Done
EOS
@rejected_branch = <<EOS
To git@github.com:agnyp/git-update-feature-branch.git
! refs/heads/feature-branch:refs/heads/as-gem [rejected] (non-fast-forward)
Done
error: failed to push some refs to 'git@github.com:agnyp/git-update-feature-branch.git'
To prevent you from losing history, non-fast-forward updates were rejected
Merge the remote changes (e.g. 'git pull') before pushing again.  See the
'Note about fast-forwards' section of 'git push --help' for details.
EOS
    end

    context 'all planned' do
      before do
        @brancher.stub(:exec_git!).with("push origin feature-branch:fb__feature-branch__1 --porcelain").and_return(@new_branch)
      end
      subject {@brancher.push_branch(1)}
      it 'should return *' do
        subject.should eql('*')
      end
    end

    context 'is a fast-forward' do
      before do
        @brancher.stub(:exec_git!).with("push origin feature-branch:fb__feature-branch__1 --porcelain").and_return(@fast_forward_branch)
      end
      subject {@brancher.push_branch(1)}
      it 'should return empty string' do
        subject.should eql('')
      end
    end

    context 'is rejected' do
      before do
        @brancher.stub(:exec_git!).with("push origin feature-branch:fb__feature-branch__1 --porcelain").and_return(@rejected_branch)
      end
      subject {@brancher.push_branch(1)}
      it 'should return !' do
        subject.should eql('!')
      end
    end

    context 'gets back broken things' do
      before do
        @brancher.stub(:exec_git!).with("push origin feature-branch:fb__feature-branch__1 --porcelain").and_return(@broken_branch)
      end
      it 'should raise an error' do
        expect {@brancher.push_branch(1)}.to raise_error(RuntimeError)
      end
    end

  end

  context '#delete_branch' do
    before :all do
      @deleted_broken_branch = <<EOS
error: unable to push to unqualified destination: fb__feature-branch__0
The destination refspec neither matches an existing ref on the remote nor
begins with refs/, and we are unable to guess a prefix based on the source ref.
error: failed to push some refs to 'git@github.com:agnyp/git-update-feature-branch.git'
EOS
      @deleted_branch = <<EOS
To git@github.com:agnyp/git-update-feature-branch.git
- :refs/heads/fb__feature-branch__0 [deleted]
Done
EOS
    end
    context 'deleted successfully' do
      before do
        @brancher.stub(:exec_git!).with("push origin :fb__feature-branch__0 --porcelain").and_return(@deleted_branch)
      end
      subject{@brancher.delete_branch(0)}
      it 'should return -' do
        subject.should eql('-')
      end

    end

    context 'could not delete because it does not exist' do
      before do
        @brancher.stub(:exec_git!).with("push origin :fb__feature-branch__0 --porcelain").and_return(@deleted_broken_branch)
      end
      it 'should raise Exception' do
        expect {@brancher.delete_branch(0)}.to raise_error(DeleteBranchError)
      end
    end

    context 'could not delete because of an error' do
      before do
        @brancher.stub(:exec_git!).with("push origin :fb__feature-branch__0 --porcelain").and_return(@deleted_branch)
        $?.stub(:success?).and_return(false)
      end
      it 'should raise Exception -> but it is basically fine' do
        expect {@brancher.delete_branch(0)}.to raise_error(DeleteBranchError)
      end
    end

  end

end
