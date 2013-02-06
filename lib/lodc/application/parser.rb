# coding: UTF-8
module LODC
  module Application
    class Parser < LODC::Parser
      def initialize(work_page_uri)
        @title_path = "//tr[th/text()='アプリケーションの名称']/td"
        @homepage_path = "//tr[th/text()='アプリケーションのURL']/td/a/@href"
        @description_path = "//tr[th/text()='アプリケーションの概略説明']/td"
        @license_path = "//tr[th/text()='アプリケーションの権利指定']/td//div[@class='title']"
        #@license_path = "//tr[th/text()='ライセンス']/td"
        @creators_path = "//tr[th/text()='ご氏名']/td"
        @related_works_path = "//tr[th[starts-with(., '関連する')]]//a[text()]/@href"
        @uri = work_page_uri
        @parser = Nokogiri::HTML.parse(open(work_page_uri).read)
      end
      def extract_work
        klass = LODC::Application::Work
        super(klass)
      end
    end
  end
end
