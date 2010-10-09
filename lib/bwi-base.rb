module ActiveRecord
  class Base
    alias_attribute :pkid, :id
  end
end

module ActionView
  module Helpers
    module NumberHelper
      def decimal_number_to_percentage(number, options = {})
        options[:precision] ||= 0
        number_to_percentage number * 100, options
      end
    end
  end
end

module ApplicationHelper
  def title(page_title, show_title = true)
    content_for :title, page_title.to_s
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  def menu_item(klass, opts = {})
    if can? :manage, klass
      html = ''
      html += ' | ' if !opts[:first]
      opts[:label] ||= klass.to_s.tableize.humanize.titleize
      html += link_to(opts[:label],eval("#{klass.to_s.tableize}_path"))
    end
  end
end

module BWI
  module Array
    module InstanceMethods
      def append_condition(sql,value)
        arr = self.clone
        arr.append_condition!(sql,value)
      end

      def append_condition!(sql,value)
        self[0] << " #{sql}"
        self << value
      end
    end
    
    def self.included(receiver)
      receiver.send :include, InstanceMethods
    end
  end
  
  module ActiveRecord
    module Base
      module ClassMethods
        def has_long_date(*symbols)
          symbols.each do |symbol|
            define_method "long_#{symbol}" do
              self[symbol].strftime("%B %d, %Y")
            end
          end
        end

        def autocomplete_with_creation_for(object,method)
          name = object.to_s.underscore
          object = object.to_s.camelize.constantize

          #auto_user_name=
          define_method("auto_#{name}_#{method}=") do |value|
            found = object.send("find_or_create_by_autocomplete_"+method,value)
            self.send(name+'=', found)
          end

          #auto_user_name
          define_method("auto_#{name}_#{method}") do
            return send(name).send(method) if send(name)
            ""
          end
        end

        def find_or_create_by_autocomplete(attr)
          class_eval <<-end_eval
            def self.find_or_create_by_autocomplete_#{attr}(value)
              return nil if value.blank?
              self.find_or_create_by_#{attr}(value.to_s)
            end
          end_eval
        end
      end

      module InstanceMethods    
        def to_json(options={})
          super({:methods => 'pkid'}.merge(options))
        end
      end
      
      def self.included(receiver)
        receiver.send :extend, ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end

  module Time  
    module InstanceMethods
      def to_month
        self.strftime '%B %Y'
      end
    end
      
    def self.included(receiver)
      receiver.send :include, InstanceMethods
    end
  end
end


module ActionController #:nodoc:
  class Base
    def bwi_respond_with(*resources, &block)
      respond_with(*resources, :methods => :pkid, &block)
    end
  end
end

class Time;include BWI::Time;end
class ActiveRecord::Base;include BWI::ActiveRecord::Base;end
class Array;include BWI::Array;end
