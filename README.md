# rack/static-copy

Why?

This will store a static copy of your processed page so that
you can load it through a web server. Much faster, no?

This is was designed around NestaCMS and other simple CMS
applications and don't require dynamic content.


### Installation

    echo "gem 'rack-static-copy'" >> Gemfile
    bundle

### Usage

    # config.ru
    require 'rack/static-copy'
    use Rack::StaticCopy, :store  => "/path/to/nginx/root/static",
                          :ignore => [ "search", "js", "png", "gif" ]
    run App

### Nginx example config:

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



