module Yarel
  class Exception < StandardError
  end
  
  module Base
    attr_accessor :count
    
    module ClassMethods
      def all
        response = Connection.get(table.to_yql)
        raise Exception.new(response["error"]["description"]) if response["error"]
        [response["query"]["results"].first[1]].flatten
      end
      
      [:sort, :order, :limit, :where, :from, :project, :select].each do |chainable_method|
        class_eval <<-RUBY_EVAL, __FILE__, __LINE__
        def #{chainable_method}(*args)
          self.table = self.table.send(:#{chainable_method}, *args)
          self
        end
        RUBY_EVAL
      end
    end
    
    def self.included(klass)
      klass.cattr_accessor :table
      klass.table = Table.new(klass.name.underscore.gsub("/", "."), klass)
      klass.instance_eval do
        class << self
          delegate :to_yql, :to => :table
        end
      end
      klass.extend ClassMethods
    end
  end
end