$:.unshift __dir__

require 'ad_parser'
require 'individual_suburb_statistics'

class Yukari
  # How expensive is each suburb?
  class SuburbStatisticsQuery
    attr_reader :output

    def self.run(filenames)
      ad_parser = AdParser.new
      ads = filenames.map(&ad_parser.method(:parse_ad)).reject { |ad| ad.is_a?(NullAd) || ad.price.zero? }
      suburb_statistics_query = new(ads)
      puts suburb_statistics_query.output
    end

    def initialize(ads)
      @ads = ads

      @ads_grouped_by_location = @ads.group_by(&:location)
      @individual_suburb_statistics = create_individual_suburb_statistics
      @output = determine_output
    end

    def create_individual_suburb_statistics
      @ads_grouped_by_location.map do |location, ads|
        IndividualSuburbStatistics.new(location, ads)
      end
    end

    def determine_output
      lines = @individual_suburb_statistics.map do |individual_suburb_statistics_object|
        individual_suburb_statistics_object.row.join("\t")
      end
      lines.join("\n")
    end
  end
end
