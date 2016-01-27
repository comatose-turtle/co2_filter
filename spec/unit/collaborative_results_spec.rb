require 'spec_helper'

describe Co2Filter::Collaborative::Results do
  before(:each) do
    @rating_sums = nil
  end

  let(:results){Co2Filter::Collaborative::Results.new(@rating_sums)}

end