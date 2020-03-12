class DataUpdateService
  def initialize(params)
    @id = params[:id]
    @ref = params[:ref]
    @code = params[:code]
    @date_from = params[:date_from]
    @date_to = params[:date_to]
  end

  def workers
    update_data(Worker)
  end

  def subdivisions
    update_data(Subdivision)
  end

  def projects
    update_data(Project)
  end

  def cash_flow_items
    update_data(CashFlowItem)
  end

  def transports
    update_data(Transport)
  end

  def prgks
    PrgkUpdateService.call(import_data_prgks)
  end

  private
  def import_data
    ImportDataService.new(id: @id, ref: @ref, code: @code).import_post["success"]
  end

  def import_data_prgks
    ImportDataService.new(date_from: @date_from, date_to: @date_to).import_post["success"]
  end

  def update_data(model)
    TableUpdateService.call(model, import_data)
  end
end
