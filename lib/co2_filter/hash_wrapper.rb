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

  def normalize!
    return if @data.empty?

    sorted_vals = @data.values.sort
    max_abs_val = [sorted_vals.first.abs, sorted_vals.last.abs].max

    @data.keys.each do |key|
      @data[key] = 1.0 * @data[key] / max_abs_val
    end
  end
end