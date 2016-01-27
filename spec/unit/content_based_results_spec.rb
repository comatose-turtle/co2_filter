require 'spec_helper'

describe Co2Filter::ContentBased::Results do
  before(:each) do
    @item_rankings = nil
  end

  let(:results){Co2Filter::ContentBased::Results.new(@item_rankings)}

end