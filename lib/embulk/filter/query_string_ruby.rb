require 'uri'
require 'cgi'

module Embulk
  module Filter

    class QueryStringRuby < FilterPlugin
      Plugin.register_filter("query_string_ruby", self)
      @pattern = "(\?|\&)([^=\n]+)\=([^&\n]+)"

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
          query_parser(@query_params, record[@target_column["index"]])
          page_builder.add(record)
        end
      end

      def finish
        page_builder.finish
      end

      def query_parser(query_params, query_string)
        uri = URI.unescape(query_string)
        u = URI.parse(uri)
        puts(query_string.match(/#{@pattern}/))
        # if u.query
        #   puts(u.query)
        # end
        # CGI.parse(q)
      end

    end

  end
end
