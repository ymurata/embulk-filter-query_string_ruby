require "addressable/uri"

module Embulk
  module Filter

    class QueryStringRuby < FilterPlugin
      Plugin.register_filter("query_string_ruby", self)

      def self.transaction(config, in_schema, &control)
        task = {
          "default_timezone" => config.param("default_timezone", :string, :default => "UTC"),
          "target_column" => in_schema.find{|c| c.name == config.param("column", :string)},
          "schema" => config.param("schema", :array, :default => [])
        }

        out_columns = in_schema + task["schema"].map {|col| Column.new(nil, col["name"], col["type"].to_sym)}
        yield(task, out_columns)
      end

      def init
        @schema = task["schema"]
        @target_column = task["target_column"]
	ENV[task["default_timezone"]]
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
        u = Addressable::URI.parse(query_string)
        uri = u.query ? u : Addressable::URI.parse("?#{query_string}")
        return uri.query_values(Hash)
      end

      def make_record(schema, query)
        return schema.map do |col|
          v = query[col["name"]]
          if !v.to_s.empty?
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
end
