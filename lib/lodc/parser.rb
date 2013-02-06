# coding: UTF-8

module LODC
  class Parser
    attr_accessor :parser, :uri
    def self.parse(work_page_uri)
      case work_page_uri.split("").pop(4).join
      when /^a[0-9]{3}/
        LODC::Application::Parser.new(work_page_uri)
      when /^d[0-9]{3}/
        LODC::Dataset::Parser.new(work_page_uri)
      when /^i[0-9]{3}/
        LODC::Idea::Parser.new(work_page_uri)
      when /^v[0-9]{3}/
        LODC::Visualization::Parser.new(work_page_uri)
      end
    end

    # ライセンスのURIを取得する
    def license_to_uri(string)
      licenses = {
        "パブリックドメイン" => "http://creativecommons.org/publicdomain/mark/1.0",
        "表示" => "http://creativecommons.org/licenses/by/3.0",
        "表示—継承" => "http://creativecommons.org/licenses/by-sa/3.0",
        "表示—改変禁止" => "http://creativecommons.org/licenses/by-nd/3.0",
        "表示—非営利" => "http://creativecommons.org/licenses/by-nc/3.0",
        "表示—非営利—継承" => "http://creativecommons.org/licenses/by-nc-sa/3.0",
        "表示—非営利—改変禁止" => "http://creativecommons.org/licenses/by-nc-nd/3.0"
      }
      licenses[string] || string
    end

    def extract_work(klass)
      work = klass.new
      work.year = @uri.slice(/(?!challenge)[0-9]{4}/)
      work_id = @uri.split("=").last
      work.uri = "http://purl.org/net/mdlab/data/lodc/#{work.year}/#{work_id}"
      work.creators = extract_creators
      work.title = extract_title
      work.homepage = extract_homepage
      work.lodc_entry_page = @uri
      work.description = extract_description
      work.related_works = extract_related_works
      work.license = extract_license
      return work
    end

    # --- 作品のタイトル ---
    def extract_title
      normalize_title(@parser.at_xpath(@title_path))
    end

    def normalize_title(title)
      title.text.strip rescue nil
    end

    # --- 作品の公開場所 ---
    def extract_homepage
      normalize_homepage(@parser.at_xpath(@homepage_path))
    end

    def normalize_homepage(homepage)
      homepage.text.strip rescue nil
    end

    # --- 作品の作成者 ---
    def extract_creators
      normalize_creators(@parser.at_xpath(@creators_path))
    end

    def normalize_creators(creators)
      creators.text.strip.split(/，|、|,　|, |,|\. /) rescue Array.new
    end

    # --- 作品の概要 ---
    def extract_description
      normalize_description(@parser.at_xpath(@description_path))
    end

    def normalize_description(description)
      description.text.strip rescue nil
    end

    # --- 関連する作品 ---
    def extract_related_works
      normalize_related_works(@parser.xpath(@related_works_path))
    end

    def normalize_related_works(related_works)
      related_works.map do |tr|
        work_page_uri = tr.text.strip rescue nil
        year = work_page_uri.slice(/(?!challenge)[0-9]{4}/)
        work_id = work_page_uri.split("=").last
        "http://purl.org/net/mdlab/data/lodc/#{year}/#{work_id}"
      end
    end

    # --- 作品のライセンス ---
    def extract_license
      normalize_license(@parser.xpath(@license_path))
    end

    def normalize_license(license)
      license = license.text.strip rescue nil
      #another_license = parser.at_xpath("//tr[th/text()='ライセンス']/td").text.strip rescue ""
      #license = another_license unless another_license == ""
      license_to_uri(license)
    end
  end
end
