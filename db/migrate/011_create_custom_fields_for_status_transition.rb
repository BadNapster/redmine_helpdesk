class CreateCustomFieldsForStatusTransition < ActiveRecord::Migration[5.2]
  def self.up
    c = CustomField.new(
      :name => 'helpdesk-status-transition',
      :editable => true,
      :visible => false,          # do not show it on the project summary page
      :field_format => 'string')
    c.type = 'ProjectCustomField' # cannot be set by mass assignement!
    c.save
  end

  def self.down
    CustomField.find_by_name('helpdesk-status-transition').delete
  end
end