$: << File.join(__dir__, '..', 'lib', 'yukari')

require 'test/unit'
require 'results'

# Tests spidering: finding ads, next pages,
#   and detecting existing pages.
class TestSpidering < Test::Unit::TestCase
  def test_spider_ad
    results_filename = 'test/data/exclude/first_results_page_20131111.html'
    expected_link = '/s-ad/haymarket/flatshare-houseshare/sydney-city-sunny-room-looking-for-rent/1004749666' # rubocop:disable LineLength
    failure_message = "Can't find an ad from result"

    result_parser = Yukari::ResultParser.new
    result = result_parser.parse_result(results_filename)
    link = result.links.first.link
    assert_equal expected_link, link, failure_message
  end

  def test_spider_next_page
    results_filename = 'test/data/exclude/first_results_page_20131111.html'
    expected_link = '/s-flatshare-houseshare/sydney/page-2/c18294l3003435'
    failure_message = "Can't find the next result page"

    result_parser = Yukari::ResultParser.new
    result = result_parser.parse_result(results_filename)
    next_page_link = result.next_page_link
    assert_equal expected_link, next_page_link, failure_message
  end

  def test_detect_existing_page
    link_string = '/s-ad/haymarket/flatshare-houseshare/sydney-city-sunny-room-looking-for-rent/1004749666'
    failure_message = "Doesn't detect an existing page"
    link = Yukari::Result::Link.new_using_string(link_string)
    refute link.new?, failure_message
  end
end
