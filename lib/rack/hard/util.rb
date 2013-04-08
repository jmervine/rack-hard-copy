require 'fileutils'
require 'mime/types'

module Rack
  class Hard
    module Util
      def setup_variables(opts={})
        @store   ||= opts[:store]   || "./static"
        @ignores ||= opts[:ignores] || []
        @headers ||= opts[:headers] || false
        @timeout ||= opts[:timeout] || false
        make_dir(@store)
      end

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
        return false if timeout === false
        return true  if timeout === true
        return true  unless ::File.exists?(path)
        (::File.mtime(path)+timeout) < Time.now
      end

      def make_dir path
        FileUtils.mkdir_p(path) unless ::File.directory?(path)
      end
    end
  end
end

