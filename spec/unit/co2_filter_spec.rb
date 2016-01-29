require 'spec_helper'

describe Co2Filter do
  it 'has a version number' do
    expect(Co2Filter::VERSION).not_to be nil
  end

  context '#filter' do
    let(:user1) {
      {
        1 => 5.0,
        2 => 2.6,
        3 => 3.5,
        4 => 0.0,
        5 => 1.0
      }
    }
    let(:other_users) {
      {
        100 => {
          1 => 2.0,
          3 => 3.0,
          4 => 2.0,
          6 => 5.0,
          7 => 5.0,
          8 => 2.0
        },
        101 => {
          1 => 1.0,
          2 => 4.0,
          3 => 4.7,
          4 => 2.2,
          6 => 1.0,
          7 => 5.0,
          8 => 1.0
        },
        102 => {
          2 => 0.0,
          3 => 4.4,
          4 => 3.3,
          5 => 2.2,
          7 => 5.0
        },
        103 => {
          1 => 4.7,
          2 => 2.0,
          3 => 3.0,
          5 => 0.0,
          6 => 1.0,
          7 => 5.0,
          8 => 4.0
        },
        104 => {
          1 => 4.0,
          2 => 3.5,
          3 => 0.0,
          4 => 4.0,
          5 => 1.0,
          7 => 5.0,
          8 => 2.2
        },
        105 => {
          1 => 5.0,
          2 => 2.6,
          3 => 3.5,
          4 => 0.0,
          5 => 1.0,
          7 => 1.0,
          8 => 4.0,
        },
        106 => {
          1 => 0.0,
          2 => 2.4,
          3 => 1.5,
          4 => 5.0,
          5 => 4.0,
          7 => 4.5,
          8 => 1.5
        },
        107 => {
          1 => 5.0,
          2 => 5.0,
          3 => 5.0,
          4 => 5.0,
          5 => 5.0,
          6 => 5.0,
          7 => 5.0,
          8 => 5.0,
          9 => 5.0
        }
      }
    }
    let(:items) {
      {
        0 => {
          2 => 1.0,
          4 => 0.2,
          5 => 0.9,
          6 => 0.5,
          9 => 1.0
        },
        1 => {
          1 => 0.75,
          2 => 0.3,
          4 => 0.1,
          5 => 0.2,
          7 => 0.9
        },
        2 => {
          1 => 0.6,
          2 => 1.0,
          3 => 0.9,
          4 => 0.1,
          5 => 0.05,
          6 => 1.0,
          11 => 1.0,
          12 => 0.4
        },
        3 => {
          5 => 0.4,
          7 => 0.1,
          8 => 0.8,
          9 => 1.0,
          10 => 0.7,
          11 => 0.7
        },
        4 => {
          1 => 0.65,
          3 => 0.2,
          5 => 0.5,
          7 => 0.2,
          9 => 0.4,
          11 => 1.0
        },
        5 => {
          1 => 1.0,
          2 => 1.0,
          3 => 1.0,
          4 => 1.0,
          5 => 1.0,
          6 => 1.0,
          7 => 1.0,
          8 => 1.0,
          9 => 1.0,
          10 => 1.0,
          11 => 1.0,
          12 => 1.0,
          13 => 1.0,
          14 => 1.0
        },
        6 => {
          11 => 1.0,
          12 => 1.0,
          13 => 1.0,
          14 => 1.0
        },
        7 => {
          15 => 1.0,
          2 => 0.7,
          5 => 0.6,
          3 => 0.3
        },
        8 => {
          1 => 1.0,
          2 => 1.0,
          3 => 0.8,
          4 => 0.9
        },
        9 => {
          2 => 0.9,
          4 => 0.9,
          6 => 0.8,
          8 => 0.8,
          10 => 0.9,
          12 => 0.95,
          14 => 0.8
        }
      }
    }

    it 'should call the collaborative filter' do
      allow(Co2Filter::Collaborative).to receive(:filter) {Co2Filter::Collaborative::Results.new({})}
      Co2Filter.filter(current_user: user1, other_users: other_users, items: items)
      expect(Co2Filter::Collaborative).to have_received(:filter)
    end

    it 'should call the content-based filter' do
      allow(Co2Filter::ContentBased).to receive(:filter) {Co2Filter::ContentBased::Results.new({})}
      Co2Filter.filter(current_user: user1, other_users: other_users, items: items)
      expect(Co2Filter::ContentBased).to have_received(:filter)
    end

    it 'should call the ratings_to_profile convertor if no profile was provided' do
      allow(Co2Filter::ContentBased).to receive(:ratings_to_profile) {Co2Filter::ContentBased::Results.new({})}
      Co2Filter.filter(current_user: user1, other_users: other_users, items: items)
      expect(Co2Filter::ContentBased).to have_received(:ratings_to_profile)
    end

    it 'should not call the ratings_to_profile convertor if a user_profile was provided' do
      allow(Co2Filter::ContentBased).to receive(:ratings_to_profile) {Co2Filter::ContentBased::Results.new({})}
      user_profile = Co2Filter::ContentBased::UserProfile.new({1 => 1, 2 => 2})
      Co2Filter.filter(current_user: user1, other_users: other_users, items: items, user_profile: user_profile)
      expect(Co2Filter::ContentBased).not_to have_received(:ratings_to_profile)
    end

    it 'returns a combination of both filtering techniques' do
      allow(Co2Filter::Collaborative).to receive(:filter) {Co2Filter::Collaborative::Results.new({1 => 1, 2 => 3, 3 => 4, 5 => 2, 9 => 1})}
      allow(Co2Filter::ContentBased).to receive(:filter) {Co2Filter::ContentBased::Results.new({1 => 2, 4 => 4, 6 => 2, 7 => 5, 10 => 4})}
      result = Co2Filter.filter(current_user: user1, other_users: other_users, items: items)
      expect(result).to be_a(Co2Filter::Results)
      expect(result.keys.sort).to eq([1, 2, 3, 4, 5, 6, 7, 9, 10])
    end

    it 'double recommendation is a strong recommendation in the result' do
      allow(Co2Filter::Collaborative).to receive(:filter) {Co2Filter::Collaborative::Results.new({1 => 10, 2 => 1, 3 => -4})}
      allow(Co2Filter::ContentBased).to receive(:filter) {Co2Filter::ContentBased::Results.new({1 => 2, 2 => 1, 3 => -1})}
      result = Co2Filter.filter(current_user: user1, other_users: other_users, items: items)
      expect(result[1]).to be > 0.5
      expect(result[1]).to be > result[2]
      expect(result[1]).to be > result[3]
    end

    it 'double disrecommendation is a strong disrecommendation in the result' do
      allow(Co2Filter::Collaborative).to receive(:filter) {Co2Filter::Collaborative::Results.new({1 => -10, 2 => -1, 3 => 4})}
      allow(Co2Filter::ContentBased).to receive(:filter) {Co2Filter::ContentBased::Results.new({1 => -2, 2 => -1, 3 => 1})}
      result = Co2Filter.filter(current_user: user1, other_users: other_users, items: items)
      expect(result[1]).to be < -0.5
      expect(result[1]).to be < result[2]
      expect(result[1]).to be < result[3]
    end

    it 'strong recommendation and weak disrecommendation is a weak recommendation in the result' do
      allow(Co2Filter::Collaborative).to receive(:filter) {Co2Filter::Collaborative::Results.new({1 => 10, 2 => 10, 3 => -4})}
      allow(Co2Filter::ContentBased).to receive(:filter) {Co2Filter::ContentBased::Results.new({1 => -1, 2 => 2, 3 => -1})}
      result = Co2Filter.filter(current_user: user1, other_users: other_users, items: items)
      expect(result[1]).to be > 0
      expect(result[1]).to be < result[2]
      expect(result[1]).to be > result[3]
    end

    it 'strong disrecommendation and weak recommendation is a weak disrecommendation in the result' do
      allow(Co2Filter::Collaborative).to receive(:filter) {Co2Filter::Collaborative::Results.new({1 => -10, 2 => -10, 3 => 4})}
      allow(Co2Filter::ContentBased).to receive(:filter) {Co2Filter::ContentBased::Results.new({1 => 1, 2 => -2, 3 => 1})}
      result = Co2Filter.filter(current_user: user1, other_users: other_users, items: items)
      expect(result[1]).to be < 0
      expect(result[1]).to be > result[2]
      expect(result[1]).to be < result[3]
    end
  end
end
