module Co2Filter::ContentBased
  autoload :Results, 'co2_filter/content_based/results'
  autoload :UserProfile, 'co2_filter/content_based/user_profile'

  def self.filter(user:, items:)
    if(user.is_a?(UserProfile))
      user_profile = user
      new_items = items
    elsif(user.is_a?(Hash) || user.is_a?(Co2Filter::RatingSet))
      user = Co2Filter::RatingSet.new(user) if user.is_a?(Hash)
      user_profile = ratings_to_profile(user_ratings: user, items: items)
      new_items = items.reject{|item_id, v| user[item_id]}
    end
    results = new_items.inject({}) do |hash, (item_id, item)|
      strength_normalizer = 0
      hash[item_id] = 0
      item.each do |attr_id, strength|
        hash[item_id] += user_profile[attr_id].to_f * strength
        strength_normalizer += strength.abs if user_profile[attr_id]
      end
      hash[item_id] /= strength_normalizer if strength_normalizer != 0
      hash
    end
    Results.new(results)
  end

  def self.ratings_to_profile(user_ratings:, items:)
    throw ArgumentError.new("user_ratings must be of type Co2Filter::RatingSet") unless user_ratings.is_a? Co2Filter::RatingSet
    user_prefs = {}
    strength_normalizers = {}
    user_ratings.each do |item_id, score|
      deviation = score - user_ratings.mean

      items[item_id].each do |attr_id, strength|
        user_prefs[attr_id] ||= 0
        user_prefs[attr_id] += strength * deviation
        strength_normalizers[attr_id] ||= 0
        strength_normalizers[attr_id] += strength.abs
      end
    end

    user_prefs.each do |attr_id, score|
      user_prefs[attr_id] /= strength_normalizers[attr_id].to_f
    end

    UserProfile.new(user_prefs)
  end
end
