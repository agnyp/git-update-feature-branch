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
  origin/continue
  origin/fb__feature-branch__156
  origin/fb__feature-branch__0
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
        RemoteBranch.stub(:exec_git).with("git fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("git branch -r", kind_of(String)).and_return(@casual_branches)
      end
      subject {RemoteBranch.list_remote_branches}
      it 'should show an empty array' do
        subject.should be_empty
      end
    end

    context 'one correct remote branch' do
      before do
        RemoteBranch.stub(:exec_git).with("git fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("git branch -r", kind_of(String)).and_return(@correct_fb)
      end
      subject {RemoteBranch.list_remote_branches}
      it 'should have one correct branch in array' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__0")
      end

    end

    context 'a lot of incorrect remote branches' do
      before do
        RemoteBranch.stub(:exec_git).with("git fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("git branch -r", kind_of(String)).and_return(@incorrect_fbs)
      end
      subject {RemoteBranch.list_remote_branches}
      it 'should be empty' do
        subject.should be_empty
      end

    end

    context '3 remote branches' do
      before do
        RemoteBranch.stub(:exec_git).with("git fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("git branch -r", kind_of(String)).and_return(@three_fbs)
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
        RemoteBranch.stub(:exec_git).with("git fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("git branch -r", kind_of(String)).and_return(@three_fbs)
      end
      subject {RemoteBranch.latest_remote_branch}
      it 'should give one branch with the highest number' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__2")
      end
    end

    context 'there are 3 non-consecutive branches' do
      before do
        RemoteBranch.stub(:exec_git).with("git fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("git branch -r", kind_of(String)).and_return(@random_fbs)
      end
      subject {RemoteBranch.latest_remote_branch}
      it 'should give one branch with the highest number' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__156")
      end
    end

    context 'there is one branch' do
      before do
        RemoteBranch.stub(:exec_git).with("git fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("git branch -r", kind_of(String)).and_return(@correct_fb)
      end
      subject {RemoteBranch.latest_remote_branch}
      it 'should give back this one branch' do
        subject.size.should eql(1)
        subject[0].should eql("#{$origin}/fb__#{$branch}__0")
      end
    end

    context 'there is no branch' do
      before do
        RemoteBranch.stub(:exec_git).with("git fetch", kind_of(String))
        RemoteBranch.stub(:exec_git).with("git branch -r", kind_of(String)).and_return(@incorrect_fbs)
      end
      subject {RemoteBranch.latest_remote_branch}
      it 'should give back empty array' do
        subject.should be_empty
      end
    end

  end

  context '#push_branch' do

    context 'no errors' do
      it 'should just do it'
    end

    context 'branch already exists' do
      it 'should raise BranchExistsException'
    end 

  end

end
