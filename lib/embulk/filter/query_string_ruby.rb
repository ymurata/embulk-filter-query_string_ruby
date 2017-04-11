require "addressable/uri"

module Embulk
  module Filter

    class QueryStringRuby < FilterPlugin
      Plugin.register_filter("query_string_ruby", self)

      def self.transaction(config, in_schema, &control)
        task = {
          "target_column" => in_schema.find{|c| c.name == config.param("column", :string)},
          "schema" => config.param("schema", :array, :default => [])
        }

        out_columns = in_schema + task["schema"].map {|col| Column.new(nil, col["name"], col["type"].to_sym)}
        yield(task, out_columns)
      end

      def init
        @schema = task["schema"]
        @target_column = task["target_column"]
      end

      def close
      end

      def add(page)
        page.each do |record|
          q = query_parser(record[@target_column["index"]])
          add_record = make_record(@schema, q)
          page_builder.add(record + add_record)
        end
      end

      def finish
        page_builder.finish
      end

      private

      def query_parser(query_string)
        begin
          u = Addressable::URI.parse(query_string)
          uri = u.query ? u : Addressable::URI.parse("?#{query_string}")
          uri.query_values(Hash)
        rescue => e
          Embulk.logger.warn("Parse failed '#{query_string}'")
        end
        uri.nil? ? {} : uri.query_values(Hash)
      end

      def make_record(schema, query)
        return schema.map do |col|
          v = query[col["name"]]

          if v.to_s.empty?
            next
          end

          begin
            case col["type"]
            when "long"
              Integer(v)
            when "double"
              Float(v)
            when "timestamp"
              Time.parse(v)
            else
              v.to_s
            end
          rescue => e
            Embulk.logger.warn("Cast failed '#{v}' as '#{col["type"]}' (query name is '#{col["name"]}')")
          end
        end
      end

    end

  end
end
