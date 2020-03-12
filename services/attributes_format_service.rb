class AttributesFormatService < ApplicationService
  def initialize(table, attributes, attributes_type, key = '')
    # attributes_type ['key', 'array']
    # if type = 'key' need to define key parameter
    @table = table
    @table_structure = table_structure
    @attributes = attributes
    @attributes_type = attributes_type
    @records_array = []
    @key = key
  end

  def call
    format_records
    @records_array
  end

  private

  def format_records
    @attributes.each { |record| format_record_attributes(record) }
  end

  def format_record_attributes(record)
    format_attributes = {}
    attributes_array(record).each do |attribute|
      format_attributes.merge!(record_attribute(attribute))
    end
    @records_array.push format_attributes
  end

  def tables_library
    folder = "#{Rails.root}/lib/tables_columns_rules/*.json"
    CollectJsonsService.call(folder)
  end

  def table_structure
    tables_library["#{@table}"]
  end

  def record_attribute(attribute)
    reference = table_reference(attribute)
    value = attribute_value(attribute)
    reference ? {"#{reference}": "#{value}"} : {}
  end

  def table_reference(column)
    @table_structure[column['code']]
  end

  def attribute_value(attribute)
    attribute['value'] === 'null' ? nil : attribute['value']
  end

  def attributes_array(record)
    case @attributes_type
    when 'key'
      record["#{@key}"]
    when 'array'
      record
    else
      []
    end
  end
end
