# frozen_string_literal: true

module Decidim
  module Meetings
    module AdminLog
      # This class holds the logic to present a `Decidim::Meetings::Meeting`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    MeetingPresenter.new(action_log, view_helpers).present
      class MeetingPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            address: :string,
            attendees_count: :integer,
            attending_organizations: :string,
            closed_at: :date,
            closing_report: :i18n,
            description: "Decidim::Meetings::AdminLog::ValueTypes::MeetingTitleDescriptionPresenter",
            end_date: :date,
            location: :i18n,
            location_hints: :i18n,
            start_date: :date,
            title: "Decidim::Meetings::AdminLog::ValueTypes::MeetingTitleDescriptionPresenter",
            private_meeting: :boolean,
            transparent: :boolean,
            published_at: :date,
            video_url: :string,
            audio_url: :string,
            closing_visible: :boolean
          }
        end

        def action_string
          case action
          when "close", "create", "delete", "export_registrations", "update", "soft_delete", "restore"
            "decidim.meetings.admin_log.meeting.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.meeting"
        end

        def diff_actions
          super + %w(close)
        end
      end
    end
  end
end
