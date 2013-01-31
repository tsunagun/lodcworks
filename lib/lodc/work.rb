# coding: UTF-8

require './lib/lodc/work/application'
require './lib/lodc/work/dataset'
require './lib/lodc/work/idea'
require './lib/lodc/work/visualization'

module LODChallenge
  class Work
    def self.extract(work_page_uri)
      case work_page_uri.split("").pop(4).join
      when /^a[0-9]{3}/
        LODChallenge::Work::Application.new(work_page_uri)
      when /^d[0-9]{3}/
        LODChallenge::Work::Dataset.new(work_page_uri)
      when /^i[0-9]{3}/
        LODChallenge::Work::Idea.new(work_page_uri)
      when /^v[0-9]{3}/
        LODChallenge::Work::Visualization.new(work_page_uri)
      end
    end

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

    # 作品の作者を取得する
    def extract_creators(parser)
      parser.at_xpath("//tr[th/text()='ご氏名']/td").text.strip.split(/，|、|,　|, |\. /) rescue Array.new
    end

    # 関連作品を取得する
    def extract_related_works(parser)
      related_works = Array.new
      parser.xpath("//tr[th[starts-with(., '関連する')]]//a[text()]/@href").each do |tr|
        work_page_uri = tr.text.strip rescue nil
        year = work_page_uri.slice(/(?!challenge)[0-9]{4}/)
        work_id = work_page_uri.split("=").last
        work_uri = "http://purl.org/net/mdlab/data/lodc/#{@year}/#{work_id}"
        related_works << work_uri
      end
      return related_works
    end
  end
end
