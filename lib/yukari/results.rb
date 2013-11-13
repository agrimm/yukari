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

  # Information represented by a result page,
  #   plus the ability to download links.
  class Result
    attr_reader :links, :next_page_link

    def initialize(links, next_page_link)
      @links = links
      @next_page_link = next_page_link
    end

    # Playing around with using a bang for something slightly dangerous
    def download_new_ads!
      @links.each do |link|
        download_link!(link)
      end
    end

    def download_link!(link)
      return unless link_is_new?(link)
      id = parse_id_from_link(link)
      filename = determine_filename_from_id(id)
      url = 'http://www.gumtree.com.au' + link
      msg = "downloading #{url.inspect} and saving it to #{filename.inspect}"
      STDERR.puts msg
      sleep 1.1
      page = open(url, &:read)
      File.open(filename, 'wb') { |file| file.puts(page) }
    end

    def link_is_new?(link)
      id = parse_id_from_link(link)
      !id_already_saved?(id)
    end

    def id_already_saved?(id)
      filename = determine_filename_from_id(id)
      File.exist?(filename)
    end

    def parse_id_from_link(link)
      strings = link.split('/')
      id = strings.last
      fail unless id =~ /^\d+$/
      id
    end

    def determine_filename_from_id(id)
      "pages/ads/#{id}.html"
    end
  end
end
