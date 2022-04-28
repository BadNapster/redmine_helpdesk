module RedmineHelpdesk
  module Patches
    module JournalPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        
        base.class_eval do
          alias_method :send_notification_without_helpdesk, :send_notification
          alias_method :send_notification, :send_notification_with_helpdesk
        end
      end
  
      module InstanceMethods
        # Overrides the send_notification method which
        # is only called on journal updates
        def send_notification_with_helpdesk
          if notify? && (Setting.notified_events.include?('issue_updated') ||
              (Setting.notified_events.include?('issue_note_added') && notes.present?) ||
              (Setting.notified_events.include?('issue_status_updated') && new_status.present?) ||
              (Setting.notified_events.include?('issue_assigned_to_updated') && detail_for_attribute('assigned_to_id').present?) ||
              (Setting.notified_events.include?('issue_priority_updated') && new_value_for('priority_id').present?)
            )
            Mailer.deliver_issue_edit(self)
          end
          # do not send on private-notes
          if private_notes == true && send_to_owner == true 
            self.send_to_owner = false
            self.save(:validate => false)
          end
          # sending email notifications to the supportclient
          # only if the send_to_owner checkbox was checked
          if send_to_owner == true && notes.length != 0
            # issue = self.journalized.reload
            issue = Issue.find_by_id(self.journalized.id)
  
            # status transition reply from journal
            custom_value = CustomValue.where(
              "customized_id = ? AND custom_field_id = ?", issue.project.id, CustomField.find_by_name('helpdesk-status-transition').id
            ).first
            if !issue.closed? && custom_value.present? && custom_value.value.present?
              tr_status = custom_value.value.split(',')
              if tr_status.any?
                status_id_first = IssueStatus.where("name = ?", tr_status.first).try(:first).try(:id) 
                status_id_last = IssueStatus.where("name = ?", tr_status.last).try(:first).try(:id) 
  
                unless status_id_first.nil? && status_id_last.nil? 
                  if issue.status_id == status_id_first
                    issue.status_id = status_id_last
                    issue.save
                  end
                end          
              end
            end
  
            owner_email = issue.custom_value_for( CustomField.find_by_name('owner-email') ).value
            RedmineHelpdesk::HelpdeskMailer.email_to_supportclient(
              issue, {
                recipient: owner_email,
                journal:   self,
                text:      notes
              }
            ).deliver unless owner_email.blank?
          end
        end
        
      end # module InstanceMethods
    end # module JournalPatch
  end  # module Patches
end # module RedmineHelpdesk

# Add module to Journal class
# Journal.send(:include, RedmineHelpdesk::Patches::JournalPatch)
# Journal.include RedmineHelpdesk::Patches::JournalPatch
