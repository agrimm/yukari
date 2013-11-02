$:.unshift __dir__

# FIXME: Hacky
$:.unshift File.join(__dir__, '..', '..', '..', 'sumisu', 'lib')

require 'ad'
require 'frequency_comparer'
require 'set'

# This already has a description
class Yukari
  # A search for a suitable flatmate
  class FlatmateSearch
    def initialize(filenames)
      @filenames = filenames

      @frequency_analyzer = create_frequency_analyzer
      @flatmate_evaluations = create_flatmate_evaluations
    end

    def create_frequency_analyzer
      australian_frequency_data = FrequencyComparer.australian_frequency_data
      japanese_frequency_data = FrequencyComparer.japanese_frequency_data
      FrequencyAnalyzer.new(australian_frequency_data, japanese_frequency_data)
    end

    def create_flatmate_evaluations
      @filenames.map(&method(:create_flatmate_evaluation))
    end

    def create_flatmate_evaluation(filename)
      FlatmateEvaluation.new(filename, @frequency_analyzer)
    end

    def matching_files
      matching_flatmates.map(&:filename)
    end

    def matching_flatmates
      @flatmate_evaluations.find_all(&:matching?)
    end
  end

  # Evaluation of an individual flatmate ad
  class FlatmateEvaluation
    attr_reader :filename

    def initialize(filename, frequency_analyzer)
      @filename = filename
      @frequency_analyzer = frequency_analyzer

      @ad_parser = create_ad_parser
      @ad = parse_ad

      # This part is still a bit uncertain.
      # I need to experiment a bit.
      @matching_word = find_matching_word
    end

    def create_ad_parser
      Yukari::AdParser.new
    end

    def parse_ad
      # STDERR.puts "Processing #{@filename.inspect}"
      @ad_parser.parse_ad(@filename)
    end

    def find_matching_word
      @ad.words.find(&method(:predominantly_japanese?))
    end

    def matching?
      @matching_word
    end

    IGNORE_WORDS = Set.new(%w{Park Rafael Pedro})
    HARDWIRED_WORDS = Set.new(%w{Japanese})

    def predominantly_japanese?(word)
      return false if IGNORE_WORDS.include?(word)
      return true if HARDWIRED_WORDS.include?(word)
      @frequency_analyzer.predominantly_japanese?(word)
    end
  end

  # Analyze frequency data for this application
  # In particular, try to work out if a word suggets the flatmate
  # may be Japanese-speaking.
  class FrequencyAnalyzer
    def initialize(australian_frequency_data, japanese_frequency_data)
      @australian_frequency_data = australian_frequency_data
      @japanese_frequency_data = japanese_frequency_data
    end

    def predominantly_japanese?(word)
      australian_frequency = @australian_frequency_data.frequency_for(word)
      japanese_frequency = @japanese_frequency_data.frequency_for(word)
      difference = japanese_frequency - australian_frequency
      difference > 10
    end
  end
end
