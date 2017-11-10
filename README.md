## BaseModel

ActiveRecord for Ecto.

[![Build Status](https://travis-ci.org/meyercm/base_model.svg?branch=master)](https://travis-ci.org/meyercm/base_model)

`{:base_model, "~> 0.1.0"},`

`BaseModel` provides a straightforward `__using__` macro to include common CRUD
functions in your models:

* `create(params)`
* `all()`
* `count(where_clause \\ :anything)`
* `find(id)`
* `where(where_clause)`
* `update(model, params)`
* `update_where(where_clause, params)`
* `delete(id)`
* `delete_where(where_clause)`
* `delete_all`

All of these are overridable, and where appropriate, support options including
`:limit`, `:preload`, and `:order_by`.  Custom create and update validation is
possible by overriding `create_changeset/1` or `update_changeset/1` in the
model.

### Example

A model taken from the [example app](examples/example_app):

```elixir
defmodule ExampleApp.Models.User do
  use BaseModel, repo: ExampleApp.Repo
  alias ExampleApp.Models.Problem

  schema "users" do
    field :name, :string
    field :age, :integer
    has_many :problems, Problem
    timestamps()
  end
end
```

Because ExampleApp.Repo has been specified in the `use` directive, BaseModel
methods can omit it:

```elixir
iex> alias ExampleApp.Models.User
...> {:ok, chris} = User.create(name: "chris")
{:ok, %User{name: "chris", age: nil}}
...> User.update(chris, age: -1)
{:ok, %User{name: "chris", age: -1}}
...> User.count
1
...> User.where(name: "chris")
[%User{name: "chris", age: -1}]
```

### Getting Started

1. Setup your repo as you normally would, and create your models as usual.
2. To each model, add `use BaseModel, repo: YourApp.Repo`
3. Profit!

### Associations

`:belongs_to` associations can be specified during `create`, and can be used in
any query or params list, e.g.:

```elixir
iex> {:ok, chris} = User.create(name: "chris")

# BaseModel will do the field mapping for you if you pass a struct to the association
...> Problem.create(user: chris, description: "...so I used regular expressions.")
# Or you could do it yourself:
...> Problem.create(user_id: chris.id, description: "now I have 100 problems.")

# In query-mode: (also works for `where`, `count`, `update_where`)
...> Problem.delete_where(user: chris)
{:ok, 2}
```

### Opts

BaseModel methods support an optional `opts` parameter, which accepts 3 values:

- `:preload`
- `:limit`
- `:order_by`

Each of these operates as a direct pass-thru to `Ecto`, so see their
documentation on available use. Note that these opts are sensibly applied, e.g.
passing `:limit` to `count` is ignored, etc.

```elixir
iex> User.find(1, preload: :problems)
%User{name: "chris", problems: []}
```

### Overriding `*_changeset` methods

TODO

### Closing comments

I wrote the first version of `BaseModel` back when Elixir 0.13 was the new
hotness and I was missing my old friend, ActiveRecord. I've found this query
interface suitable for many use-cases, but as soon as I have a need for a more
complicated query, I simply add it as a new method on the model.  This way, all
of my Ecto code lives in the models, and in the models only.  The sanity gained
from not spreading Ecto calls directly into the business logic cannot be
overstated.

Please drop me a note if you end up using BaseModel in something cool, or file
an issue if you have difficulty, bugs, or ideas for a better API.
