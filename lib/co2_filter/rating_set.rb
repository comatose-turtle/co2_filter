class Co2Filter::RatingSet < Co2Filter::HashWrapper
  def mean
    @mean ||= 1.0 * @data.values.inject(:+) / @data.size
  end

  def []=(key, val)
    super(key, val)
    @mean = nil
  end
end