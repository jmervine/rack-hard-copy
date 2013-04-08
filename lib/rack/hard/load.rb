require File.join(File.dirname(__FILE__), "util")
module Rack
  class Hard
    class Load
      include Util
      def initialize(app, opts={})
        @app     = app
        setup_variables(opts)
      end

      def call(env)
        return @app.call(env) if     ignored?(@ignores, env["PATH_INFO"].to_s)
        return @app.call(env) unless env["REQUEST_METHOD"] == "GET"

        logger    = env['rack.logger']||nil
        path      = generate_path_from(@store, env['PATH_INFO'].to_s)

        if ::File.exists?(path) && !ignored?(@ignores, path) && (@timeout === false || !expired?(@timeout, path))
          logger.info "Rack::Hard::Load loading: #{path}" rescue nil
          begin
            status = 200
            headers = http_headers(env)
            headers['X-Rack-Hard-Load'] = 'true' if @headers
            response = [ ::File.read(path) ]
          rescue => e
            logger.error "Rack::Hard::Load error creating: #{path}\n#{e}\n#{e.backtrace.join("\n")}" rescue nil
            status, headers, response = @app.call(env)
            headers['X-Rack-Hard-Load'] = "error" if @headers
          end
        else
          logger.info "Rack::Hard::Load passing" rescue nil
          status, headers, response = @app.call(env)
          headers['X-Rack-Hard-Load'] = "false" if @headers
        end
        return Rack::Response.new(response, status, headers)
      end
    end
  end
end

