module LODC
  class Work
    attr_accessor :type, :uri, :lodc_entry_page, :year, :title, :homepage, :description, :license # String
    attr_accessor :creators, :related_works # Array
    def initialize
      @creators = Array.new
      @related_works = Array.new
    end

    def serialize(format=:ntriples)
      self.to_rdf.dump(format)
    end

    def to_rdf(type = RDF::LODC.Work)
      graph = RDF::Graph.new
      work_uri = RDF::URI.new(@uri)
      graph << [work_uri, RDF.type, type]
      graph << RDF::Statement.new(work_uri, RDF::DC.available, RDF::Literal.new(@year)) unless @year.nil?
      @creators.each do |creator|
        graph << RDF::Statement.new(work_uri, RDF::DC.creator, RDF::Literal.new(creator)) unless creator.nil?
      end
      graph << RDF::Statement.new(work_uri, RDF::DC.title, RDF::Literal.new(@title)) unless @title.nil?
      graph << RDF::Statement.new(work_uri, RDF::DC.description, RDF::Literal.new(@description)) unless @description.nil?
      graph << RDF::Statement.new(work_uri, RDF::FOAF.homepage, RDF::URI.new(@homepage)) unless @homepage.nil?
      graph << RDF::Statement.new(work_uri, RDF::RDFS.seeAlso, RDF::URI.new(@lodc_entry_page)) unless @lodc_entry_page.nil?
      @related_works.each do |related_work|
        graph << RDF::Statement.new(work_uri, RDF::DC.relation, RDF::URI.new(related_work)) unless related_work.nil?
      end
      if @license =~ /^http/
        graph << RDF::Statement.new(work_uri, RDF::DC.license, RDF::URI.new(@license)) unless @license.nil?
      else
        graph << RDF::Statement.new(work_uri, RDF::DC.license, RDF::Literal.new(@license)) unless @license.nil?
      end
      graph
    end
  end
end
