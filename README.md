# Hal

Hal is a gem for generating Hyptertext Application Language(HAL) formatted JSON

## Installation

## Usage

Hal does very little magic and does not assume a lot of things. A simple example for serializing a resouce into HAL formatted JSON looks like this

```ruby
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
    relation :self, { href: "http://yourapp.com/users/#{@user.id}" }
  end
end
```

This will generate this following JSON

```json
{
  "_links": {
    "self": {
      "href": "http://yourapp.com/users/1"
    }
  },
  "name": "foo",
  "title": "Dr"
}
```
