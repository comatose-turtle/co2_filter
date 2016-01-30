require 'spec_helper'

describe Co2Filter::ContentBased::UserProfile do
  before(:each) do
    @attr_rankings = nil
  end

  let(:results){Co2Filter::ContentBased::UserProfile.new(@attr_rankings, @mean)}

  it 'has a constructor that accepts a mean' do
    @attr_rankings = {
      1 => -1,
      2 => 0,
      3 => 1,
      4 => 0.5,
      5 => -0.5
    }
    @mean = 3.0
    expect(results.mean).to eq(@mean)
  end
end