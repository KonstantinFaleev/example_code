class TableUpdateService < ApplicationService
  def initialize(table, attributes)
    @table = table
    @attributes = attributes
  end

  def call
    create_or_update_records
  end

  private

  def create_or_update_records
    records_format_array.each do |record_attributes|
      @table.find_or_initialize_by(ref: record_attributes[:ref])
          .update_attributes(record_attributes)
    end
  rescue Exception
    false
  end

  def records_format_array
    AttributesFormatService.call(@table, @attributes, 'key', 'Attributes')
  end
end
