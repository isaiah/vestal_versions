require 'spec_helper'

describe VestalVersions::Versions do
  let(:user){ User.create(:name => 'Stephen Richert') }

  before do
    user.update_attribute(:name, 'Steve Jobs')
    user.update_attribute(:last_name, 'Richert')
    @first_version, @last_version = user.versions.first, user.versions.last
  end

  it 'is comparable to another version based on version iteration' do
    @first_version.should == @first_version
    @last_version.should == @last_version
    @first_version.should_not == @last_version
    @last_version.should_not == @first_version
    @first_version.should < @last_version
    @last_version.should > @first_version
    @first_version.should <= @last_version
    @last_version.should >= @first_version
  end

  it "is not equal a separate model's version with the same iteration" do
    other = User.create(:name => 'Stephen Richert')
    other.update_attribute(:name, 'Steve Jobs')
    other.update_attribute(:last_name, 'Richert')
    first_version, last_version = other.versions.first, other.versions.last

    @first_version.should_not == first_version
    @last_version.should_not == last_version
  end

  it 'defaults to ordering by iteration when finding through association' do
    iterations = user.versions.map(&:iteration)
    iterations.sort.should == iterations
  end

  it 'returns true for the "initial?" method when the version iteration is 1' do
    version = user.versions.build(:iteration => 1)
    version.iteration.should == 1
    version.should be_initial
  end
  
  it "sreturn the version iteration if it is not a revert" do
    user.version.should == user.versions.last.original_iteration
  end

  it "return the reverted_version if it is a revert" do
    user.revert_to!(1)
    user.versions.last.original_iteration.should == 1
  end

  it "return the original version if it is a double revert" do
    user.revert_to!(2)
    version = user.version
    user.update_attributes(:last_name => 'Gates')
    user.revert_to!(version)
    user.versions.last.original_iteration.should == 2
  end
  
end
