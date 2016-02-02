module Co2Filter
  def self.filter(current_user: , other_users: , items: nil, user_profile: nil, content_based_results: nil)
    raise ArgumentError.new("An 'items' or 'content_based_results' argument must be provided.") unless items || content_based_results
    collab = Collaborative.filter(current_user: current_user, other_users: other_users)
    
    if content_based_results && content_based_results.is_a?(Results)
      content = content_based_results
    elsif user_profile.is_a? ContentBased::UserProfile
      content = ContentBased.filter(user: user_profile, items: items)
    else
      content = ContentBased.filter(user: current_user, items: items)
    end

    hybrid = collab.merge(content) do |k, val1, val2|
      (val1 + val2) / 2.0
    end
    Results.new(hybrid)
  end

  def self.content_boosted_collaborative_filter(current_user:, other_users:, items:)
    content_boosted_users = {}
    other_users.each do |user_id, ratings|
      content_boosted_users[user_id] = ratings.merge(ContentBased.filter(user: ratings, items: items))
    end
    results = Collaborative.filter(current_user: current_user, other_users: content_boosted_users)
    Results.new(results)
  end

  autoload :VERSION, 'co2_filter/version'
  autoload :Collaborative, 'co2_filter/collaborative'
  autoload :ContentBased,  'co2_filter/content_based'
  autoload :Results, 'co2_filter/results'
  autoload :RatingSet,  'co2_filter/rating_set'
  autoload :HashWrapper,  'co2_filter/hash_Wrapper'
end
