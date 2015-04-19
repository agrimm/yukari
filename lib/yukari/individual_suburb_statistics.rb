class Yukari
  # Statistics about a specific suburb
  class IndividualSuburbStatistics
    def initialize(location, ads)
      @location = location
      @ads = ads

      @average = determine_average
      @median = determine_median
    end

    def determine_average
      @ads.map(&:price).inject(:+) / @ads.count
    end

    def determine_median
      @ads.sort_by(&:price)[@ads.count / 2].price
    end

    def row
      [
        @location,
        @ads.count,
        @average,
        @median
      ]
    end
  end
end
