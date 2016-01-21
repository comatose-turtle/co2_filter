require 'spec_helper'

describe Co2Filter::Collaborative do
  context '#filter' do
    it 'translates a set of data into recommendation results' do
      data = [
        {
          1 => 1,
          2 => 0,
          3 => -1,
          4 => 1,
          5 => 0,
          6 => -1
        },
        {
          2 => 1,
          3 => -1,
          4 => 1,
          6 => 1
        },
        {
          1 => 1,
          3 => -1,
          4 => 1,
          5 => 1
        }
      ]
      result = Co2Filter::Collaborative.filter(data)
      expect(result).to be_a(Co2Filter::Collaborative::Results)
      expect(result.ids_by_rating.first).to eq(4)
      expect(result.ids_by_rating.last).to eq(3)
    end
  end
end
