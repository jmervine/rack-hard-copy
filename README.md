# rack/static/copy

This is a simple two part middleware, the first Rack::Static::Save,
saves a static html copy (other formats supported) of your rendered
page. The second, Rack::Static::Load, loads a saved copy instead of
rendering your page.

Used together, it should deacrese load time, once a page has been
saved.

Simple Benchmark:

                              1         10        100       1000      10000
    --------------------------------------------------------------------------
    test_benchmark_copy_save  0.000881  0.002774  0.024893  0.288374  2.825357
    test_benchmark_copy_load  0.000497  0.002245  0.016319  0.197906  2.038878
    test_benchmark_save       0.000709  0.002379  0.020360  0.243811  2.374883
    test_benchmark_load       0.001283  0.001418  0.011091  0.156337  1.498511



So in other words, this is a static html cache.


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

Additionally, you can use Rack::Static::Save alone to simple create a copy
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

StaticCopy turns `/foo` in to `/foo/index.html`, while simply copying
anything with an extension. The above `try_files` will look for this
pattner in your choosen root and store location.

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

