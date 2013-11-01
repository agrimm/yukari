$:.unshift __dir__

require 'ad'

# This already has a description
class Yukari
  # A search for a suitable flatmate
  class FlatmateSearch
    def initialize(filenames)
      @filenames = filenames

      @flatmate_evaluations = create_flatmate_evaluations
    end

    def create_flatmate_evaluations
      @filenames.map(&method(:create_flatmate_evaluation))
    end

    def create_flatmate_evaluation(filename)
      FlatmateEvaluation.new(filename)
    end

    def matching_files
      @flatmate_evaluations.map(&:filename)
    end
  end

  # Evaluation of an individual flatmate ad
  class FlatmateEvaluation
    attr_reader :filename

    def initialize(filename)
      @filename = filename

      @ad_parser = create_ad_parser
      @ad = parse_ad
    end

    def create_ad_parser
      Yukari::AdParser.new
    end

    def parse_ad
      # STDERR.puts "Processing #{@filename.inspect}"
      @ad_parser.parse_ad(@filename)
    end
  end
end
