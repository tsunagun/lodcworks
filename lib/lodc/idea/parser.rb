# coding: UTF-8
module LODC
  module Idea
    class Parser < LODC::Parser
      def initialize(work_page_uri)
        @title_path = "//tr[th/text()='アイデアの名称']/td"
        @homepage_path = "//tr[th/text()='投稿したアイデア']/td/a/@href"
        @description_path = "//tr[th/text()='アイデアの概略説明']/td"
        @license_path = "//tr[th/text()='アイデアの権利指定']/td//div[@class='title']"
        #@license_path = "//tr[th/text()='ライセンス']/td"
        @creators_path = "//tr[th/text()='ご氏名']/td"
        @related_works_path = "//tr[th[starts-with(., '関連する')]]//a[text()]/@href"
        @uri = work_page_uri
        @parser = Nokogiri::HTML.parse(open(work_page_uri).read)
      end
      def extract_work
        klass = LODC::Idea::Work
        super(klass)
      end
    end
  end
end
