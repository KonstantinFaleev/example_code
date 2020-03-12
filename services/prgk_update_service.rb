class PrgkUpdateService < ApplicationService
  def initialize(prgk_groups)
    @prgk_groups = prgk_groups
    @prgk_groups_attributes = format_prgk_groups_attributes
  end

  def call
    create_prgks
    true
  end

  private

  def create_prgks
    @prgk_groups.each do |prgk_group|
      @prgk_group = prgk_group
      destroy_previous_prgks
      create_group_prgks
    end
  end

  def format_prgk_groups_attributes
    AttributesFormatService.call('PrgkGroup', @prgk_groups, 'key', 'Attributes')
  end

  def prgks_array
    AttributesFormatService.call(Prgk, @prgk_group['CashFlows'], 'array')
  end

  def group_ref
    @prgk_group['Attributes']
        .select { |attr| attr["code"] === 'Ref' }.first['value']
  end


  def destroy_previous_prgks
    Prgk.where(group_ref: group_ref).destroy_all
  end

  def create_group_prgks
    prgks_array.each do |prgk_attributes|
      Prgk.create(prgk_attributes.merge(prgk_group_attributes)) if PrgkValidateService
                                                                       .call(prgk_attributes, prgk_group_attributes)
    end
  end

  def prgk_group_attributes
    @prgk_groups_attributes.select { |attr| attr[:group_ref] === group_ref }.first
  end
end
