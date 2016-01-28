class Co2Filter::ContentBased::UserProfile < Co2Filter::HashWrapper
  def initialize(data)
    super(data)
    normalize!
  end
end
