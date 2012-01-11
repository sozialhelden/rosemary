# rOSM- OpenStreetMap for ruby

[![alt text][2]][1]

  [1]: http://travis-ci.org/#!/sozialhelden/rosm
  [2]: https://secure.travis-ci.org/sozialhelden/rosm.png

This is an API client for the current OpenStreetMap API v0.6

It provides easy access to OpenStreetMap (OSM) data. OK, gimme some code:

    require 'rosm'
    api = OpenStreetMap::Api.new
    node = api.find_node(123)
     => #<OpenStreetMap::Node:0x1019268d0 @changeset=7836598, @timestamp=Mon Apr 11 19:40:43 UTC 2011, @user="Turleder'n", @tags={}, @uid=289426, @version=4, @lat=59.9502252, @id=123, @lon=10.7899133>

Modification of data is supported too.

    client = OpenStreetMap::BasicAuthClient('osm_user_nane', 'password')
    api = OpenStreetMap::Api.new(client)
    node = OpenStreetMap::Node.new(:lat => 52.0, :lon => 13.4)
    api.save(node)

Yeah, i can hear you sayin: 'Seriously, do i have to provide username and password? Is that secure?' Providing username and password is prone to some security issues, especially because the OSM API does not provide an SSL service. But wait, there is some more in store for you: OAuth! It's much more secure for the user and your OSM app. But it comes with a price: You have to register an application on http://www.openstreetmap.org. After you have your app registered you get an app key and secret. Keep it in a save place.

    consumer = OAuth::Consumer.new(  'osm_app_key', 'osm_app_secret',
                          { :site => 'http://www.openstreetmap.org',
                            :request_token_path => '/oauth/request_token',
                            :access_token_path => '/oauth/access_token',
                            :authorize_path => '/oauth/authorize'
                          })
    access_token = OAuth::AccessToken(consumer, 'osm_user_token', 'osm_user_key')
    client = OpenStreetMap::OauthClient(access_token)
    api = OpenStreetMap::Api.new(client)
    node = OpenStreetMap::Node.new(:lat => 52.0, :lon => 13.4)
    api.save(node)

Every request to the API which requires authentication, which is mainly write access, is now handled by the OauthClient. Does that sound good?

The locale can be determined from four different sources: host name, path prefix, query parameter and the Accept-Language header.

Each of the following URLs will set the locale to 'es' (Spanish):

    http://es.example.org
    http://example.org/es
    http://example.org?locale=es

as will the following request:

    GET / HTTP/1.1
    Host: example.org
    Accept-Language: es


### Using it with Rails

    # file application.rb

    require  'rack/i18n_locale_switcher'
    config.middleware.use Rack::I18nLocaleSwitcher

If you use Rails 3.1 with the asset pipeline, make sure you exclude the path to assets:

    config.middleware.use Rack::I18nLocaleSwitcher, :except => /^\/assets/

### Using it with Sinatra

    require 'rack/i18n_locale_switcher'
    use Rack::I18nLocaleSwitcher


## Configuration options


### Source

The sources from which the locale is determined and the order in which they are probed can be specified with the `source` option. By default this is `[ :param, :path, :host, :header ]`. In case ambiguous locales are provided such as in `en.example.org/de`, the path (de) will have precedence over the host (en), due to its higher order.

If you want to support only one source, which is strongly encouraged, you can configure the middleware using the `source` option:

    use Rack::I18nLocaleSwitcher, :source => [ :path, :header ]

You might always want to include `header` as the last option. In case no locale was specified in the URL (i.e. `http://example.org`) and you would otherwise fall back to the default locale, the user preferred locale as indicated in the Accept-Language header will always be the better choice.


### Redirect

If you allow more than one source (because you have to support a legacy URL scheme, for example) you can choose to redirect requests to the preferred scheme. Redirect is not enabled by default.

    use Rack::I18nLocaleSwitcher, :source => [ :path, :param, :header ], :redirect => :path

With this setup, a request to `https://example.org?locale=es` would be permanently redirected to `https://example.org/es`.


### Canonical URLs

Many sites have a default locale which is not part of the URL. Only if a different locale is requested, it will be indicated in the URL. For example, `www.apple.com` uses English by default while other languages have a prefix to the path such as `www.apple.com/jp/` for Japanese.

If no locale can be determined from the URL, the locale switcher falls back to the `I18n.default_locale`. However, depending on your application, this might result in the default locale to be available under two different URLs, such as `http://example.org` and `http://example.org/en`. The problem with this is mainly that search engines will see both URLs and consider it duplicate content resulting in your page rank taking a penalty.

To avoid this, you can set the `canonical` option resulting in requests to be redirected to the canonical URL (without the locale):

    use Rack::I18nLocaleSwitcher, :source => [ :host, :header ], :redirect => :path, :canonical => true

In this configuration, requests to `http://en.example.org` will be redirected to `http://example.org` (provided you have set `I18n.default_locale` to `:en`).

### Exceptions

If you would like to exclude certain paths from locale switcher, just pass a regex matching these paths in the `except` option.

    use Rack::I18nLocaleSwitcher, :redirect => :path, :except => /^\/(assets|static)\b/


## Configuring I18n

You have to define which locales are actually supported by your application. In Rails this happens automagically, in other application you have to set the available locales explicitely:

    I18n.available_locales = [:de, :en, :es, :it, :tr ]

You should also set the default locale to which Locale Switcher will fall back in case the locale can't be determined. This setting is also important if you use canonical URLs (see above).

    I18n.default_locale = :de


## Feedback and Contributions

We appreciate your feedback and contributions. If you find a bug, feel free to to open a GitHub issue. Better yet, add a test that exposes the bug, fix it and send us a pull request.