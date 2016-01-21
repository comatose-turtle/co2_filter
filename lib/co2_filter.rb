module Co2Filter
  def self.DoesSomethingUseful
    true
  end
  autoload :Collaborative, 'co2_filter/collaborative'
  autoload :ContentBased,  'co2_filter/content_based'
end
