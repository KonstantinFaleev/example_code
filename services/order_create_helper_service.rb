class OrderCreateHelperService < ApplicationService
  def initialize(params, current_user)
    @user = current_user
    @params = params
    @prgks = Prgk.all
    @date = Date.parse(params[:perform_date].to_s)
    @final_scopes = {
        project: nil,
        cash_flow_item: nil,
        subdivision: nil,
        worker: nil,
        valid_prgks: false
    }
  end

  def fields_scopes
    if @params[:nature_of_costs]
      init_query
      scopes
    end
    valid_prgks?
    @final_scopes
  end

  def sequence
    Order.basic_fields_sequence(@params[:nature_of_costs])
  end

  private

  def init_query
    sort_by_period
    sort_by_subdivision
    sort_by_date
    sort_by_project_dest_cost
  end

  def sort_by_period
    @prgks = @prgks.where('prgks.period = 4')
  end

  def sort_by_subdivision
    @prgks = @prgks.where('prgks.subdivision_ref IN (?)', user_subdivisions) unless @user.has_role? :admin_order
  end

  def sort_by_date
    @prgks = @prgks.where('prgks.date_start <= ? AND prgks.date_end >= ?', @date, @date)
  end

  def sort_by_project_dest_cost
    @prgks = @prgks.by_project_dest_cost(@params[:nature_of_costs])
  end


  def scopes
    previous_filed = ''
    sequence.each do |field|
      if previous_filed.blank? || @params[:"#{previous_filed}_id"].present?
        define_query(previous_filed)
        if @prgks.any?
          define_scope(field)
          auto_check(field)
        end
      end
      previous_filed = field
    end
  end

  def define_query(previous_filed)
    case previous_filed
    when 'project'
      @prgks = @prgks.by_project(@params[:project_id])
    when 'cash_flow_item'
      @prgks = @prgks.by_cash_flow_item(@params[:cash_flow_item_id])
    when 'subdivision'
      @prgks = @prgks.by_subdivision(@params[:subdivision_id])
    end
  rescue ActiveRecord::RecordNotFound
    @prgks = nil
  end

  def define_scope(field)
    case field
    when 'project'
      @final_scopes[:project] =  @prgks.map(&:project).uniq.compact
    when 'cash_flow_item'
      @final_scopes[:cash_flow_item] = @prgks.map(&:cash_flow_item).uniq.compact
    when 'subdivision'
      @final_scopes[:subdivision] = @prgks.map(&:subdivision).uniq.compact
    when 'own_customer'
      @final_scopes[:own_customer] = @prgks.map(&:worker).uniq.compact
    end
  end

  def user_subdivisions
    @user.subdivisions.map(&:ref)
  end

  def valid_prgks?
    @final_scopes[:valid_prgks] = @prgks.any?
  end

  def auto_check(field)
    # auto check if available 1 record
    scope = @final_scopes[:"#{field}"]
    @params["#{field}_id"] = scope[0].id if scope.count == 1
  end
end
