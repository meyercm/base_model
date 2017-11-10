defmodule BaseModel do
  @moduledoc """

  """

  defmacro __using__(repo: q_repo) do
    quote do
      use Ecto.Schema
      # the injected functions call the functions in BaseModel.Functions to
      # keep this short and sweet.
      alias BaseModel.Functions, as: BMF
      @__repo unquote(q_repo)
      @__doc_module Module.split(__MODULE__) |> Enum.reverse |> hd
      @__repo_mod {@__repo, __MODULE__}

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
      def create(args), do: BMF.create(@__repo_mod, args)

      @doc """
      Finds a #{@__doc_module} based on primary key.

      Returns the record struct if the key exists in the database, otherwise
      `nil`

      valid `opts`:
        - `:preload`  -  accepts the same arguments as Ecto's `preload`
      """
      def find(id, opts \\ []), do: BMF.find(@__repo_mod, id, opts)

      @doc """
      Returns a list of #{@__doc_module}s that match the where clause, subject
      to the limitations of `opts`

      valid `opts`:
        - `:order_by` -  accepts the same arguments as Ecto's `order_by`
        - `:limit`    -  max number of records to return
        - `:preload`  -  accepts the same arguments as Ecto's `preload`
      """
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
      def count(where_clause \\ []), do: BMF.count(@__repo_mod, where_clause)

      @doc """
      Deletes a #{@__doc_module} by primary key.
      returns

      ### Examples
      ```elixir
      iex> #{@__doc_module}.delete(1)
      ```
      """
      def delete(id), do: BMF.delete(@__repo_mod, id)

      @doc """
      Deletes all #{@__doc_module}s matching the where clause.  Where clause may
      be a Keyword list or a Map.

      ### Examples
      ```elixir
      iex> #{@__doc_module}.delete_where(%{field => value})
      """
      def delete_where(where_clause), do: BMF.delete_where(@__repo_mod, where_clause)

      @doc """
      Delete all records from the table.

      Returns {:ok, count} if successful.
      """
      def delete_all, do: BMF.delete_all(@__repo_mod)

      @doc """
      Updates a model's fields as set in `params`.  Accepts a #{@__doc_module}
      struct and either a Keyword list or Map of params.

      Like `create/1`, update will call the models `update_changeset/2` method
      to validate and clean the params passed in.  By default, update changeset
      allows updating any field that is not part of the table's primary key.

      Returns {:ok, updated_model} when successful.
      """
      def update(model, params), do: BMF.update(@__repo_mod, model, params)

      @doc """
      Updates all #{@__doc_module}s that match the where clause with the given
      params.

      **Important**: This method does not call `update_changeset/2`, and should
      not be used with untrusted inputs.
      """
      def update_where(where_clause, params), do: BMF.update_where(@__repo_mod, where_clause, params)

      @doc """
      Returns the first record to match the where clause, or nil if no match

      valid opts:
      - order_by
      - preload
      """
      def first(where_clause, opts \\ []), do: BMF.first(@__repo_mod, where_clause, opts)

      @doc """
      Queries for a record, and creates it if nothing matches the query

      Returns the first record to match the where clause, or the newly created record

      valid opts:
      - order_by
      - preload
      """
      def first_or_create(where_clause, opts \\ []), do: BMF.first_or_create(@__repo_mod, where_clause, opts)

      ####################################
      #  Overrideable Callback Functions
      ####################################

      def create_changeset(params), do: BMF.create_changeset(@__repo_mod, params)

      def update_changeset(model, params), do: BMF.update_changeset(@__repo_mod, model, params)

      defoverridable [
        # override these to provide custom validation / data hygiene
        create_changeset: 1,
        update_changeset: 2,

        # overriding these is not common, but supported. Good luck.
        all: 0,
        all: 1,
        create: 1,
        find: 1,
        find: 2,
        where: 1,
        where: 2,
        count: 0,
        count: 1,
        delete: 1,
        delete_where: 1,
        update: 2,
        update_where: 2,

      ]

    end
  end

end
