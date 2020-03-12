class PrgkValidateService < ApplicationService
  def initialize(prgk_attributes, prgk_group_attributes)
    @subdivision_ref = prgk_group_attributes[:subdivision_ref]
    @cash_flow_item_ref = prgk_attributes[:cash_flow_item_ref]
    @project_ref = prgk_attributes[:project_ref]
    @worker_ref = prgk_attributes[:worker_ref]
  end

  def call
    prgk_validate
  end

  private
  def prgk_validate
    find_cash_flow_item? && find_project? && find_worker? && find_subdivision?
  end

  def find_cash_flow_item?
    CashFlowItem.where("ref = ?", @cash_flow_item_ref).first.present?
  end

  def find_project?
    Project.where("ref = ?", @project_ref).first.present?
  end

  def find_worker?
    Worker.where("ref = ?", @worker_ref).first.present?
  end

  def find_subdivision?
    Subdivision.where("ref = ?", @subdivision_ref).first.present?
  end
end
