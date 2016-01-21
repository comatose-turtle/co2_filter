require 'spec_helper'

describe Co2Filter::Collaborative::Results do
  before(:each) do
    @rating_sums = nil
  end

  let(:results){Co2Filter::Collaborative::Results.new(@rating_sums)}

  context '#ids_by_rating' do
    it 'exists' do
      expect(results.respond_to?(:ids_by_rating)).to be_truthy
    end

    it 'returns the sorted ids from the input' do
      @rating_sums = {
        1 => 1,
        3 => 0,
        10 => 3,
        11 => 2,
        15 => -2
      }
      expect(results.ids_by_rating).to eq([10, 11, 1, 3, 15])
    end

    it 'can handle floats' do
      @rating_sums = {
        3 => 0.1,
        4 => 0.4,
        100 => 1.3,
        23 => -1.2,
        2 => -0.2
      }
      expect(results.ids_by_rating).to eq([100, 4, 3, 2, 23])
    end
  end
end