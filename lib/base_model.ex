defmodule BaseModel do
  @moduledoc ~S"""
  BaseModel provides a simple set of CRUD functions to an Ecto Model via a
  `__using__` macro.  For Example:

  ```elixir
  defmodule Db.Models.Person do
    use BaseModel, repo: Db.Repo

    schema "persons" do
      field :name, :string
      field :age, :integer
    end
  end
  ```

  The `use BaseModel` line adds the following methods to the Person Model:

  - `Person.create(params)`
  - `Person.all(opts \\ [order_by: :none, preload: []])`
  - `Person.find(id, opts \\ [preload: []])`
  - `Person.first(where, opts \\ [preload: []])`
  - `Person.first(where_clause, opts \\ [order_by: :none, preload []])`
  - `Person.first_or_create(where_clause, opts \\ [order_by: :none, preload []])`
  - `Person.where(where_clause, opts \\ [order_by: :none, limit: :none, preload: []])`
  - `Person.count(where_clause \\ [])`
  - `Person.delete(id_or_struct)`
  - `Person.delete_all()`
  - `Person.delete_where(where_clause)`
  - `Person.update(model, params)`
  - `Person.update_where(where_clause, params)`

  This model can now be interacted with in a more fluent manner than raw ecto:
  ```elixir
  iex> {:ok, model} = Person.create(name: "chris", age: 99)
  {:ok, %Person{name: "chris", age: 99}}
  iex> Person.update(model, age: 18)
  {:ok, %Person{name: "chris", age: 18}}
  iex> Person.where(age: 18)
  [%Person{name: "chris", age: 18}]
  ```
  """

  @type params :: map | Keyword.t()
  @type model :: map
  @callback create_changeset(params) :: Ecto.Changeset.t()
  @callback update_changeset(model, params) :: Ecto.Changeset.t()

  @doc """

  """
  defmacro __using__(repo: q_repo) do
    quote do
      use Ecto.Schema
      # the injected functions call the functions in BaseModel.Functions to
      # keep this short and sweet.
      alias BaseModel.Functions, as: BMF
      @__repo unquote(q_repo)
      @__doc_module Module.split(__MODULE__) |> Enum.reverse() |> hd
      @__repo_mod {@__repo, __MODULE__}

      @behaviour BaseModel
      @type t :: %__MODULE__{}
      @type opts :: Keyword.t()
      @type params :: map | Keyword.t()
      # NOTE: find a way to make this dynamic, if possible.
      @type pk :: any
      @type where_clause :: Keyword.t()
      ###########################
      #  Inserted API Functions
      ###########################

      @doc """
      Returns a list of all #{@__doc_module}s stored in the database

      valid `opts`:
        - `:order_by` - accepts the same arguments as Ecto's `order_by`
        - `:preload`  -  accepts the same arguments as Ecto's `preload`

      ### Examples
      ```elixir
      iex> #{@__doc_module}.all()
      ...> #{@__doc_module}.all(order_by: field)
      ...> #{@__doc_module}.all(order_by: [desc: field])
      ```
      """
      @spec all(opts) :: [t]
      def all(opts \\ []), do: BMF.all(@__repo_mod, opts)

      @doc """
      Creates a #{@__doc_module}, using either a Keyword list or a Map of keys
      and values.

      The `create` method calls `create_changeset/1`, which by default only
      strips fields from the Primary Key, but can be overridden by this module.
      If `create_changeset/1` is overridden, it must accept a map of keys/values
      and must return an `Ecto.Changeset`.

      Returns `{:ok, model}` or `{:error, reason}`

      ```elixir
      iex> #{@__doc_module}.create(%{field => value})
      ```
      """
      @spec create(params) :: {:ok, t} | {:error, any}
      def create(args), do: BMF.create(@__repo_mod, args)

      @doc """
      Finds a #{@__doc_module} based on primary key.

      Returns the record struct if the key exists in the database, otherwise
      `nil`

      valid `opts`:
        - `:preload`  -  accepts the same arguments as Ecto's `preload`
      """
      @spec find(pk, opts) :: t | nil
      def find(id, opts \\ []), do: BMF.find(@__repo_mod, id, opts)

      @doc """
      Returns a list of #{@__doc_module}s that match the where clause, subject
      to the limitations of `opts`

      valid `opts`:
        - `:order_by` -  accepts the same arguments as Ecto's `order_by`
        - `:limit`    -  max number of records to return
        - `:preload`  -  accepts the same arguments as Ecto's `preload`
      """
      @spec where(where_clause) :: [t]
      @spec where(where_clause, opts) :: [t]
      def where(where_clause, opts \\ []), do: BMF.where(@__repo_mod, where_clause, opts)

      @doc """
      Counts the number of #{@__doc_module}s that match the where clause
      (default is all). Where clause may be a Keyword list or a Map.

      ### Examples
      ```elixir
      iex> #{@__doc_module}.count()
      ...> #{@__doc_module}.count(%{field => value})
      ```
      """
      @spec count() :: non_neg_integer
      @spec count(where_clause) :: non_neg_integer
      def count(where_clause \\ []), do: BMF.count(@__repo_mod, where_clause)

      @doc """
      Deletes a #{@__doc_module} by primary key or by passing the model.
      returns

      ### Examples
      ```elixir
      iex> #{@__doc_module}.delete(1)
      ...> {:ok, struct} = #{@__doc_module}.create(params)
      ...> #{@__doc_module}.delete(struct)
      ```
      """
      @spec delete(pk | t) :: :ok | {:error, any}
      def delete(id_or_struct), do: BMF.delete(@__repo_mod, id_or_struct)

      @doc """
      Deletes all #{@__doc_module}s matching the where clause.  Where clause may
      be a Keyword list or a Map.

      ### Examples
      ```elixir
      iex> #{@__doc_module}.delete_where(%{field => value})
      """
      @spec delete_where(where_clause) :: {:ok, non_neg_integer}
      def delete_where(where_clause), do: BMF.delete_where(@__repo_mod, where_clause)

      @doc """
      Delete all records from the table.

      Returns {:ok, count} if successful.
      """
      @spec delete_all() :: {:ok, non_neg_integer}
      def delete_all, do: BMF.delete_all(@__repo_mod)

      @doc """
      Updates a model's fields as set in `params`.  Accepts a #{@__doc_module}
      struct and either a Keyword list or Map of params.

      Like `create/1`, update will call the models `update_changeset/2` method
      to validate and clean the params passed in.  By default, update changeset
      allows updating any field that is not part of the table's primary key.

      Returns {:ok, updated_model} when successful.
      """
      @spec update(t, params) :: {:ok, t} | {:error, any}
      def update(model, params), do: BMF.update(@__repo_mod, model, params)

      @doc """
      Updates all #{@__doc_module}s that match the where clause with the given
      params.

      **Important**: This method does not call `update_changeset/2`, and should
      not be used with untrusted inputs.
      """
      @spec update_where(where_clause, params) :: {:ok, non_neg_integer}
      def update_where(where_clause, params),
        do: BMF.update_where(@__repo_mod, where_clause, params)

      @doc """
      Returns the first record to match the where clause, or nil if no match

      valid opts:
      - order_by
      - preload
      """
      @spec first(where_clause) :: nil | t
      @spec first(where_clause, opts) :: nil | t
      def first(where_clause, opts \\ []), do: BMF.first(@__repo_mod, where_clause, opts)

      @doc """
      Queries for a record, and creates it if nothing matches the query

      Returns the first record to match the where clause, or the newly created record

      valid opts:
      - order_by
      - preload
      """
      @spec first_or_create(where_clause) :: t
      @spec first_or_create(where_clause, opts) :: t
      def first_or_create(where_clause, opts \\ []),
        do: BMF.first_or_create(@__repo_mod, where_clause, opts)

      ####################################
      #  Overrideable Callback Functions
      ####################################
      @impl BaseModel
      def create_changeset(params), do: BMF.create_changeset(@__repo_mod, params)

      @impl BaseModel
      def update_changeset(model, params), do: BMF.update_changeset(@__repo_mod, model, params)

      defoverridable create_changeset: 1,
                     # override these to provide custom validation / data hygiene
                     update_changeset: 2,

                     # overriding these is not common, but supported. Good luck.
                     all: 0,
                     all: 1,
                     create: 1,
                     find: 1,
                     find: 2,
                     first: 1,
                     first: 2,
                     first_or_create: 1,
                     first_or_create: 2,
                     where: 1,
                     where: 2,
                     count: 0,
                     count: 1,
                     delete: 1,
                     delete_where: 1,
                     update: 2,
                     update_where: 2
    end
  end
end
