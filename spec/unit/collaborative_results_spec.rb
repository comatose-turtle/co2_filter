require 'spec_helper'

describe Co2Filter::Collaborative::Results do
  before(:each) do
    @rating_sums = nil
  end

  let(:results){Co2Filter::Collaborative::Results.new(@rating_sums)}

  context '#keys' do
    it 'returns the keys to the input hash' do
      @rating_sums = {
        1 => 1,
        3 => 0,
        10 => 3,
        11 => 2,
        15 => -2
      }
      expect(results.keys.sort).to eq(@rating_sums.keys.sort)
    end
  end

  context '#values' do
    it 'returns the values to the input hash' do
      @rating_sums = {
        1 => 1,
        3 => 0,
        10 => 3,
        11 => 2,
        15 => -2
      }
      expect(results.values.sort).to eq(@rating_sums.values.sort)
    end
  end

  context '[]' do
    before(:each) {
      @rating_sums = {
        1 => 1,
        3 => 0,
        10 => 3,
        11 => 2,
        15 => -2
      }
    }

    it 'can be get' do
      expect(results[10]).to eq(3)
    end

    it 'can be set' do
      expect(results[11]).to eq(2)
      results[11] = 50
      expect(results[11]).to eq(50)
    end
  end

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