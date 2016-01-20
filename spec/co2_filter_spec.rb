require 'spec_helper'

describe Co2Filter do
  it 'has a version number' do
    expect(Co2Filter::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(Co2Filter.DoesSomethingUseful).to eq(true)
  end

  it 'returns helpful recommendation results' do
    expect(false).to be_truthy
  end
end
