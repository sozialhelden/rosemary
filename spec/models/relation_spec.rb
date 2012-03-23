require 'spec_helper'

describe 'Rosemary::Relation' do

  subject do
    Rosemary::Relation.new(:id         => "123",
                                :lat        => "52.2",
                                :lon        => "13.4",
                                :changeset  => "12",
                                :user       => "fred",
                                :uid        => "123",
                                :visible    => true,
                                :timestamp  => "2005-07-30T14:27:12+01:00",
                                :member     => [
                                  {"type"=>"relation", "ref"=>"1628007", "role"=>"outer"},
                                  {"type"=>"way", "ref"=>"50197015", "role"=>""}
                                ])
  end

  it { should be_valid }

  it "should have members" do
    subject.members.size.should eql 2
  end

end