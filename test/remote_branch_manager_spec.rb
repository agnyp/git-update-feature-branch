require 'git_update_feature_branch/remote_branch_manager'

describe RemoteBranchManager do
  
  context '#push_branch' do

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

end
