module Yarel
  module Base
    attr_accessor :count

    module ClassMethods
      def all
        response = Connection.get(table.to_yql)
        raise Exception.new(response["error"]["description"]) if response["error"]
        [response["query"]["results"].first[1]].flatten
      end
      

      def table_name
        @table_name ||= self.name.underscore.gsub("_", ".")
      end
      
      def table_name=(name)
        @table_name = name
        @table = nil
      end
      
      def table
        @table ||= Table.new(self.table_name)
      end
      
      # [:sort, :order, :limit, :where, :from, :project, :select].each do |chainable_method|
      #   class_eval <<-RUBY_EVAL, __FILE__, __LINE__
      #   def #{chainable_method}(*args)
      #     self.table = self.table.send(:#{chainable_method}, *args)
      #     self
      #   end
      #   RUBY_EVAL
      # end
    end
    
    def self.included(klass)
      klass.delegate :to_yql, :to => :table
      klass.extend ClassMethods
    end
  end
end