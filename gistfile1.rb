# coding: UTF-8

require 'uri'
require 'open-uri'
require 'linkeddata'
require 'nokogiri'

class Work
	attr_accessor :title, :creators, :uri, :another_uri, :description, :related_works, :license, :type
	def initialize
		@creators = Array.new
		@related_works = Array.new
	end

	def self.extract(page_uri)
		parser = Nokogiri::HTML.parse(open(page_uri).read)
		work = Work.new
		work.uri = page_uri
		case page_uri.split("").pop(4).join
		when /^a[0-9]{3}/
			work.type = "アプリケーション"
		when /^d[0-9]{3}/
			work.type = "データセット"
		when /^i[0-9]{3}/
			work.type = "アイデア"
		end
		parser.at_xpath("//tr[th/text()='ご氏名']/td").text.strip.split(/，|、|,　|, |\. /).each do |creator|
			work.creators << creator
		end
		work.title = parser.at_xpath("//tr[th/text()='#{work.type}の名称']/td").text.strip rescue nil
		work.another_uri = parser.at_xpath("//tr[th/text()='#{work.type}のURL']/td/a/@href").text.strip rescue nil
		work.description = parser.at_xpath("//tr[th/text()='#{work.type}の概略説明']/td").text.strip rescue nil
		work.license = license_to_uri(parser.at_xpath("//tr[th/text()='#{work.type}の権利指定']/td//div[@class='title']").text.strip) rescue nil
		another_license = parser.at_xpath("//tr[th/text()='ライセンス']/td").text.strip rescue ""
		work.license = another_license unless another_license == ""
		parser.xpath("//tr[th[starts-with(., '関連する')]]//a[text()]/@href").each do |tr|
			work.related_works << tr.text.strip rescue next
		end
		if work.type == "アイデア"
			work.another_uri = parser.at_xpath("//tr[th/text()='投稿したアイデア']//@href").text.strip rescue nil
		end
		return work
	end

	def to_rdf
		graph = RDF::Graph.new
		@creators.each do |creator|
			graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC11.creator, RDF::Literal.new(creator)) unless creator.nil?
		end
		graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC11.title, RDF::Literal.new(@title)) unless @title.nil?
		graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC11.description, RDF::Literal.new(@description)) unless @description.nil?
		graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::RDFS.seeAlso, RDF::URI.new(@another_uri)) unless @another_uri.nil?
		@related_works.each do |related_work|
			graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::RDFS.seeAlso, RDF::URI.new(related_work)) unless related_work.nil?
		end
		if @license =~ /^http/
			graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC11.rights, RDF::URI.new(@license)) unless @license.nil?
		else
			graph << RDF::Statement.new(RDF::URI.new(@uri), RDF::DC11.rights, RDF::Literal.new(@license)) unless @license.nil?
		end
		graph.dump(:ntriples)
	end
end

def license_to_uri(string)
	licenses = {
		"パブリックドメイン" => "http://creativecommons.org/licenses/publicdomain/3.0/",
		"表示" => "http://creativecommons.org/licenses/by/3.0",
		"表示—継承" => "http://creativecommons.org/licenses/by-sa/3.0",
		"表示—改変禁止" => "http://creativecommons.org/licenses/by-nd/3.0",
		"表示—非営利" => "http://creativecommons.org/licenses/by-nc/3.0",
		"表示—非営利—継承" => "http://creativecommons.org/licenses/by-nc-sa/3.0",
		"表示—非営利—改変禁止" => "http://creativecommons.org/licenses/by-nc-nd/3.0"
	}
	licenses[string] || string
end

list_uri = "http://lod.sfc.keio.ac.jp/challenge2011/show_list.php"
parser = Nokogiri::HTML.parse(open(list_uri).read)
parser.xpath("//table[@id='entry-list']//@href").each do |href|
	uri = URI.parse(list_uri).merge(href.text).to_s
	sleep 1
	work = Work.extract(uri)
	puts work.to_rdf
end
