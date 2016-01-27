require 'spec_helper'

describe Co2Filter::RatingSet do
  before(:each) do
    @item_ratings = nil
  end

  let(:results){Co2Filter::RatingSet.new(@item_ratings)}
end