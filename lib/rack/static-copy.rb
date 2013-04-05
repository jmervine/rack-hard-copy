require 'fileutils'
require 'mime/types'

module Rack
  class StaticCopy
    autoload :VERSION, 'rack/static-copy/version'

    # Why?
    #
    # This will store a static copy of your processed page so that
    # you can load it through a web server. Much faster, no?
    #
    # This is was designed around NestaCMS and other simple CMS
    # applications and don't require dynamic content.
    #
    # # config.ru
    # require 'rack/static_copy'
    # use Rack::StaticCopy, :store => "/path/to/nginx/root/static"
    # run App
    #
    # Nginx example:
    #
    # # /etc/nginx/sites-enabled/my_site.conf
    #  server {
    #      #listen   80; ## listen for ipv4; this line is default and implied
    #      #listen   [::]:80 default ipv6only=on; ## listen for ipv6
    #
    #      root /path/to/nginx/root;
    #
    #      server_name localhost;
    #
    #      location / {
    #          try_files /static$uri/index.html /static$uri $uri @app;
    #      }
    #
    #      location @app {
    #        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #        proxy_set_header Host $http_host;
    #        proxy_pass http://0.0.0.0:8080;
    #      }
    #  }
    #
    # The key to above lies in '/static$uri/index.html' and '/static$uri'.
    #
    # StaticCopy turns '/foo' in to '/foo/index.html', while simply copying
    # anything with an extension. The above 'try_files' will look for this
    # pattner in your choosen root and store location.
    #

    def initialize(app, opts={})
      @app     = app
      @store   = opts[:store]||"./static"
      @ignores = opts[:ignores]||[]
      @timer   = opts[:timer]||true

      Dir.mkdir(@store, 0770) unless ::File.directory?(@store)

    end

    def call(env)
      return @app.call(env) unless env["REQUEST_METHOD"] == "GET"

      logger    = env['rack.logger']
      path      = generate_path_from( env['PATH_INFO'].to_s )

      status,
      headers,
      response  = @app.call(env)

      if should_copy?(path) && status == 200
        begin
          FileUtils.mkdir_p(::File.dirname(path)) unless ::File.directory?(::File.dirname(path))
          create(path, response.first)
          logger.info "Rack::StaticCopy creating: #{path}"
        rescue => e
          logger.error "Rack::StaticCopy error creating: #{path}\n#{e}\n#{e.backtrace.join("\n")}"
        end
      end

      [status, headers, response]
    end

    private
    def should_copy?(path)
      @ignores.each { |ignore| return false if path.end_with?(ignore) } unless @ignores.empty?
      return true
    end

    def generate_path_from path_info
      path = ::File.join(@store, path_info)
      return ( MIME::Types.type_for("try."+path.split("/").last.split(".").last).empty? ? path.gsub(/\/$/, '')+"/index.html" : path )
    end

    def create(f, body)
      ::File.open(f, ::File::WRONLY|::File::TRUNC|::File::CREAT, 0664) do |file|
        file.flock(::File::LOCK_EX)
        file.write(body)
      end
    end
  end
end
