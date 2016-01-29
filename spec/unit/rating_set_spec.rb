require 'spec_helper'

describe Co2Filter::RatingSet do
  before(:each) do
    @item_ratings = nil
  end

  let(:results){Co2Filter::RatingSet.new(@item_ratings)}

  it 'calculates a #mean' do
    @item_ratings = {
      1 => 1,
      "two" => 2,
      3 => 5,
      6 => 3,
      7 => 3
    }
    expect(results.mean).to eq(2.8)
  end

  it 'recalculates a #mean after changing a value' do
    @item_ratings = {
      1 => 1,
      "two" => 2,
      3 => 5,
      6 => 3,
      7 => 3
    }
    expect(results.mean).to eq(2.8)
    results[6] = 4
    expect(results.mean).to eq(3.0)
  end
end