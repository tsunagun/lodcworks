require 'nokogiri'
require 'open-uri'
require 'linkeddata'

module LODC
  require './lib/rdf/lodc'
  require './lib/lodc/work'
  require './lib/lodc/parser'
  require './lib/lodc/application'
  require './lib/lodc/dataset'
  require './lib/lodc/idea'
  require './lib/lodc/visualization'

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

graph = RDF::Graph.new
namespaces = {
  :rdf => RDF,
  :rdfs => RDF::RDFS,
  :foaf => RDF::FOAF,
  :dc => RDF::DC11,
  :dcterms => RDF::DC,
  :cc => RDF::CC,
  :owl => RDF::OWL,
  :lodc => RDF::LODC
}
LODC.work_page_uris.each do |work_page_uri|
  sleep 1
  work = LODC::Parser.parse(work_page_uri).extract_work
  graph << work.to_rdf
end
puts graph.dump(:rdfxml, :prefixes => namespaces)
