# rack/static/copy

This is a simple middleware to save and load static copies of
rendered pages. So in other words, this is simple static cache
which saves in a format that can be used as a backup, or to be
loaded via a simple http server (e.g. Nginx).

### Installation

    echo "gem 'rack-static-copy'" >> Gemfile
    bundle

### Usage - Basic

    # config.ru
    require 'rack/hard/copy'
    use Rack::Hard::Copy, :store   => "/tmp/hard_copy",
                          :ignores => [ "search", "js", "png", "gif" ],
                          :timeout => 600

    run App


> Note: This should probably be the last middleware loaded.

#### Options

* `:store`   - path to file store
* `:ignores` - `Array` of keywords to be ignored
* `:timeout` - `Fixnum` as seconds to expire stored files
* `:headers` - `Boolean` can be set to `true` to insert custom http headers
  * `X-Rack-Hard-Save => (true|false)`
  * `X-Rack-Hard-Load => (true|false)`

### Another Use

Additionally, you can use Rack::Hard::Save alone to simple create a copy
of your pages in rendered html format (other formats are supported).

Exmaple:

    # config.ru
    require 'rack/hard/save'
    use Rack::Hard::Save, :store   => "/path/to/nginx/root/static",
                          :ignores => [ "search", "js", "png", "gif" ],
                          :timeout => 600

    run App


From there you can use Nginx to first check and see if the static pages exist
and if not, load your app normally, which will in turn generate the static
content.

Very large speed enhancments should be see doing this.


##### Nginx example config:

    # /etc/nginx/sites-enabled/my_site.conf
    server {
        #listen   80; ## listen for ipv4; this line is default and implied
        #listen   [::]:80 default ipv6only=on; ## listen for ipv6

        root /path/to/nginx/root;

        server_name localhost;

        location / {
            try_files /static$uri/index.html /static$uri $uri @app;
        }

        location @app {
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_pass http://0.0.0.0:8080;
        }
    }

The key to above lies in `/static$uri/index.html` and `/static$uri`.

Rack::Hard::Copy turns `/foo` in to `/foo/index.html`, while simply
copying anything with an extension. The above `try_files` will look
for this pattner in your choosen root and store location.

### Load

You can also load static files, on your own. This might be good for
pregenerating large sitemaps, error pages, etc. Why? Well, it might
be nice to dynamically generate a page, sitemaps in particular, but
store them staticly to reduce load on your host when they're rather
large.

    # config.ru
    require 'rack/hard/load'
    use Rack::Hard::Load, :store   => "./hard_copy",
                          :timeout => false


Pregeneration examples:

    $ curl http://yoursite.com/sitemap.xml > ./hard_copy/sitemap.xml
    $ curl http://yoursite.com/main.css > ./hard_copy/main.css

> These could be automated as part of your startup.

