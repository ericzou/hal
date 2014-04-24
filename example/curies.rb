# {
#   "_links": {
#     "self": { "href": "/orders" },
#     "curies": [{
#       "name": "acme",
#       "href": "http://docs.acme.com/relations/{rel}",
#       "templated": true
#     }],
#     "acme:widgets": { "href": "/widgets" }
#   }
# }
# acme:widgets : http://docs.acme.com/relations/widgets,

require 'hal'
require "active_support/core_ext/module/delegation"


class User < Struct.new(:name, :title, :id)
end

user = User.new('foo', 'Dr', 1)

class UserSerializer
  include Hal::Serializer
  attr_accessor :user

  delegate :name, :title, to: :user

  def initialize(user)
    @user = user
  end

  def attributes
    [:name, :title]
  end

  def links
    curies do |curi|
      curi :ht, href: '/href', templated: true
    end

    namespaces do |ns|
      ns
    end

    relation :self, { href: "http://yourapp.com/users/#{@user.id}" }
    relation [:ht, :account], { href: "http://yourapp.com/users/#{@user.id}" }
  end
end

if __FILE__ == $0
  json = Hal.json(user, pretty: true)
  puts "============", json, "============"
end


# {
#   "_links": {
#     "self": {
#       "href": "/"
#     },
#     "curies": [
#       {
#         "name": "ht",
#         "href": "http://haltalk.herokuapp.com/rels/{rel}",
#         "templated": true
#       }
#     ],
#     "ht:users": {
#       "href": "/users"
#     },
#     "ht:signup": {
#       "href": "/signup"
#     },
#     "ht:me": {
#       "href": "/users/{name}",
#       "templated": true
#     },
#     "ht:latest-posts": {
#       "href": "/posts/latest"
#     }
#   },
#   "welcome": "Welcome to a haltalk server.",
#   "hint_1": "You need an account to post stuff..",
#   "hint_2": "Create one by POSTing via the ht:signup link..",
#   "hint_3": "Click the orange buttons on the right to make POST requests..",
#   "hint_4": "Click the green button to follow a link with a GET request..",
#   "hint_5": "Click the book icon to read docs for the link relation."
# }
