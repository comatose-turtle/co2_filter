module Co2Filter
  def self.filter(current_user: , other_users: , items: , user_profile: nil)
    collab = Collaborative.filter(current_user: current_user, other_users: other_users)
    if user_profile.is_a? ContentBased::UserProfile
      content = ContentBased.filter(user: user_profile, items: items)
    else
      content = ContentBased.filter(user: current_user, items: items)
    end
    hybrid = collab.merge(content) do |k, val1, val2|
      val1 * val2
    end
    Results.new(hybrid)
  end
  autoload :VERSION, 'co2_filter/version'
  autoload :Collaborative, 'co2_filter/collaborative'
  autoload :ContentBased,  'co2_filter/content_based'
  autoload :Results, 'co2_filter/results'
  autoload :RatingSet,  'co2_filter/rating_set'
  autoload :HashWrapper,  'co2_filter/hash_Wrapper'
end
