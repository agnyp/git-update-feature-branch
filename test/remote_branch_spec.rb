require 'git_update_feature_branch/remote_branch'

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
  end

  context '#list_remote_branches:' do

    context 'no remote branch' do
      before do
        $branch = "notInThere"
        RemoteBranch.stub(:exec_git).with("fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@casual_branches)
      end
      subject {RemoteBranch.list_remote_branches}
      it 'should show an empty array' do
        subject.should be_empty
      end
    end

    context 'one correct remote branch' do
      before do
        RemoteBranch.stub(:exec_git).with("fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@correct_fb)
      end
      subject {RemoteBranch.list_remote_branches}
      it 'should have one correct branch in array' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__0")
      end

    end

    context 'a lot of incorrect remote branches' do
      before do
        RemoteBranch.stub(:exec_git).with("fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@incorrect_fbs)
      end
      subject {RemoteBranch.list_remote_branches}
      it 'should be empty' do
        subject.should be_empty
      end

    end

    context '3 remote branches' do
      before do
        RemoteBranch.stub(:exec_git).with("fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@three_fbs)
      end
      subject {RemoteBranch.list_remote_branches}
      it 'should have 3 branches in array' do
        subject.size.should eql(3)
      end
    end

  end

  context '#latest_remote_branch' do

    context 'there are 3 branches' do
      before do
        RemoteBranch.stub(:exec_git).with("fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@three_fbs)
      end
      subject {RemoteBranch.latest_remote_branch}
      it 'should give one branch with the highest number' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__2")
      end
    end

    context 'there are 3 non-consecutive branches' do
      before do
        RemoteBranch.stub(:exec_git).with("fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@random_fbs)
      end
      subject {RemoteBranch.latest_remote_branch}
      it 'should give one branch with the highest number' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__156")
      end
    end

    context 'there is one branch' do
      before do
        RemoteBranch.stub(:exec_git).with("fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@correct_fb)
      end
      subject {RemoteBranch.latest_remote_branch}
      it 'should give back this one branch' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__0")
      end
    end

    context 'there is no branch' do
      before do
        RemoteBranch.stub(:exec_git).with("fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("branch -r", kind_of(String)).and_return(@incorrect_fbs)
      end
      subject {RemoteBranch.latest_remote_branch}
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
        RemoteBranch.stub(:exec_git!).with("push origin feature-branch:fb__feature-branch__1 --porcelain").and_return(@new_branch)
      end
      subject {RemoteBranch.push_branch(1)}
      it 'should return *' do
        subject.should eql('*')
      end
    end

    context 'is a fast-forward' do
      before do
        RemoteBranch.stub(:exec_git!).with("push origin feature-branch:fb__feature-branch__1 --porcelain").and_return(@fast_forward_branch)
      end
      subject {RemoteBranch.push_branch(1)}
      it 'should return empty string' do
        subject.should eql('')
      end
    end

    context 'is rejected' do
      before do
        RemoteBranch.stub(:exec_git!).with("push origin feature-branch:fb__feature-branch__1 --porcelain").and_return(@rejected_branch)
      end
      subject {RemoteBranch.push_branch(1)}
      it 'should return !' do
        subject.should eql('!')
      end
    end

    context 'gets back broken things' do
      before do
        RemoteBranch.stub(:exec_git!).with("push origin feature-branch:fb__feature-branch__1 --porcelain").and_return(@broken_branch)
      end
      it 'should raise an error' do
        expect {RemoteBranch.push_branch(1)}.to raise_error(RuntimeError)
      end
    end

  end

  context '#delete_branch' do
    before :all do
      @deleted_branch = <<EOS
To git@github.com:agnyp/git-update-feature-branch.git
- :refs/heads/as-gem__1 [deleted]
Done
EOS
    end
    context 'deleted successfully' do
      it 'should return -'
    end

    context 'could not delete' do
      it 'should raise Exception'
    end

    context 'found nothing to delete' do
      it 'should be happy with it'
    end

  end

end
