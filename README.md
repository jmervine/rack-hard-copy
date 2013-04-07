# rack/static/copy

This is a simple two part middleware, the first Rack::Static::Save,
saves a static html copy (other formats supported) of your rendered
page. The second, Rack::Static::Load, loads a saved copy instead of
rendering your page.

Used together, it should deacrese load time, once a page has been
saved.

Simple Benchmark:

    ... goes here ...


So in other words, this is a static html cache.


### Installation

    echo "gem 'rack-static-copy'" >> Gemfile
    bundle

### Usage - Basic

    # config.ru
    require 'rack/static/copy'

    use Rack::Static::Copy, :store   => "/path/to/app/root/static",
                              :ignore  => [ "search", "js", "png", "gif" ],
                              :timeout => 600

    run App


> Note: This should probably be the last middleware loaded.

### Another Use

Additionally, you can use Rack::Static::Save alone to simple create a copy
of your pages in rendered html format (other formats are supported).

Exmaple:

    # config.ru
    require 'rack/static/save'

    use Rack::Static::Save, :store   => "/path/to/nginx/root/static",
                              :ignore  => [ "search", "js", "png", "gif" ]

    run App


From there you can use Nginx to first check and see if the static pages exist
and if not, load your app normally, which will in turn generate the static
content.

Very large speed enhancments should be see doing this.

Sample benchmark:



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



