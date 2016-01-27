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
      expect(result.ids_by_rating).to eq([8, 7, 6])
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
end
