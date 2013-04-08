require ::File.join(::File.dirname(__FILE__), "util")
require ::File.join(::File.dirname(__FILE__), "save")
require ::File.join(::File.dirname(__FILE__), "load")
module Rack
  class Hard
    class Copy
      include Util
      autoload :VERSION, ::File.join(::File.dirname(__FILE__), "version")
      def initialize(app, opts={})
        @app             = app
        opts[:store]   ||= "./static"
        opts[:ignores] ||= []
        opts[:headers] ||= false
        opts[:timeout] ||= 600
        @options         = opts

        make_dir(@options[:store])
      end

      def call(env)
        return @app.call(env) if     ignored?(@options[:ignores], env["PATH_INFO"].to_s)
        return @app.call(env) unless env["REQUEST_METHOD"] == "GET"

        logger = env['rack.logger']||nil
        path   = generate_path_from(@options[:store], env['PATH_INFO'].to_s)

        if @options[:timeout] === false || expired?(@options[:timeout], path)
          logger.warn "Rack::Hard::Copy: Warning, Copy without timeout is just a Save." if @options[:timeout] === false
          return Rack::Hard::Save.new(@app, @options).call(env)
        else
          return Rack::Hard::Load.new(@app, @options).call(env)
        end
      end
    end
  end
end

