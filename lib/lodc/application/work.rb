module LODC
  module Application
    class Work < LODC::Work
      def to_rdf
        type = RDF::LODC.Application
        super(type)
      end
    end
  end
end
