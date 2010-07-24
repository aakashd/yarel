module Yarel
  class Table
    attr_accessor :table_name, :projections, :conditions, :limit_to, :offset

    def initialize(table_name)
      @table_name = table_name
      @projections = "*"
      @conditions = []
      @limit_to = :default
      @offset = :default
    end

    def from(table_name)
      modify_clone { self.table_name = table_name }
    end

    def project(*field_names)
      modify_clone { self.projections = field_names.join(", ") }
    end

    alias_method :select, :project

    def where(condition)
      new_condition =
      case
      when condition.kind_of?(Hash)
        condition.map do |key, value|
          condition_string = value.kind_of?(self.class) ? "#{key} in ( #{value.to_yql} )" : "#{key} = #{value}"
        end
      when condition.kind_of?(String)
        condition
      when condition.kind_of?(Array)
        send :sprintf, condition[0].gsub("?", "%s"), *condition[1..-1]
      end

      modify_clone { self.conditions << new_condition }
    end

    def limit(*options)
      lim = options[0]
      off, lim = options[0..1] unless options.size == 1
      modify_clone {
        self.limit_to = lim.to_i if lim
        self.offset = off.to_i if off
      }
    end

    def to_yql
      yql = ["SELECT #{projections} FROM #{table_name}"]
      yql << "WHERE #{conditions.join(' AND ')}" unless conditions.empty?
      yql << "LIMIT #{limit_to}" if limit_to != :default
      yql << "OFFSET #{offset}" if offset != :default
      yql.join " "
    end

    private
    def modify_clone(&block)
      cloned_obj = self.deep_clone
      cloned_obj.instance_eval &block
      cloned_obj
    end
  end
end
