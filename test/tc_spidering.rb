$: << File.join(__dir__, '..', 'lib', 'yukari')

require 'test/unit'
require 'results'

# Tests spidering: finding ads, next pages,
#   and detecting existing pages.
class TestSpidering < Test::Unit::TestCase
  def test_spider_ad
    results_filename = 'pages/first_results_page.html'
    expected_link = '/s-ad/kingsgrove/houseshare/room-for-rent-at-kingsgrove-close-to-sydney-cbd/1000320712' # rubocop:disable LineLength
    failure_message = "Can't find an ad from result"

    result_parser = Yukari::ResultParser.new
    result = result_parser.parse_result(results_filename)
    links = result.links
    assert links.include?(expected_link), failure_message
  end

  def test_spider_next_page
    results_filename = 'pages/first_results_page.html'
    expected_link = '/s-shared-accommodation/sydney/page-2/c18294l3003435'
    failure_message = "Can't find the next result page"

    result_parser = Yukari::ResultParser.new
    result = result_parser.parse_result(results_filename)
    next_page_link = result.next_page_link
    assert_equal expected_link, next_page_link, failure_message
  end

  def test_detect_existing_page
    link = '/s-ad/castle-hill/other-shared-accommodation/looking-for-place-to-share-around-castle-hill/1004443184'
    failure_message = "Doesn't detect an existing page"
    result = Yukari::Result.new([], nil)
    refute result.link_is_new?(link), failure_message
  end
end
