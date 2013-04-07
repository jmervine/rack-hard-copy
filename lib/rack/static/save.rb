require File.join(File.dirname(__FILE__), "util")
module Rack
  class Static
    class Save
      include Util
      def initialize(app, opts={})
        @app     = app
        @store   = opts[:store]   || "./static"
        @ignores = opts[:ignores] || []
        @timeout = opts[:timeout] || false
        @headers = opts[:headers] || false

        Dir.mkdir(@store, 0770) unless ::File.directory?(@store)
      end

      def call(env)
        return @app.call(env) unless env["REQUEST_METHOD"] == "GET"

        logger    = env['rack.logger']||nil
        path      = generate_path_from(@store, env['PATH_INFO'].to_s)

        status,
        headers,
        response  = @app.call(env)

        if (@timeout === false || expired?(@timeout, path)) && !ignored?(@ignores, path) && status == 200
          begin
            FileUtils.mkdir_p(::File.dirname(path)) unless ::File.directory?(::File.dirname(path))
            create(path, response.first)
            headers['X-Rack-Static-Save'] = 'true' if @headers
            logger.info "Rack::StaticSave creating: #{path}" rescue nil
          rescue => e
            headers['X-Rack-Static-Save'] = 'error' if @headers
            logger.error "Rack::StaticSave error creating: #{path}\n#{e}\n#{e.backtrace.join("\n")}" rescue nil
          end
        end

        headers['X-Rack-Static-Save'] ||= 'false' if @headers
        [status, headers, response]
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
