# Rosemary: OpenStreetMap for Ruby

[![Gem Version](https://fury-badge.herokuapp.com/rb/rosemary.png)](http://badge.fury.io/rb/rosemary)
[![Build Status](https://travis-ci.org/sozialhelden/rosemary.png?branch=master)](https://travis-ci.org/sozialhelden/rosemary)
[![Dependency Status](https://gemnasium.com/sozialhelden/rosemary.png)](https://gemnasium.com/sozialhelden/rosemary)
[![Coverage Status](https://coveralls.io/repos/sozialhelden/rosemary/badge.png)](https://coveralls.io/r/sozialhelden/rosemary)
[![Code Climate](https://codeclimate.com/github/sozialhelden/rosemary.png)](https://codeclimate.com/github/sozialhelden/rosemary)
[![License](http://img.shields.io/license/MIT.png?color=green) ](https://github.com/sozialhelden/rosemary/blob/master/LICENSE)
[![Gittip ](http://img.shields.io/gittip/sozialhelden.png)](https://gittip.com/sozialhelden)

This ruby gem is an API client for the current OpenStreetMap [API v0.6](http://wiki.openstreetmap.org/wiki/API_v0.6). It provides easy access to OpenStreetMap (OSM) data.

## What is OpenStreetMap?

OpenStreetMap (OSM) is a collaborative project to create a free editable map of the world. Two major driving forces behind the establishment and growth of OSM have been restrictions on use or availability of map information across much of the world and the advent of inexpensive portable GPS devices.


## The OpenStreetMap Database

OpenStreetMap data is published under an open content license, with the intention of promoting free use and re-distribution of the data (both commercial and non-commercial). The license currently used is the [Creative Commons Attribution-Share Alike 2.0 licence](http://creativecommons.org/licenses/by-sa/2.0/); however, legal investigation work and community consultation is underway to relicense the project under the [Open Database License (ODbL)](http://opendatacommons.org/licenses/odbl/) from [Open Data Commons (ODC)](http://opendatacommons.org/), claimed to be more suitable for a map data set.

## Input Data

All data added to the project need to have a license compatible with the Creative Commons Attribution-Share Alike license. This can include out of copyright information, public domain or other licenses. All contributors must register with the project and agree to provide data on a Creative Commons CC-BY-SA 2.0 licence, or determine that the licensing of the source data is suitable; this may involve examining licences for government data to establish whether they are compatible.
Due to the license switch, data added in future must be compatible with both the Open Database License and the new Contributor Terms in order to be accepted.

## Installation

Put this in your Gemfile

    # Gemfile
    gem 'rosemary', :git => 'git://github.com/sozialhelden/rosemary'

Then run

    bundle install

## Getting started

OK, gimme some code:

    require 'rosemary'
    api = Rosemary::Api.new
    node = api.find_node(123)
     => #<Rosemary::Node:0x1019268d0 @changeset=7836598, @timestamp=Mon Apr 11 19:40:43 UTC 2011, @user="Turleder'n", @tags={}, @uid=289426, @version=4, @lat=59.9502252, @id=123, @lon=10.7899133>

## Testing your code

You should try your code on the OSM testing server first! You can change the url like this:

    require 'rosemary'
    Rosemary::Api.base_uri 'http://api06.dev.openstreetmap.org/'
    api = Rosemary::Api.new
    api.find_node(123)

Modification of data is supported too. According to the OSM license every modification to the data has to be done by a registered OSM user account. The user can be authenticated with username and password. But see yourself:

    client = Rosemary::BasicAuthClient.new('osm_user_name', 'password')

    api = Rosemary::Api.new(client)
    changeset = api.create_changeset("Some meaningful comment")
    node = Rosemary::Node.new(:lat => 52.0, :lon => 13.4)
    api.save(node, changeset)
    api.close_changeset(changeset)

Yeah, i can hear you sayin: 'Seriously, do i have to provide username and password? Is that secure?' Providing username and password is prone to some security issues, especially because the OSM API does not provide an SSL service. But wait, there is some more in store for you: [OAuth](http://oauth.net/) It's much more secure for the user and your OSM app. But it comes with a price: You have to register an application on http://www.openstreetmap.org. After you have your app registered you get an app key and secret. Keep it in a safe place.

    consumer = OAuth::Consumer.new( 'osm_app_key', 'osm_app_secret',
                                    :site => 'http://www.openstreetmap.org')
    access_token = OAuth::AccessToken.new(consumer, 'osm_user_token', 'osm_user_key')
    client = Rosemary::OauthClient.new(access_token)

    api = Rosemary::Api.new(client)
    changeset = api.create_changeset("Some meaningful comment")
    node = Rosemary::Node.new(:lat => 52.0, :lon => 13.4)
    api.save(node, changeset)
    api.close_changeset(changeset)

Every request to the API is now handled by the OauthClient.


## Feedback and Contributions

We appreciate your feedback and contributions. If you find a bug, feel free to to open a GitHub issue. Better yet, add a test that exposes the bug, fix it and send us a pull request.