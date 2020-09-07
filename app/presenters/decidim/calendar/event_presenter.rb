# frozen_string_literal: true

module Decidim
  module Calendar
    class EventPresenter < SimpleDelegator
      def color
        case __getobj__.class.name
        when "Decidim::ParticipatoryProcessStep"
          "#3A4A9F"
        when "Decidim::Meetings::Meeting"
          "#ed1c24"
        when "Decidim::Calendar::ExternalEvent"
          "#ed650b"
        when "Decidim::Debates::Debate"
          "#099329"
        when "Decidim::Consultation"
          "#92278f"
        end
      end

      def type
        case __getobj__.class.name
        when "Decidim::ParticipatoryProcessStep"
          "participatory_process_step"
        when "Decidim::Meetings::Meeting"
          "meeting"
        when "Decidim::Calendar::ExternalEvent"
          "external_event"
        when "Decidim::Debates::Debate"
          "debate"
        when "Decidim::Consultation"
          "consultation"
        end
      end

      def full_id
        return id unless participatory_process_step?
        
        "#{participatory_process.id}-#{id}"
      end

      def parent
        if participatory_process_step? 
          "#{participatory_process.id}-#{participatory_process.steps.find_by(position: position - 1).id}" if position.positive?
        end
      end

      def link
        return url if respond_to?(:url)

        component = participatory_process_step? ? participatory_process : __getobj__
        return Decidim::ResourceLocatorPresenter.new(component).url
      end

      def start
        @start ||= if respond_to?(:start_date)
                     start_date
                   elsif respond_to?(:start_at)
                     start_at
                   elsif respond_to?(:start_voting_date)
                     start_voting_date
                   else
                     start_time
                   end
      end

      def finish
        @finish ||= if respond_to?(:end_date)
                      end_date
                    elsif respond_to?(:end_at)
                      end_at
                    elsif respond_to?(:end_voting_date)
                      end_voting_date
                    else
                      end_time
                    end
        @finish || start
      end

      def full_title
        participatory_process_step? ? participatory_process.title : title
      end

      def subtitle
        @subtitle ||= participatory_process_step? ? title : ""
      end

      def all_day?
        days > 1
      end

      def days
        return 0 if start.nil? || finish.nil?

        (start.to_date..finish.to_date).count
      end

      def model_class_name
        @model.class.name
      end

      def participatory_process_step?
        type == "participatory_process_step"
      end

      def compatible_modules
        [
          "Decidim::Meetings::Meeting",
          "Decidim::ParticipatoryProcessStep",
          "Decidim::Debates::Debate",
          "Decidim::Calendar::ExternalEvent",
          "Decidim::Consultation"
        ]
      end
    end
  end
end
