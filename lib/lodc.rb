# coding: UTF-8

require 'nokogiri'
require 'open-uri'
require 'linkeddata'
require './lib/lodc/work'
require './lib/rdf/lodc'

module LODChallenge
  def self.work_page_uris
    work_page_uris = Array.new
    list_uris = [
      "http://lod.sfc.keio.ac.jp/challenge2011/show_list.php",
      "http://lod.sfc.keio.ac.jp/challenge2012/dataset.html",
      "http://lod.sfc.keio.ac.jp/challenge2012/idea.html",
      "http://lod.sfc.keio.ac.jp/challenge2012/application.html",
      "http://lod.sfc.keio.ac.jp/challenge2012/visualization.html"
    ]
    list_uris.each do |list_uri|
      parser = Nokogiri::HTML.parse(open(list_uri).read)
      parser.xpath("//tr//@href").each do |href|
        work_page_uris << URI.parse(list_uri).merge(href.text).to_s
      end
    end
    return work_page_uris
  end
end

LODChallenge.work_page_uris.each do |work_page_uri|
  sleep 1
  work = LODChallenge::Work.extract(work_page_uri)
  accept_license = {
    "パブリックドメイン" => "http://creativecommons.org/publicdomain/mark/1.0",
    "表示" => "http://creativecommons.org/licenses/by/3.0",
    "表示—継承" => "http://creativecommons.org/licenses/by-sa/3.0",
    "表示—改変禁止" => "http://creativecommons.org/licenses/by-nd/3.0",
    "表示—非営利" => "http://creativecommons.org/licenses/by-nc/3.0",
    "表示—非営利—継承" => "http://creativecommons.org/licenses/by-nc-sa/3.0",
    "表示—非営利—改変禁止" => "http://creativecommons.org/licenses/by-nc-nd/3.0"
  }
  license = work.license rescue nil
  puts work.to_rdf if accept_license.values.include?(license)
end
