$:.unshift __dir__

require 'ad_parser'
require 'individual_suburb_statistics'

class Yukari
  # Can words in the ad indicate how expensive the ad is?
  class WordStatisticsQuery
    attr_reader :output

    def self.run(filenames)
      ad_parser = AdParser.new
      ads = filenames.map(&ad_parser.method(:parse_ad)).reject { |ad| ad.is_a?(NullAd) || ad.price.zero? }
      word_statistics_query = new(ads)
      puts word_statistics_query.output
    end

    def initialize(ads)
      @ads = ads

      @ads_grouped_by_words = group_ads_by_words
      @individual_suburb_statistics = create_individual_suburb_statistics
      @output = determine_output
    end

    def group_ads_by_words
      @ads.each_with_object({}) do |ad, result|
        for word in ad.words.uniq
          result[word] ||= []
          result[word] << ad
        end
      end
    end

    def create_individual_suburb_statistics
      sorted_groups = @ads_grouped_by_words.sort_by do |word, ads|
        [-ads.count, word]
      end
      sorted_groups.map do |word, ads|
        IndividualSuburbStatistics.new(word, ads)
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
