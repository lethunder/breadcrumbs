# frozen_string_literal: true

require "i18n"
require "action_view"
require "active_support/inflector"

require "breadcrumbs/render"
require "breadcrumbs/action_controller_ext" if defined?(ActionController)

class Breadcrumbs
  attr_reader :current_user, :name

  def initialize(current_user, name = nil) # :nodoc:
    @current_user = current_user
    if name.present?
      @name = "user:#{@current_user.id}:#{name}"
    else
      @name = "user:#{@current_user.id}:breadcrumbs"
    end
  end

  # Add a new breadcrumbs.
  #
  #   breadcrumbs.add 'Home'
  #   breadcrumbs.add 'Home', '/'
  #   breadcrumbs.add 'Home', '/', class: 'home'
  #
  # If you provide a symbol as text, it will try to
  # find it as I18n scope.
  #
  def add(text, url = nil, options = {})
    options = {i18n: true}.merge(options)
    text = translate(text) if options.delete(:i18n)
    breadcrumb_hash = {"text" => text, "url" => url}.merge(options).with_indifferent_access

    if items.exclude?(breadcrumb_hash)
      $redis.rpush(@name, breadcrumb_hash.to_json)
    else
      unless items.find_index(breadcrumb_hash) == (items.size - 1)
        elements = items[0..items.find_index(breadcrumb_hash)]
        self.reset
        elements.each do |element|
          $redis.rpush(@name, element.to_json)
        end
      end
    end
  end

  def items
    hashes = $redis.lrange(@name, 0, -1)
    hashes.map! { |x| JSON.parse(x) }
  end

  def reset
    $redis.del(@name)
  end

  alias << add

  # Render breadcrumbs using the specified format.
  # Use HTML lists by default, but can be plain links.
  #
  #   breadcrumbs.render
  #   breadcrumbs.render(format: "inline")
  #   breadcrumbs.render(format: "inline", separator: "|")
  #   breadcrumbs.render(format: "list")
  #   breadcrumbs.render(format: "ordered_list")
  #   breadcrumbs.render(id: 'breadcrumbs')
  #   breadcrumbs.render(class: 'breadcrumbs')
  #
  # You can also define your own formatter. Just create a class that implements
  # a +render+ instance
  # method and you're good to go.
  #
  #   class Breadcrumbs::Render::Dl
  #     def render
  #       # return breadcrumbs wrapped in a <DL> tag
  #     end
  #   end
  #
  # To use your new format, just provide the <tt>:format</tt> option.
  #
  #   breadcrumbs.render(format: 'dl')
  #
  def render(options = {})
    options[:format] ||= :list

    klass_name = options.delete(:format).to_s.classify
    klass = Breadcrumbs::Render.const_get(klass_name)
    klass.new(self, options).render
  end

  def translate(scope) # :nodoc:
    return scope if scope.match?(/\A[\s.]+\z/)

    text = begin
             I18n.t(scope, scope: "breadcrumbs", raise: true)
           rescue StandardError
             nil
           end

    text ||= begin
               I18n.t(scope, default: scope.to_s)
             rescue StandardError
               scope
             end

    text
  end
end
