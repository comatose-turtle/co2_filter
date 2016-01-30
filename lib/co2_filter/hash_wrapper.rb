class Co2Filter::HashWrapper
  def initialize(data)
    @data = data
  end

  def method_missing(method, *args, &block)
    if [:keys, :values, :length, :size, :"[]", :"[]=", :each, :merge]
      @data.send(method, *args, &block)
    else
      super(method, *args, &block)
    end
  end

  def to_hash
    @data
  end
end