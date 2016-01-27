module Co2Filter::Collaborative
  autoload :Results, 'co2_filter/collaborative/results'

  def self.filter(current_user:, other_users:)
    processed_users = mean_centered_cosine(current_user: current_user, other_users: other_users, num_nearest: 30)
    new_items = []
    processed_users.each do |user_id, user|
      new_items = new_items | (user[:ratings].keys - current_user.keys)
    end

    item_ratings = {}
    new_items.each do |item_id|
      rating_influence_total = 0
      weight_normal = 0
      processed_users.reject do |user_id, user|
        user[:ratings][item_id].nil?
      end.each do |user_id, user|
        rating_influence_total += user[:coefficient] * (user[:ratings][item_id] - user[:mean])
        weight_normal += user[:coefficient].abs
      end
      item_ratings[item_id] = rating_influence_total / weight_normal if weight_normal > 0
    end

    Results.new(item_ratings)
  end

  def self.mean_centered_cosine(current_user:, other_users:, num_nearest:)
    processed = other_users.map do |key, user2|
      [key, single_cosine(current_user, user2)]
    end
    processed.sort_by do |entry|
      -(entry[1][:coefficient].abs)
    end.take(num_nearest).inject({}) do |hash, (key, value)|
      hash[key] = value
      hash
    end
  end

  def self.single_cosine(user1, user2)
    sum1 = 0
    sum2 = 0
    union = user1.keys | user2.keys
    union.each do |key|
      if user1[key]
        sum1 += user1[key]
      end
      if user2[key]
        sum2 += user2[key]
      end
    end
    mean1 = sum1 / user1.length
    mean2 = sum2 / user2.length

    numerator = 0
    denominator1 = 0
    denominator2 = 0
    union.each do |key|
      deviation1 = user1[key] ? user1[key] - mean1 : 0
      deviation2 = user2[key] ? user2[key] - mean2 : 0

      numerator += deviation1 * deviation2
      denominator1 += deviation1**2
      denominator2 += deviation2**2
    end
    {
      ratings: user2,
      mean: mean2,
      coefficient: (denominator1 * denominator2 == 0 ? 0 : numerator / Math.sqrt(denominator1 * denominator2))
    }
  end
end
