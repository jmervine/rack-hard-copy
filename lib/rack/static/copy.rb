require File.join(File.dirname(__FILE__), "util")
require File.join(File.dirname(__FILE__), "save")
require File.join(File.dirname(__FILE__), "copy")

module Rack
  class Static
    class Copy
      include Util
      def initialize(app, opts={})
        @app             = app

        # default options
        opts[:store]   ||= "./static"
        opts[:ignores] ||= []

        # handing disabling of timeout
        opts[:timeout] ||= 600 unless opts[:timeout] === false

        opts[:headers] ||= false
        @options         = opts
      end

      def call(env)
        path = generate_path_from(@options[:store], env['PATH_INFO'].to_s)

        # handing disabling of timeout
        if @options[:timeout] === false || expired?(@options[:timeout], path)
          return Rack::Static::Save.new(@app, @options).call(env)
        else
          return Rack::Static::Load.new(@app, @options).call(env)
        end
      end

      def pass_call env, header = "false"
        status, headers, response = @app.call(env)
        headers['X-Rack-Static-Copy'] = header
        [status, headers, response]
      end
    end
  end
end

