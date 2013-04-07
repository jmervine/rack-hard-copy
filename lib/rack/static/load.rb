require File.join(File.dirname(__FILE__), "util")
module Rack
  class Static
    class Load
      include Util
      def initialize(app, opts={})
        @app     = app
        @store   = opts[:store]   || "./static"
        @ignores = opts[:ignores] || []
        @headers = opts[:headers] || false
        @timeout = opts[:timeout] || false
      end

      def call(env)
        return @app.call(env) unless env["REQUEST_METHOD"] == "GET"

        logger    = env['rack.logger']||nil
        path      = generate_path_from(@store, env['PATH_INFO'].to_s)

        if ::File.exists?(path) && !ignored?(@ignores, path) && (@timeout === false || !expired?(@timeout, path))
          logger.info "Rack::StaticCopy loading: #{path}" rescue nil
          begin
            status = 200
            headers = http_headers(env)
            headers['X-Rack-Static-Load'] = 'true' if @headers
            response = [ ::File.read(path) ]
          rescue => e
            logger.error "Rack::StaticCopy error creating: #{path}\n#{e}\n#{e.backtrace.join("\n")}" rescue nil
            status, headers, response = @app.call(env)
            headers['X-Rack-Static-Load'] = "error" if @headers
          end
        else
          logger.info "Rack::StaticCopy passing" rescue nil
          status, headers, response = @app.call(env)
          headers['X-Rack-Static-Load'] = "false" if @headers
        end
        return [status, headers, response]
      end

      private
    end
  end
end

