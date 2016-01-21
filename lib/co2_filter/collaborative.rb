module Co2Filter::Collaborative
  def self.filter(users)
    sum = users.inject({}) do |sum, user|
      user.each do |id, rating|
        sum[id] ||= 0
        sum[id] += rating
      end
      sum
    end

    Results.new(sum)
  end

  class Results
    def initialize(data)
      @rating_sums =
        data.sort_by do |id, rating_sum|
          -rating_sum
        end if data.is_a?(Hash)
    end

    def ids_by_rating
      @ids_by_rating ||=
        @rating_sums.map do |el|
          el[0]
        end
    end
  end
end
