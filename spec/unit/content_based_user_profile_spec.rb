require 'spec_helper'

describe Co2Filter::ContentBased::UserProfile do
  before(:each) do
    @attr_rankings = nil
  end

  let(:results){Co2Filter::ContentBased::UserProfile.new(@attr_rankings)}

end