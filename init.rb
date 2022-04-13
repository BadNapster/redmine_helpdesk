require 'redmine'

# require_relative 'lib/redmine_helpdesk/hooks/helpdesk_hooks'
# require_relative 'lib/redmine_helpdesk/helpdesk_mailer'
# require_relative 'lib/redmine_helpdesk/patches/journal_patch'
# require_relative 'lib/redmine_helpdesk/patches/mail_handler_patch'
# require_relative 'lib/redmine_helpdesk/patches/mailer_patch'

Redmine::Plugin.register :redmine_helpdesk do
  name 'Redmine helpdesk plugin'
  author 'Stefan Husch'
  description 'Redmine helpdesk plugin'
  version '0.0.18'
  requires_redmine :version_or_higher => '4.0.0'
  project_module :issue_tracking do
    permission :treat_user_as_supportclient, {}
  end
end

if Rails.version > '6.0'
  ActiveSupport.on_load(:active_record) { RedmineHelpdesk.setup }
else
  Rails.configuration.to_prepare { RedmineHelpdesk.legacy_setup }
end
