# frozen_string_literal: true

class Breadcrumbs
  module ActionController # :nodoc: all
    def self.included(base)
      base.send :helper_method, :breadcrumbs
    end

    def breadcrumbs(name=nil)
      @breadcrumbs ||= Breadcrumbs.new(current_user, name)
    end
  end
end

ActionController::Base.include Breadcrumbs::ActionController
