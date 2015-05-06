# Etikett

## Installation

Require `etikett` in your Gemfile
```ruby
gem 'etikett', github: 'metaminded/etikett'
```
After that run `bundle install`. Copy the provided migrations with `rake etikett_engine:install:migrations` and
execute `rake db:migrate` to run them.

## Usage

Include `Etikett::Taggable` in your models to make use of the provided features.

```ruby
class Company < ActiveRecord::Base
  include Etikett::Taggable
end

class User < ActiveRecord::Base
  include Etikett::Taggable
end
```

### master_tag

With that you'll be able to use the `master_tag` method which creates an unique tag-identifier for each object. It receives a block which should return a Hash with at least a `sid` key and an optional `title` key.

```ruby
class Company < ActiveRecord::Base
  include Etikett::Taggable
  
  master_tag do
    {sid: self.title}
  end
end

# ...

c = Company.create(title: 'Porsche')
c.master_tag.sid # => 'Porsche'
c.update(title: 'Ferrari')
c.master_tag.sid # => 'Ferrari'
```

### has_many_tags

`has_many_tags` enables you to create associations between your object and tags.
```ruby
class Company < ActiveRecord::Base
  include Etikett::Taggable
  
  has_many_tags
  
  master_tag do
    {sid: self.title}
  end
end

# ...

c = Company.create!(title: 'Porsche')
c.tags << Tag.new(name: 'fast')
c.tags << Tag.new(name: 'expensive')
c.save
```

### has_many_via_tags

If you want to make associations to other objects through tags instead, you should use `has_many_via_tags`.

```ruby
class Company < ActiveRecord::Base
  include Etikett::Taggable
  
  has_many_via_tags :users
  
  master_tag do
    {sid: self.title}
  end
end

class User < ActiveRecord::Base
  include Etikett::Taggable
  
  master_tag do
    {sid: "#{first_name} #{last_name}"}
  end
end

c = Company.create(title: 'metaminded')
luke = User.create(first_name: 'Luke', last_name: 'Skywalker')
han  = User.create(first_name: 'Han', last_name: 'Solo')
c.user_tags << luke.master_tag
c.user_tags << han.master_tag
c.save
c.users.map(&:last_name) # => ['Skywalker', 'Solo'] 
c.user_tag_mappings.map{|tm| [tm.taggable.last_name, tm.typ, tm.tag.sid]}
# => [['Skywalker', 'users', 'metaminded'],['Solo', 'users', 'metaminded']]
```

