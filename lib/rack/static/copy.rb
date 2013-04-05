require File.join(File.dirname(__FILE__), "util")
module Rack
  class Static
    class Copy
      include Util
      def initialize(app, opts={})
        @app     = app
        @store   = opts[:store]||"./static"
        @ignores = opts[:ignores]||[]

        Dir.mkdir(@store, 0770) unless ::File.directory?(@store)
      end

      def call(env)
        return @app.call(env) unless env["REQUEST_METHOD"] == "GET"

        logger    = env['rack.logger']||nil
        path      = generate_path_from(@store, env['PATH_INFO'].to_s)

        status,
        headers,
        response  = @app.call(env)

        unless ignored?(@ignores, path) && status == 200
          begin
            FileUtils.mkdir_p(::File.dirname(path)) unless ::File.directory?(::File.dirname(path))
            create(path, response.first)
            logger.info "Rack::StaticCopy creating: #{path}" rescue nil
          rescue => e
            logger.error "Rack::StaticCopy error creating: #{path}\n#{e}\n#{e.backtrace.join("\n")}" rescue nil
          end
        end

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
