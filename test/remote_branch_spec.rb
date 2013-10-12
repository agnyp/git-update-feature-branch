require 'git_update_feature_branch/remote_branch'


describe RemoteBranch, '#list_remote_branches' do

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
  $origin = 'origin'

end

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
      $branch = "feature-branch"
      RemoteBranch.stub(:exec_git).with("git fetch", kind_of(String))
      RemoteBranch.stub(:exec_git).with("git branch -r", kind_of(String)).and_return(@correct_fb)
    end
    subject {RemoteBranch.list_remote_branches}
    it 'should have one correct branch in array' do
      subject[0].should eql("#{$origin}/fb__#{$branch}__0")
    end
    
  end

  context 'a lot of incorrect remote branches' do
    before do
      $branch = "feature-branch"
      RemoteBranch.stub(:exec_git).with("git fetch", kind_of(String))
      RemoteBranch.stub(:exec_git).with("git branch -r", kind_of(String)).and_return(@incorrect_fbs)
    end
    subject {RemoteBranch.list_remote_branches}
    it 'should be empty' do
      subject.should be_empty
    end
    
  end

  context '3 remote branches'do
    before do
      $branch = "feature-branch"
      RemoteBranch.stub(:exec_git).with("git fetch", kind_of(String))
      RemoteBranch.stub(:exec_git).with("git branch -r", kind_of(String)).and_return(@three_fbs)
    end
    subject {RemoteBranch.list_remote_branches}
    it 'should have 3 branches in array' do
      subject.size.should eql(3)
    end
  end
end

describe RemoteBranch, '#working_branch' do
  context 'given 2 remote branches' do
    before do

    end
    it 'should remember the highest branch'
  end
end

describe RemoteBranch, '#push_branch' do
  context 'new branch is highest branch' do
    it 'should push branch' 
  end

  context 'new branch is not highest branch' do
    it 'should raise NewerBranchException'
  end

  context 'after pushing: Check for higher branch -> there is none' do
    it 'should return all good'
  end 

  context 'after pushing: Check for higher branch -> there is one!' do
    it 'should raise NewerBranchException'
  end 

end
