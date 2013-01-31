# coding: UTF-8

module LODChallenge

  class Work

    class Dataset < Work
      attr_accessor :title, :creators, :uri, :homepage, :lodc_entry_page, :description, :related_works, :license, :year
      def initialize(work_page_uri)
        parser = Nokogiri::HTML.parse(open(work_page_uri).read)
        @year = work_page_uri.slice(/(?!challenge)[0-9]{4}/)
        work_id = work_page_uri.split("=").last
        @uri = "http://purl.org/net/mdlab/data/lodc/#{@year}/#{work_id}"
        @creators = extract_creators(parser)
        @title = extract_title(parser)
        @homepage = extract_homepage(parser)
        @lodc_entry_page = work_page_uri
        @description = extract_description(parser)
        @related_works = extract_related_works(parser)
        @license = extract_license(parser)
      end


      # 作品の名称を取得する
      def extract_title(parser)
        parser.at_xpath("//tr[th/text()='データセットの名称']/td").text.strip rescue nil
      end

      # 作品にアクセスするためのURIを取得する
      #   データセットやデモ用アプリケーション，アップロードしたアイデアのファイルなどにアクセスするためのURI
      def extract_homepage(parser)
        parser.at_xpath("//tr[th/text()='データセットのURL']/td/a/@href").text.strip rescue nil
      end

      # 作品の概要を取得する
      def extract_description(parser)
        parser.at_xpath("//tr[th/text()='データセットの概略説明']/td").text.strip rescue nil
      end

      # 作品の権利指定を取得する
      def extract_license(parser)
        license = parser.at_xpath("//tr[th/text()='データセットの権利指定']/td//div[@class='title']").text.strip rescue nil
        another_license = parser.at_xpath("//tr[th/text()='ライセンス']/td").text.strip rescue ""
        license = another_license unless another_license == ""
        license_to_uri(license)
      end

      # 作品情報をRDF化する
      def to_rdf(format = :ntriples)
        graph = RDF::Graph.new
        graph << RDF::Statement.new(RDF::URI.new(@uri), RDF.type, RDF::LODC.Dataset)
        graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC.available, RDF::Literal.new(@year)) unless @year.nil?
        @creators.each do |creator|
          graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC.creator, RDF::Literal.new(creator)) unless creator.nil?
        end
        graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC.title, RDF::Literal.new(@title)) unless @title.nil?
        graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC.description, RDF::Literal.new(@description)) unless @description.nil?
        graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::FOAF.homepage, RDF::URI.new(@homepage)) unless @homepage.nil?
        graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::RDFS.seeAlso, RDF::URI.new(@lodc_entry_page)) unless @lodc_entry_page.nil?
        @related_works.each do |related_work|
          graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC.relation, RDF::URI.new(related_work)) unless related_work.nil?
        end
        if @license =~ /^http/
          graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC.license, RDF::URI.new(@license)) unless @license.nil?
        else
          graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC.license, RDF::Literal.new(@license)) unless @license.nil?
        end
        graph.dump(:ntriples)
      end
    end

  end

end
