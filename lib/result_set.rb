##
# Simple class to hold a collection of search result data.
#
class GoogleCustomSearch::ResultSet
  include Kaminari::ConfigurationMethods::ClassMethods
  
  attr_reader :time, :total, :pages, :suggestion, :labels
  attr_internal_accessor :limit_value, :offset_value
  
  alias :total_count :total


  def self.create(xml_hash, offset, per_page)
    self.new(xml_hash['TM'].to_f,
             xml_hash['RES']['M'].to_i,
             parse_results(xml_hash['RES']['R']),
             spelling = xml_hash['SPELLING'] ? spelling['SUGGESTION'] : nil,
             parse_labels(xml_hash),
             offset, per_page)
  end

  def self.create_empty
    self.new(0.0, 0, [], nil, {})
  end

  def self.parse_results(res_r)
    GoogleCustomSearch::Result.parse(res_r)
  end

  def self.parse_labels(xml_hash)
    return {} unless context = xml_hash['Context'] and facets = context['Facet']
    facets.map do |f|
      (fi = f['FacetItem']).is_a?(Array) ? fi : [fi]
    end.inject({}) do |h, facet_item|
      facet_item.each do |element|
        h[element['label']] = element['anchor_text']
      end
      h
    end
  end

  def initialize(time, total, pages, suggestion, labels, offset = 0, limit = 20)
    @time, @total, @pages, @suggestion, @labels = time, total, pages, suggestion, labels
    @_limit_value, @_offset_value = (limit || default_per_page).to_i, offset.to_i
    
    class << self
      include Kaminari::PageScopeMethods
    end
  end
  
end
  
