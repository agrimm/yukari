$:.unshift __dir__

# FIXME: Hacky
$:.unshift File.join(__dir__, '..', '..', '..', 'yuzuki', 'lib', 'yuzuki')

require 'ad'
begin
  require 'frequency_evaluator'
rescue LoadError
  raise 'Need to move yuzuki repository to correct location'
end
require 'set'
require 'forwardable'

# This already has a description
class Yukari
  # A search for a suitable flatmate
  class FlatmateSearch
    def initialize(filenames)
      @filenames = filenames

      @frequency_analyzer = create_frequency_analyzer
      @flatmate_evaluations = create_flatmate_evaluations
      @match_report = create_match_report
    end

    def create_frequency_analyzer
      Yuzuki::FrequencyAnalyzer.new_using_configuration
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

    def create_match_report
      MatchReport.new(matching_flatmates)
    end

    def match_report_output
      @match_report.to_s
    end
  end

  # Display information about matching flatmates
  class MatchReport
    def initialize(flatmates)
      @flatmates = flatmates

      @individual_match_reports = create_individual_match_reports
    end

    def create_individual_match_reports
      @flatmates.map(&method(:create_individual_match_report))
    end

    def create_individual_match_report(flatmate)
      IndividualMatchReport.new(flatmate)
    end

    def to_s
      individual_reports = @individual_match_reports.map(&:to_s)
      individual_reports.join("\n")
    end
  end

  # Display information about a single matching flatmate
  class IndividualMatchReport
    extend Forwardable

    def_delegators :@flatmate, :filename, :matching_words

    def initialize(flatmate)
      @flatmate = flatmate
    end

    def cells
      matching_words_portion = matching_words.join(' ')
      [filename, 'has a match based on the words', matching_words_portion]
    end

    def to_s
      cells.join(' ')
    end
  end

  # Evaluation of an individual flatmate ad
  class FlatmateEvaluation
    attr_reader :filename, :matching_words

    def initialize(filename, frequency_analyzer)
      @filename = filename
      @frequency_analyzer = frequency_analyzer

      @ad_parser = create_ad_parser
      @ad = parse_ad

      # This part is still a bit uncertain.
      # I need to experiment a bit.
      @matching_words = find_matching_words
    end

    def create_ad_parser
      Yukari::AdParser.new
    end

    def parse_ad
      # STDERR.puts "Processing #{@filename.inspect}"
      @ad_parser.parse_ad(@filename)
    end

    def find_matching_words
      @ad.words.find_all(&method(:predominantly_japanese?)).uniq
    end

    def matching?
      ! @matching_words.empty?
    end

    IGNORE_WORDS = Set.new(%w{
      Park Rafael Pedro in You do So Min He Go Sun An Man
      Date Take de Milk Kim Fernando Roberto Olga Oh Francisco
      Maria Marie Giovanni Diego Rodrigo Csaba Bobby Ina Ma Jesus
      Marco Antonio Andreas Mariano Viktor
      adam alan alex alex american an and and andrew andy anthony antonio art artist bailey ban bart
      basketball battle ben bill billy bond born boyle
      brazilian buddy campbell charlie chris christian chung clarissa coles colin dale date dave dee
      der designer dick du ever fields figure film
      first ford french gareth gay gear george german gillespie go great guy hall harris hill hockey
      house ii im james jessica jim jimmy jo jon josh
      justin king laura law lee leon list little living lloyd love m marco maria mark martin matt
      matthew max may min mine mitchell model money music
      musician north of olivia park paul peter peters photographer prince producer ready rush ryan
      s sales scientist second service shane short simon
      singh so son sophie south stairs store store sun susan t take taylor the third thomas tim
      tom van vicky video volleyball wendy west white will
      wood writer yo you you young zero
      water motorcycle Korean SO YOU TAKE Water Great
      I Hi Monika
      June In A U No One Me China Fi Shire Scotland Don Non London Uni Note Jen Nintendo Sue
      Ryan She Mango On Fun Miranda Canada Australia Ireland Italy Europe India Mike Home France
      Taiwan Switzerland Asia Ben Nina Are Same Anna Some Natasha NOW Ii Anne Dee Shira
      A ABC ACCESS AIM Access Africa DEAR Dear Emu Era HI Hai IGA MACHINE MAIN MAKE MEN
      Machine Made Main Make NOW No None Now ONE One RUN Roman Scotland Sea Semi TO TOO
      Ten To Too Use a abc abuse access age aim arise aware banana base be bin blues dear
      hike i idea machine made main make men no none now raise sea semi shoe taken ten to
      ton too undo use via
    }.map(&:downcase))
    HARDWIRED_WORDS = Set.new(%w{Japanese Japan}.map(&:downcase))

    def predominantly_japanese?(word)
      downcased_word = word.downcase
      return false if IGNORE_WORDS.include?(downcased_word)
      return true if HARDWIRED_WORDS.include?(downcased_word)
      @frequency_analyzer.predominantly_japanese?(downcased_word)
    end
  end
end
