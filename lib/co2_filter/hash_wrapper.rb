class Co2Filter::HashWrapper
  def initialize(data)
    @data = data
  end

  def keys
    @data.keys
  end

  def values
    @data.values
  end

  def [](key)
    @data[key]
  end

  def []=(key, value)
    @data[key] = value
  end

  def to_hash
    @data
  end

  def each(*args, &block)
    @data.each(*args, &block)
  end

  def merge(*args, &block)
    @data.merge(*args, &block)
  end
end