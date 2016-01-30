class Co2Filter::ContentBased::UserProfile < Co2Filter::HashWrapper
  attr_accessor :mean

  def initialize(data, mean)
    super(data)
    @mean = mean
  end
end
