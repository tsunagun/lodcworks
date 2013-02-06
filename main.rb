# coding: UTF-8
require './lib/lodc'

def accept?(work)
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
  accept_license.values.include?(license)
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
  graph << work.to_rdf if accept?(work)
end
puts graph.dump(:rdfxml, :prefixes => namespaces)
