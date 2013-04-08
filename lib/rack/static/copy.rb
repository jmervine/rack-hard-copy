require ::File.join(::File.dirname(__FILE__), "util")
module Rack
  class Static
    class Copy
      include Util
      autoload :VERSION, ::File.join(::File.dirname(__FILE__), "version")
      def initialize(app, opts={})
        @app     = app
        setup_variables(opts)
      end

      def call(env)
        return @app.call(env) unless env["REQUEST_METHOD"] == "GET"

        logger    = env['rack.logger']||nil
        path      = generate_path_from(@store, env['PATH_INFO'].to_s)

        status, headers, response  = @app.call(env)

        if (@timeout === false || expired?(@timeout, path)) && !ignored?(@ignores, path) && status == 200
          begin
            make_dir(::File.dirname(path))
            create(path, response.first)
            headers['X-Rack-Static-Copy'] = 'true' if @headers
            logger.info "Rack::StaticCopy creating: #{path}" rescue nil
          rescue => e
            headers['X-Rack-Static-Copy'] = 'error' if @headers
            logger.error "Rack::StaticCopy error creating: #{path}\n#{e}\n#{e.backtrace.join("\n")}" rescue nil
          end
        end

        headers['X-Rack-Static-Copy'] ||= 'false' if @headers

        return Rack::Response.new(response, status, headers)
      end

      private
      def create(f, body)
        ::File.open(f, ::File::WRONLY|::File::TRUNC|::File::CREAT, 0664) do |file|
          file.flock(::File::LOCK_EX)
          file.write(body)
        end
      end
    end
  end
end
