require "addressable/uri"

module Embulk
  module Filter

    class QueryStringRuby < FilterPlugin
      Plugin.register_filter("query_string_ruby", self)

      def self.transaction(config, in_schema, &control)
        task = {
          "column" => config.param("column", :string),
          "query_params" => config.param("query_params", :array, :default => []).inject({}){|a, c|
            a[c["name"]] = {"type" => c["type"].to_sym, "format" => c['format']}
            a
          }
        }
        task["target_column"] = in_schema.find{|c| c.name == task["column"]}
        idx = in_schema.size
        columns = task['query_params'].map.with_index{|(name, c), i| Column.new(i+idx, name, c["type"], c["format"])}
        out_columns = in_schema + columns
        yield(task, out_columns)
      end

      def init
        @query_params = task["query_params"]
        @target_column = task["target_column"]
      end

      def close
      end

      def add(page)
        page.each do |record|
          q = query_parser(record[@target_column["index"]])
          add_records = make_records(@query_params, q)
          page_builder.add(record + add_records)
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
          return uri.query_values(Hash)
        rescue ArgumentError
          Embulk.logger.warn "Failed parse: #{query_string}"
          return nil
        end
      end

      def make_records(schema, query)
        return query.map{|name, v|
          c = schema[name]
          begin
            case c["type"]
            when "long"
              v.empty? ? nil : Integer(v)
            when "timestamp"
              puts(c)
              v.empty? ? nil : Time.strptime(v, c["format"])
            else
              v.to_s
            end
          rescue => e
            raise ConfigError.new("Cast failed '#{v}' as '#{schema[k]["type"]}' (key is '#{k}')")
          end
        }
      end

    end

  end
end
