# IdempotentBlock

This gem execute passed block by once using database unique key.  

```ruby
class IdempotentExecutor < ApplicationRecord
  #  user_id             :bigint(8)      not null
  #  type                :integer(11)    not null
  #  signature           :string(255)    not null
  #  expired_time        :datetime       not null
  #
  # Indexes
  #
  #  unique_index  (user_id, type, signature) UNIQUE

  include IdempotentBlock
end

exec = IdempotentExecutor.new(user_id: user.id, type: :post_create, signature: 'abcdefg')
exec.start do
  user.user_posts.create(params[:new_post])
end

# we don't execute block and raise IdempotentBlock::IdempotentError
exec.start do
  user.user_posts.create(params[:new_post])
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'idempotent_block'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install idempotent_block

## Usage

### Basic
```ruby
exec_1 = IdempotentExecutor.new(user_id: user.id, type: :post_create, signature: 'abcdefg')

# first time, we got no error and executed block 
exec_1.finished?
# => false

exec.start do
  user.user_posts.create(params[:new_post])
end

user.user_posts.count
# => 1

exec_1.finished?
# => true

exec_1.executed?
# => true

# second time, we didn't execute block
exec_2 = IdempotentExecutor.new(user_id: user.id, type: :post_create, signature: 'abcdefg')
exec_2.finished?
# => true
exec_2.executed?
# => false

exec_2.start do
  user.user_posts.create(params[:new_post])
end

user.user_posts.count
# => 1 we don't execute block

exec_2.finished?
# => true
exec_2.executed?
# => false
```

### Force execute
When you pass force option, we always execute block and update state.

```ruby
exec.finished?
# => true

exec.start(force: true) do
  user.user_posts.create(params[:new_post])
end

exec.executed?
# => true
```

### Stop execute block
If you raise error in block, we stop execute block and rollback state.

```ruby
exec.start do
  raise 'error'
end

# when retry, execute block because above block didn't completed
exec.start do
  user.user_posts.create(params[:new_post])
end

```

## Background
```ruby
exec = IdemponentExecutor.new(user_id: user.id, type: :post_create, signature: 'abcdefg')
exec.start do
  user.user_posts.create(params[:new_post])
end
```

We use transaction so we rewrite this code like this. 

```
exec = IdempotentExecutor.new(user_id: user.id, type: :post_create, signature: 'abcdefg')

now = Time.current
ActiveRecord::Base.transaction do
  r = IdempotentExecutor.find_by(user_id: user_id, type: type, signature: signature)
  if r
    exec.finish = true
    break unless force
  end 

  user.user_posts.create(params[:new_post])

  begin
    exec.save!
    exec.executed = true
  rescue => ActiveRecord::RecordNotUnique
    exec.executed = false
  end 
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/idempotent_block. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the IdempotentBlock project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/idempotent_block/blob/master/CODE_OF_CONDUCT.md).
