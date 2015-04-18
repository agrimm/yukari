$: << File.join(__dir__, '..', 'lib', 'yukari')

require 'test/unit'
require 'flatmate_search'

# Test for flatmate search.
class TestFlatmateSearch < Test::Unit::TestCase
  def create_flatmate_search
    ad_filename = 'test/data/exclude/ads/page_1_20131111.html'
    filenames = [ad_filename]
    Yukari::FlatmateSearch.new(filenames)
  end

  def test_flatmate_search
    flatmate_search = create_flatmate_search
    failure_message = 'Something does not work'
    assert_equal 1, flatmate_search.matching_files.length, failure_message
  end

  def test_flatmate_search_report
    flatmate_search = create_flatmate_search
    assert_nothing_raised do
      flatmate_search.match_report_output
    end
  end

  def test_lowercase_hardwired_word_detected
    ad_filename = 'test/data/exclude/ads/page_1_20150321.html'
    skip 'File not found' unless File.exist?(ad_filename)
    filenames = [ad_filename]
    flatmate_search = Yukari::FlatmateSearch.new(filenames)

    failure_message = "A lower case hardwired word isn't detected"
    assert_equal 1, flatmate_search.matching_files.length, failure_message
  end
end
