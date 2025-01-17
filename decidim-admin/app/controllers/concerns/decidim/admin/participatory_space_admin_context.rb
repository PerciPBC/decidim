# frozen_string_literal: true

module Decidim
  module Admin
    # This module contains all the logic needed for a controller to render a participatory space
    # public layout. modqule ParticipatorySpaceAdminContext
    module ParticipatorySpaceAdminContext
      extend ActiveSupport::Concern

      class_methods do
        # Public: Called on a controller, it sets up all the surrounding methods to render a
        # participatory space's admin template. It expects the method `current_participatory_space`
        # to be defined, from which it will extract the participatory manifest.
        #
        # options - A hash used to modify the behavior of the layout. :only: - An array of actions
        #         on which the layout will be applied.
        #
        # Returns nothing.
        def participatory_space_admin_layout(options = {})
          layout :layout, options
          before_action :authorize_participatory_space, options
        end
      end

      included do
        include Decidim::NeedsOrganization
        include Decidim::Admin::ParticipatorySpaceAdminBreadcrumb
        helper ParticipatorySpaceHelpers

        helper_method :current_participatory_space
        helper_method :current_participatory_space_manifest
        helper_method :current_participatory_space_context
      end

      private

      def current_participatory_space_context
        :admin
      end

      def current_participatory_space
        raise NotImplementedError
      end

      def current_participatory_space_manifest
        return current_participatory_space.manifest if current_participatory_space

        manifest = Decidim.find_participatory_space_manifest(
          self.class.name.demodulize.underscore.gsub("_controller", "")
        )

        raise NotImplementedError unless manifest

        manifest
      end

      def authorize_participatory_space
        enforce_permission_to :read, :participatory_space, current_participatory_space:
      end

      def permissions_context
        super.merge(
          current_participatory_space:
        )
      end

      def layout
        current_participatory_space_manifest.context(current_participatory_space_context).layout
      end
    end
  end
end
