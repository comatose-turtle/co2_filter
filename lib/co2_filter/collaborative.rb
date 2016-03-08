module Co2Filter::Collaborative
  autoload :Results, 'co2_filter/collaborative/results'

  def self.filter(current_user: nil, other_users: nil, measure: :hybrid)
    raise ArgumentError.new("A 'current_user' argument must be provided.") unless current_user
    raise ArgumentError.new("An 'other_users' argument must be provided.") unless other_users

    current_user = Co2Filter::RatingSet.new(current_user) unless current_user.is_a? Co2Filter::RatingSet
    if measure == :euclidean
      processed_users = euclidean(current_user: current_user, other_users: other_users, num_nearest: 30)
    elsif measure == :cosine
      processed_users = mean_centered_cosine(current_user: current_user, other_users: other_users, num_nearest: 30)
    else
      eu = euclidean(current_user: current_user, other_users: other_users, num_nearest: 30)
      co = mean_centered_cosine(current_user: current_user, other_users: other_users, num_nearest: 30)
      processed_users = {}
      eu.each do |user_id, user|
        processed_users[user_id] = user.merge(co[user_id]) do |k, val1, val2|
          k == :coefficient ? (val1 + val2) / 2.0 : val1
        end
      end
    end

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
      item_ratings[item_id] = current_user.mean + rating_influence_total / weight_normal if weight_normal > 0
    end

    Results.new(item_ratings)
  end

  def self.mean_centered_cosine(current_user: nil, other_users: nil, num_nearest: 30)
    raise ArgumentError.new("A 'current_user' argument must be provided.") unless current_user
    raise ArgumentError.new("An 'other_users' argument must be provided.") unless other_users

    processed = other_users.map do |key, user2|
      user2 = Co2Filter::RatingSet.new(user2) unless user2.is_a? Co2Filter::RatingSet
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
    mean1 = user1.length == 0 ? 0 : sum1 / user1.length
    mean2 = user2.length == 0 ? 0 : sum2 / user2.length

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

  def self.euclidean(current_user: nil, other_users: nil, num_nearest: 30, range:0)
    raise ArgumentError.new("A 'current_user' argument must be provided.") unless current_user
    raise ArgumentError.new("An 'other_users' argument must be provided.") unless other_users

    if range == 0
      lowest = nil
      highest = nil
      current_user.each do |k, rating|
        lowest = rating if !lowest || lowest > rating
        highest = rating if !highest || highest < rating
      end
      other_users.each do |k, user|
        user.each do |k, rating|
          lowest = rating if !lowest || lowest > rating
          highest = rating if !highest || highest < rating
        end
      end
      range = highest - lowest
    end
    processed = other_users.map do |key, user2|
      user2 = Co2Filter::RatingSet.new(user2) unless user2.is_a? Co2Filter::RatingSet
      [key, single_euclidean(current_user, user2, range)]
    end
    processed.sort_by do |entry|
      -(entry[1][:coefficient])
    end.take(num_nearest).inject({}) do |hash, (key, value)|
      hash[key] = value
      hash
    end
  end

  def self.single_euclidean(user1, user2, range)
    numerator = 0
    denominator = 0
    intersect = user1.keys & user2.keys
    intersect.each do |item_id|
      numerator += (user1[item_id] - user2[item_id]) ** 2
      denominator += range ** 2
    end
    relevancy_weight = intersect.size < 50.0 ? intersect.size / 50.0 : 1
    coefficient = relevancy_weight * (1 - ((1.0 * numerator / denominator)**(0.5)))
    user2 = Co2Filter::RatingSet.new(user2) unless user2.is_a? Co2Filter::RatingSet
    {
        ratings: user2.to_hash,
        mean: user2.mean,
        coefficient: coefficient
    }
  end
end
