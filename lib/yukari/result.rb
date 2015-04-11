require 'fileutils'

class Yukari
  # Information represented by a result page,
  #   plus the ability to download links.
  class Result
    # @return [String]
    attr_reader :next_page_link
    # @return [Array<Yukari::Result::Link>]
    attr_reader :links

    def initialize(link_strings, next_page_link)
      @link_strings = link_strings
      @next_page_link = next_page_link

      @links = create_links
    end

    def create_links
      @link_strings.map(&method(:create_link))
    end

    def create_link(link_string)
      Link.new_using_string(link_string)
    end

    # Playing around with using a bang for something slightly dangerous
    def download_new_ads!
      @links.each(&:download!)
      # @links.each(&:copy!)
    end

    # A link from a Result page
    class Link
      attr_reader :link

      def self.new_using_string(link)
        new(link)
      end

      def initialize(link)
        @link = link

        @id = determine_id

        @output_filename = determine_output_filename
        @absolute_url = determine_absolute_url
        @destination_filename = determine_destination_filename
      end

      def determine_id
        strings = @link.split('/')
        id = strings.last
        fail unless id =~ /^\d+$/
        id
      end

      def determine_output_filename
        "pages/ads/#{@id}.html"
      end

      def determine_absolute_url
        'http://www.gumtree.com.au' + @link
      end

      # FIXME: Code for downloading from the internet,
      #  and for copying from one folder to another ought
      #  not to be in the same folder.

      DESTINATION_FOLDER = 'pages/ads/sydney_flatshare_wanted_20131120/'
      def determine_destination_filename
        File.join(DESTINATION_FOLDER, "#{@id}.html")
      end

      def new?
        !File.exist?(@output_filename)
      end

      def download!
        return unless new?
        # return if @absolute_url.include?('1074556063')
        msg = "downloading #{@absolute_url.inspect} and saving it to #{@output_filename.inspect}"
        STDERR.puts msg
        sleep 1.1
        page = open(@absolute_url, &:read)
        File.open(@output_filename, 'wb') { |file| file.puts(page) }
      end

      def copy!
        return if copied?
        FileUtils.copy(@output_filename, @destination_filename)
      end

      def copied?
        File.exist?(@destination_filename)
      end
    end
  end
end
