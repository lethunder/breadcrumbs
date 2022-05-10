# frozen_string_literal: true

class Breadcrumbs
  module Render
    class Base # :nodoc: all
      include ::ActionView::Helpers::TagHelper

      attr_accessor :breadcrumbs, :default_options, :output_buffer

      def initialize(breadcrumbs, default_options = {})
        @breadcrumbs = breadcrumbs
        @default_options = default_options
      end

      def tag(name, content = "", options = {}, &block)
        content_tag(name, content, options, &block)
      end

      protected def wrap_item(url, text, options)
        if url
          tag(:a, text, options.merge(href: url).merge(class: "ml-4 text-sm font-medium text-gray-500 hover:text-gray-700 #{options["class"]}"))
        else
          tag(:div, text, {class: "text-center ml-4 text-sm font-medium text-gray-500 hover:text-gray-700 #{options["class"]}"})
        end
      end
    end
  end
end
