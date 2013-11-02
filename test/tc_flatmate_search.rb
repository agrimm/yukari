$: << File.join(__dir__, '..', 'lib', 'yukari')

require 'test/unit'
require 'flatmate_search'

# Test for flatmate search.
class TestFlatmateSearch < Test::Unit::TestCase
  def create_flatmate_search
    ad_filename = 'test/data/exclude/ads/page_1.html'
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
end
