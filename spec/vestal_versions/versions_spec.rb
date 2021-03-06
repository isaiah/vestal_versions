require 'spec_helper'

describe VestalVersions::Versions do
  subject{ User.new }
  let(:times){ {} }
  let(:names){
    ['Steve Richert', 'Stephen Richert', 'Stephen Jobs', 'Steve Jobs']
  }

  before do
    time = names.size.hours.ago

    names.each do |name|
      subject.update_attribute(:name, name)
      subject.tag_version(subject.version.to_s)
      time += 1.hour

      subject.versions.last.update_attribute(:created_at, time)
      times[subject.version] = time
    end
  end

  it 'is searchable between two valid version values' do
    times.keys.each do |iteration|
      times.values.each do |time|
        subject.versions.between(iteration, iteration).should be_a(Array)
        subject.versions.between(iteration, time).should be_a(Array)
        subject.versions.between(time, iteration).should be_a(Array)
        subject.versions.between(time, time).should be_a(Array)
        subject.versions.between(iteration, iteration).should_not be_empty
        subject.versions.between(iteration, time).should_not be_empty
        subject.versions.between(time, iteration).should_not be_empty
        subject.versions.between(time, time).should_not be_empty
      end
    end
  end

  it 'returns an empty array when searching between a valid and an invalid version value' do
    times.each do |iteration, time|
      subject.versions.between(iteration, nil).should == []
      subject.versions.between(time, nil).should == []
      subject.versions.between(nil, iteration).should == []
      subject.versions.between(nil, time).should == []
    end
  end

  it 'returns an empty array when searching between two invalid version values' do
    subject.versions.between(nil, nil).should == []
  end

  it 'is searchable before a valid version value' do
    times.sort.each_with_index do |(iteration, time), i|
      subject.versions.before(iteration).size.should == i
      subject.versions.before(time).size.should == i
    end
  end

  it 'returns an empty array when searching before an invalid version value' do
    subject.versions.before(nil).should == []
  end

  it 'is searchable after a valid version value' do
    times.sort.reverse.each_with_index do |(iteration, time), i|
      subject.versions.after(iteration).size.should == i
      subject.versions.after(time).size.should == i
    end
  end

  it 'returns an empty array when searching after an invalid version value' do
    subject.versions.after(nil).should == []
  end

  it 'is fetchable by version iteration' do
    times.keys.each do |iteration|
      subject.versions.at(iteration).should be_a(VestalVersions::Version)
      subject.versions.at(iteration).iteration.should == iteration
    end
  end

  it 'is fetchable by tag' do
    times.keys.map{|n| [n, n.to_s] }.each do |iteration, tag|
      subject.versions.at(tag).should be_a(VestalVersions::Version)
      subject.versions.at(tag).iteration.should == iteration
    end
  end

  it "is fetchable by the exact time of a version's creation" do
    times.each do |iteration, time|
      subject.versions.at(time).should be_a(VestalVersions::Version)
      subject.versions.at(time).iteration.should == iteration
    end
  end

  it "is fetchable by any time after the model's creation" do
    times.each do |iteration, time|
      subject.versions.at(time + 30.minutes).should be_a(VestalVersions::Version)
      subject.versions.at(time + 30.minutes).iteration.should == iteration
    end
  end

  it "returns nil when fetching a time before the model's creation" do
    creation = times.values.min
    subject.versions.at(creation - 1.second).should be_nil
  end

  it 'is fetchable by an association extension method' do
    subject.versions.at(:first).should be_a(VestalVersions::Version)
    subject.versions.at(:last).should be_a(VestalVersions::Version)
    subject.versions.at(:first).iteration.should == times.keys.min
    subject.versions.at(:last).iteration.should == times.keys.max
  end

  it 'is fetchable by a version object' do
    times.keys.each do |iteration|
      version = subject.versions.at(iteration)

      subject.versions.at(version).should be_a(VestalVersions::Version)
      subject.versions.at(version).iteration.should == iteration
    end
  end

  it 'returns nil when fetching an invalid version value' do
    subject.versions.at(nil).should be_nil
  end

  it 'provides a version iteration for any given numeric version value' do
    times.keys.each do |iteration|
      subject.versions.iteration_at(iteration).should be_a(Fixnum)
      subject.versions.iteration_at(iteration + 0.5).should be_a(Fixnum)
      subject.versions.iteration_at(iteration).should == subject.versions.iteration_at(iteration + 0.5)
    end
  end

  it 'provides a version iteration for a valid tag' do
    times.keys.map{|n| [n, n.to_s] }.each do |iteration, tag|
      subject.versions.iteration_at(tag).should be_a(Fixnum)
      subject.versions.iteration_at(tag).should == iteration
    end
  end

  it 'returns nil when providing a version iteration for an invalid tag' do
    subject.versions.iteration_at('INVALID').should be_nil
  end

  it 'provides a version iteration of a version corresponding to an association extension method' do
    subject.versions.at(:first).should be_a(VestalVersions::Version)
    subject.versions.at(:last).should be_a(VestalVersions::Version)
    subject.versions.iteration_at(:first).should == times.keys.min
    subject.versions.iteration_at(:last).should == times.keys.max
  end

  it 'returns nil when providing a version iteration for an invalid association extension method' do
    subject.versions.iteration_at(:INVALID).should be_nil
  end

  it "provides a version iteration for any time after the model's creation" do
    times.each do |iteration, time|
      subject.versions.iteration_at(time + 30.minutes).should be_a(Fixnum)
      subject.versions.iteration_at(time + 30.minutes).should == iteration
    end
  end

  it "provides a version iteration of 1 for a time before the model's creation" do
    creation = times.values.min
    subject.versions.iteration_at(creation - 1.second).should == 1
  end

  it 'provides a version iteration for a given version object' do
    times.keys.each do |iteration|
      version = subject.versions.at(iteration)

      subject.versions.iteration_at(version).should == iteration
    end
  end

end
