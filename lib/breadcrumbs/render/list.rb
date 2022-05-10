# frozen_string_literal: true

class Breadcrumbs
  module Render
    class List < Base # :nodoc: all
      def render
        options = {class: "flex items-center space-x-4"}.merge(default_options)

        tag(list_style, options) do
          html = []
          items = breadcrumbs.items
          size = items.size

          items.each_with_index do |item, i|
            html << render_item(item, i, size)
          end

          html.join.html_safe
        end
      end

      def list_style
        :ol
      end

      def render_item(item, index, size)
        text = item["text"]
        url = item["url"]

        item.delete("text")
        item.delete("url")

        if index == (size - index)
          text = wrap_item(nil, text, item)
        else
          text = wrap_item(url, text, item)
        end
        tag(:li, text) do
          "<div class='flex items-center'>
          <svg class='flex-shrink-0 h-5 w-5 text-gray-300' xmlns='http://www.w3.org/2000/svg' fill='currentColor' viewBox='0 0 20 20' aria-hidden='true'>
          <path d='M5.555 17.776l8-16 .894.448-8 16-.894-.448z'></path>
                </svg>
            #{text}
          </div>".html_safe
        end
      end
    end
  end
end
