require 'fileutils'
require 'mime/types'

module Rack
  class Static
    autoload :VERSION, 'rack/static/version'
    module Util
      def ignored?(ignores, path)
        ignores.each { |ignore| return true if path.end_with?(ignore) } unless ignores.empty?
        return false
      end
      def generate_path_from store, path_info
        path = ::File.join(store, path_info)
        return ( MIME::Types.type_for("try."+path.split("/").last.split(".").last).empty? ? path.gsub(/\/$/, '')+"/index.html" : path )
      end
      def http_headers env
        http_headers = {}
        env.select { |k,v| k.start_with?("HTTP_") }.each do |k,v|
          http_headers[k.gsub(/^HTTP_/, '')] = v
        end
        http_headers
      end
      def expired? timeout, path
        return false unless timeout
        return true  unless ::File.exists?(path)
        (::File.mtime(path)+timeout) < Time.now
      end
    end
  end
end

