class Co2Filter::Results < Co2Filter::HashWrapper
  def ids_by_rating
    @ids_by_rating ||=
      @data.sort_by do |id, item_ranking|
        -item_ranking
      end.map do |el|
        el[0]
      end
  end
end