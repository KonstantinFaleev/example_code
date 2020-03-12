require 'json'

class CollectJsonsService < ApplicationService
  def initialize(folder)
    @folder = folder
    @result_json = {}
  end

  def call
    json_collection
    @result_json
  end

  private

  def json_collection
    Dir.glob(@folder).select do |file_path|
      json_data = open_json_file(file_path)
      merge_to_result_json(json_data)
    end
  end

  def merge_to_result_json(json_data)
    @result_json.merge!(json_data)
  end

  def open_json_file(file_path)
    file = File.open file_path
    JSON.load file
  end
end
