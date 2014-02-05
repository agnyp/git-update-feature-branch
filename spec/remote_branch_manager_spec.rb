require 'git_update_feature_branch/remote_branch_manager'

describe RemoteBranchManager do
  before :each do
    @manager = RemoteBranchManager.new
  end
  
  context '#push_branch' do

    context 'new branch is highest branch' do
      context 'checked before push' do
        it 'should push branch' 
      end
      context 'received error attempting to push' do
        it 'should raise NewerBranchException and update again with the highest branch'
      end
    end

    context 'new branch is not highest branch' do
      context 'checked before push' do
        it 'should raise NewerBranchException and update again with the highest branch'
      end
      context 'received error attempting to push' do
        it 'should raise NewerBranchException and update again with the highest branch'
      end
    end

    context 'after pushing: Check for higher branch -> there is one!' do
      it 'should raise NewerBranchException and update again with the highest branch'
    end 

    context 'after pushing: Check for higher branch -> there is none' do
      it 'should return all good'
    end 

  end
end
