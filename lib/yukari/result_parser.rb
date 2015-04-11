$:.unshift __dir__

require 'result'
require 'nokogiri'

class Yukari
  # Given a results page, parse links to an ad,
  #   and to the next results page.
  class ResultParser
    def parse_result(result_filename)
      document = Nokogiri::HTML(File.read(result_filename))
      links = parse_links(document)
      fail if links.empty?
      next_page_link = parse_next_page_link(document)
      Result.new(links, next_page_link)
    end

    def parse_links(document)
      h3_xpath = './/h3[contains(@class, "rs-ad-title h-elips")]'
      h3_nodes = document.xpath(h3_xpath)
      link_nodes = h3_nodes.map { |node| node.xpath('a').first }
      link_nodes.map { |node| node['href'] }
    end

    def parse_next_page_link(document)
      next_page_link_xpath = './/a[contains(@title, "Next")]'
      next_page_link_node = document.xpath(next_page_link_xpath).first
      next_page_link_node && next_page_link_node['href']
    end
  end
end
