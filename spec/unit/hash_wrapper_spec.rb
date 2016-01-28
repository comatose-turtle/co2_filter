require 'spec_helper'

describe Co2Filter::HashWrapper do
  before(:each) do
    @data = nil
  end

  let(:results){Co2Filter::HashWrapper.new(@data)}

  context '#keys' do
    it 'returns the keys to the input hash' do
      @data = {
        1 => 1,
        3 => 0,
        10 => 3,
        11 => 2,
        15 => -2
      }
      expect(results.keys.sort).to eq(@data.keys.sort)
    end
  end

  context '#values' do
    it 'returns the values to the input hash' do
      @data = {
        1 => 1,
        3 => 0,
        10 => 3,
        11 => 2,
        15 => -2
      }
      expect(results.values.sort).to eq(@data.values.sort)
    end
  end

  context '[]' do
    before(:each) {
      @data = {
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

  context '#to_hash' do
    it 'returns the input' do
      @data = {
        1 => 1,
        3 => 0,
        10 => 3,
        11 => 2,
        15 => -2
      }
      expect(results.to_hash).to eq(@data)
    end
  end

  context '#each' do
    it 'passes through to the input' do
      @data = {
        1 => 1,
        3 => 0,
        10 => 3,
        11 => 2,
        15 => -2
      }
      results.each do |k, v|
        expect(v).to eq(@data[k])
      end
    end
  end

  context '#merge' do
    it 'passes through to the input' do
      @data = {
        1 => 1,
        3 => 0,
        10 => 3,
        11 => 2,
        15 => -2
      }
      results.merge({
        1 => 1,
        3 => 0,
        10 => 3,
        11 => 2,
        15 => -2
      }) do |k, v1, v2|
        expect(@data[k]).to eq(v1)
      end
    end
  end

  context '#normalize!' do
    it 'reduces all values to an absolute value <= 1' do
      @data = {
        1 => 100,
        2 => -25,
        3 => 0,
        4 => 50,
        5 => 67,
        6 => -40,
        7 => 20,
        8 => 100,
        9 => 95
      }
      data_dup = @data.clone
      results.normalize!
      scale = results[1] / data_dup[1]
      results.each do |key, val|
        expect(val).to be <= 1.0
        expect(val).to be_within(0.001).of(data_dup[key] * scale)
      end
    end

    it 'does nothing if the input is an empty hash' do
      @data = {}
      expect{results.normalize!}.to_not raise_error
    end
  end
end