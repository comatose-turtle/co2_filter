require 'spec_helper'

describe Co2Filter::Collaborative do
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

  context '#filter' do
    it 'translates a set of data into recommendation results' do
      result = Co2Filter::Collaborative.filter(current_user: user1, other_users: other_users)
      expect(result).to be_a(Co2Filter::Collaborative::Results)
      expect(result.ids_by_rating).to eq([8, 9, 7, 6])
    end

    context 'measure setting' do
      let(:sample_ratings) {[
          Co2Filter::RatingSet.new(other_users[100]),
          Co2Filter::RatingSet.new(other_users[101]),
          Co2Filter::RatingSet.new(other_users[102]),
          Co2Filter::RatingSet.new(other_users[103]),
          Co2Filter::RatingSet.new(other_users[104]),
          Co2Filter::RatingSet.new(other_users[105]),
          Co2Filter::RatingSet.new(other_users[106]),
          Co2Filter::RatingSet.new(other_users[107])
      ]}

      before(:each) do
        allow(Co2Filter::Collaborative).to receive(:mean_centered_cosine) {
          {
              1 => {coefficient: 0.5, mean: 2.5, ratings: sample_ratings[0]},
              2 => {coefficient: 0.1, mean: 2.5, ratings: sample_ratings[1]},
              3 => {coefficient: 0.75, mean: 2.5, ratings: sample_ratings[2]},
              4 => {coefficient: 1.0, mean: 2.5, ratings: sample_ratings[3]},
              5 => {coefficient: 0.3, mean: 2.5, ratings: sample_ratings[4]},
              6 => {coefficient: 0.9, mean: 2.5, ratings: sample_ratings[5]},
              7 => {coefficient: 0.55, mean: 2.5, ratings: sample_ratings[6]},
              8 => {coefficient: 0, mean: 2.5, ratings: sample_ratings[7]}
          }
        }

        allow(Co2Filter::Collaborative).to receive(:euclidean) {
          {
              1 => {coefficient: 1, mean: 2.5, ratings: sample_ratings[0]},
              2 => {coefficient: 0.5, mean: 2.5, ratings: sample_ratings[1]},
              3 => {coefficient: 0.25, mean: 2.5, ratings: sample_ratings[2]},
              4 => {coefficient: 0.01, mean: 2.5, ratings: sample_ratings[3]},
              5 => {coefficient: 0.33, mean: 2.5, ratings: sample_ratings[4]},
              6 => {coefficient: 0.2, mean: 2.5, ratings: sample_ratings[5]},
              7 => {coefficient: 0.7, mean: 2.5, ratings: sample_ratings[6]},
              8 => {coefficient: 0.5, mean: 2.5, ratings: sample_ratings[7]}
          }
        }
      end

      it 'can accept cosine' do
        result = Co2Filter::Collaborative.filter(current_user: user1, other_users: other_users, measure: :cosine)
        expect(result).to be_a(Co2Filter::Collaborative::Results)
        expect(result.ids_by_rating).to eq([7, 8, 6])
        expect(Co2Filter::Collaborative).not_to have_received(:euclidean)
        expect(Co2Filter::Collaborative).to have_received(:mean_centered_cosine)
      end

      it 'can accept euclidean' do
        result = Co2Filter::Collaborative.filter(current_user: user1, other_users: other_users, measure: :euclidean)
        expect(result).to be_a(Co2Filter::Collaborative::Results)
        expect(result.ids_by_rating).to eq([9, 7, 6, 8])
        expect(Co2Filter::Collaborative).to have_received(:euclidean)
        expect(Co2Filter::Collaborative).not_to have_received(:mean_centered_cosine)
      end

      it 'can accept hybrid' do
        result = Co2Filter::Collaborative.filter(current_user: user1, other_users: other_users, measure: :hybrid)
        expect(result).to be_a(Co2Filter::Collaborative::Results)
        expect(result.ids_by_rating).to eq([9, 7, 6, 8])
        expect(Co2Filter::Collaborative).to have_received(:euclidean)
        expect(Co2Filter::Collaborative).to have_received(:mean_centered_cosine)
      end
    end
  end

  context '#single_cosine' do
    let(:identical_user) {
      {
        1 => 5.0,
        2 => 2.6,
        3 => 3.5,
        4 => 0.0,
        5 => 1.0
      }
    }
    let(:opposite_user) {
      {
        1 => 0.0,
        2 => 2.4,
        3 => 1.5,
        4 => 5.0,
        5 => 4.0
      }
    }
    let(:similar_user) {
      {
        1 => 4.7,
        2 => 2.0,
        3 => 3.0,
        5 => 0.0,
        6 => 1.0
      }
    }
    let(:rando_user) {
      {
        1 => 1.0,
        2 => 4.0,
        3 => 4.7,
        4 => 2.2,
        6 => 1.0
      }
    }
    let(:consistent_user) {
      {
        1 => 5.0,
        2 => 5.0,
        3 => 5.0,
        4 => 5.0,
        5 => 5.0
      }
    }

    def subject(user2)
      Co2Filter::Collaborative.single_cosine(user1, user2)
    end

    it 'returns the original object as ratings' do
      expect(subject(rando_user)[:ratings]).to be(rando_user)
    end

    it 'returns the mean for user2' do
      mean = rando_user.inject(0.0) {|sum, (k,v)| sum + v } / rando_user.size
      expect(subject(rando_user)[:mean]).to eq(mean)
    end

    context 'coefficient' do
      def user_with_irrelevant_ratings(num_ratings)
        user = {1 => 5.0, 4 => 0.0}
        num_ratings.times do |i|
          user[100+i] = rand * 5.0
        end
        user
      end

      it 'returns 1 for an identical user' do
        expect(subject(identical_user)[:coefficient]).to eq(1)
      end

      it 'returns -1 for an exactly opposite user' do
        expect(subject(opposite_user)[:coefficient]).to eq(-1)
      end

      it 'returns 0 for a completely consistent user' do
        expect(subject(consistent_user)[:coefficient]).to eq(0)
      end

      it 'returns near 1 for a similar user' do
        expect(subject(similar_user)[:coefficient]).to be > 0.7
      end

      it 'returns close to 0 for a dissimilar user' do
        expect(subject(rando_user)[:coefficient].abs).to be < 0.2
      end

      it 'returns closer to 0 as users have more items not in common' do
        not_very_active_user = subject(user_with_irrelevant_ratings(0))
        not_very_relevant_user = subject(user_with_irrelevant_ratings(4))
        moderately_irrelevant_user = subject(user_with_irrelevant_ratings(100))
        extremely_irrelevant_user = subject(user_with_irrelevant_ratings(1000))

        expect(not_very_active_user[:coefficient]).to be > not_very_relevant_user[:coefficient]
        expect(not_very_relevant_user[:coefficient]).to be > moderately_irrelevant_user[:coefficient]
        expect(moderately_irrelevant_user[:coefficient]).to be > extremely_irrelevant_user[:coefficient]
        expect(extremely_irrelevant_user[:coefficient]).to be < 0.1
      end
    end
  end

  context '#cosine' do
    def subject(n)
      Co2Filter::Collaborative.mean_centered_cosine(current_user: user1, other_users: other_users, num_nearest: n)
    end

    it 'returns the n nearest (or farthest) users' do
      results = subject(3)
      expect(results.keys).to     include(105)
      expect(results.keys).to     include(106)
      expect(results.keys).to     include(103)
      expect(results.keys).not_to include(107)
    end

    it 'returns users with their coefficients' do
      results = subject(10)
      expect(results[105][:coefficient]).to be > 0.85
      expect(results[106][:coefficient]).to be < -0.85
      expect(results[107][:coefficient]).to eq(0)
    end
  end

  context 'euclidean' do
    let(:user1) {
      user = {}
      10000.times do |i|
        user[i] = (rand * 1.0).round * 5.0
      end
      user
    }

    let(:identical_user) {
      user1.clone
    }
    let(:opposite_user) {
      user1.inject({}) do |user, (item, rating)|
        user[item] = 5.0 - rating
        user
      end
    }
    let(:similar_user) {
      user1.inject({}) do |user, (item, rating)|
        user[item] = rating + (rand - 1*rating/5)
        user
      end
    }
    let(:rando_user) {
      user = {}
      10000.times do |i|
        user[i] = 2.5 + (2*rand - 1)
      end
      user
    }
    let(:consistent_user) {
      user = {}
      10000.times do |i|
        user[i] = 5.0
      end
      user
    }

    let(:other_users) {
      {
        101 => identical_user,
        102 => opposite_user,
        103 => similar_user,
        104 => rando_user,
        105 => consistent_user
      }
    }

    context '#single_euclidean' do
      def subject(user2)
        Co2Filter::Collaborative.single_euclidean(user1, user2, 5.0)
      end

      it 'returns the original object as ratings' do
        expect(subject(rando_user)[:ratings]).to be(rando_user)
      end

      it 'returns the mean for user2' do
        mean = rando_user.inject(0.0) {|sum, (k,v)| sum + v } / rando_user.size
        expect(subject(rando_user)[:mean]).to eq(mean)
      end

      context 'coefficient' do
        def user_with_n_identical_ratings(num_ratings)
          user = {}
          num_ratings.times do |k|
            user[k] = user1[k]
          end
          user
        end

        it 'returns 1 for an identical user' do
          expect(subject(identical_user)[:coefficient]).to eq(1)
        end

        it 'returns very close to 0 for an exactly opposite user' do
          expect(subject(opposite_user)[:coefficient]).to be < 0.01
        end

        it 'does not return 0 for a completely consistent user' do
          expect(subject(consistent_user)[:coefficient]).not_to eq(0)
        end

        it 'returns near 1 for a similar user' do
          expect(subject(similar_user)[:coefficient]).to be > 0.8
        end

        it 'returns close to 0.5 for a random user' do
          expect(subject(rando_user)[:coefficient].abs).to be_within(0.1).of(0.5)
        end

        it 'returns closer to 0 as users have fewer items in common' do
          user_with_1_similarity = subject(user_with_n_identical_ratings(1))
          user_with_a_few_similarities = subject(user_with_n_identical_ratings(5))
          user_with_some_similarities = subject(user_with_n_identical_ratings(25))
          user_with_plenty_similarities = subject(user_with_n_identical_ratings(1000))

          expect(user_with_1_similarity[:coefficient]).to be < 0.05
          expect(user_with_a_few_similarities[:coefficient]).to be > user_with_1_similarity[:coefficient]
          expect(user_with_some_similarities[:coefficient]).to be > user_with_a_few_similarities[:coefficient]
          expect(user_with_plenty_similarities[:coefficient]).to be > user_with_some_similarities[:coefficient]
          expect(user_with_plenty_similarities[:coefficient]).to eq(1)
        end
      end
    end

    context '#euclidean' do
      def subject(n)
        Co2Filter::Collaborative.euclidean(current_user: user1, other_users: other_users, num_nearest: n)
      end

      it 'returns the n nearest (or farthest) users' do
        results = subject(3)
        expect(results.keys).to     include(101)
        expect(results.keys).to     include(103)
        expect(results.keys).not_to include(102)
      end

      it 'returns users with their coefficients' do
        results = subject(10)
        expect(results[101][:coefficient]).to eq(1)
        expect(results[102][:coefficient]).to be < 0.01
        expect(results[103][:coefficient]).to be > 0.8
      end
    end
  end
end
