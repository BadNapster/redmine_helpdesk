class CreateCustomFieldsForReply < ActiveRecord::Migration[5.2]
  def self.up
    c = CustomField.new(
      :name => 'helpdesk-send-transition',
      :editable => true,
      :visible => false,          # do not show it on the project summary page
      :field_format => 'text')
    c.type = 'ProjectCustomField' # cannot be set by mass assignement!
    c.save
    d = CustomField.new(
      :name => 'helpdesk-reply-transition',
      :editable => true,
      :visible => false,          # do not show it on the project summary page
      :field_format => 'text')
    d.type = 'ProjectCustomField' # cannot be set by mass assignement!
    d.save
  end

  def self.down
    CustomField.find_by_name('helpdesk-send-transition').delete
    CustomField.find_by_name('helpdesk-reply-transition').delete
  end
end