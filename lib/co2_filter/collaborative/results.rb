class Co2Filter::Collaborative::Results
  def initialize(data)
    @rating_sums = data
  end

  def keys
    @rating_sums.keys
  end

  def values
    @rating_sums.values
  end

  def [](key)
    @rating_sums[key]
  end

  def []=(key, value)
    @rating_sums[key] = value
  end

  def ids_by_rating
    @ids_by_rating ||=
      @rating_sums.sort_by do |id, rating_sum|
        -rating_sum
      end.map do |el|
        el[0]
      end
  end
end