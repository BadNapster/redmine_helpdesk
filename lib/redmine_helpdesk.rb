module RedmineHelpdesk
    VERSION = '1.0.0'

    class << self
      def setup
    
        # Hooks
        RedmineHelpdesk::Hooks::HelpdeskHooks
      end

      def legacy_setup
        require_relative '/hooks/helpdesk_hooks'
        require_relative '/helpdesk_mailer'
        require_relative '/patches/journal_patch'
        require_relative '/patches/mail_handler_patch'
        require_relative '/patches/mailer_patch'
      end
    end
end