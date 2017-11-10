defmodule BaseModel.Functions do
  @moduledoc false
  import Ecto.Query, only: [from: 2]
  import ShorterMaps
  alias Ecto.{Query, Changeset, Association.BelongsTo}

  def all({repo, model}, opts) do
    model
    |> add_opts(opts, [:order_by, :preload])
    |> repo.all
  end

  def create({repo, model}, params) do
    params
    |> fix_params_assoc(model)
    |> model.create_changeset
    |> repo.insert
  end

  def find({repo, model}, id, opts) do
    [pk] = model.__schema__(:primary_key)
    (from x in model,
     where: field(x, ^pk) == ^id)
    |> add_opts(opts, [:preload])
    |> repo.one
  end

  def where({repo, model}, where_clause, opts) do
    where_clause = fix_where_assoc(where_clause, model)
    model
    |> add_where(where_clause)
    |> add_opts(opts, [:order_by, :limit, :preload])
    |> repo.all
  end

  def count({repo, model}, where_clause) do
    where_clause = fix_where_assoc(where_clause, model)
    model
    |> add_where(where_clause)
    |> Query.select([], count(1))
    |> repo.one
  end

  def delete({repo, model} = rm, %{__struct__: model} = record) do
    [pk] = model.__schema__(:primary_key)
    delete(rm, Map.fetch!(record, pk))
  end
  def delete({repo, model}, id) do
    [pk] = model.__schema__(:primary_key)
    case repo.delete_all(from x in model, where: field(x, ^pk) == ^id) do
      {1, _} -> :ok
      {0, _} -> {:error, :not_found}
    end
  end

  def delete_where({repo, model}, where_clause) do
    where_clause = fix_where_assoc(where_clause, model)
    model
    |> add_where(where_clause)
    |> repo.delete_all
    |> case do
      {n, _} -> {:ok, n}
    end
  end

  def delete_all({repo, model}) do
    model
    |> repo.delete_all
    |> case do
      {n, _} -> {:ok, n}
    end
  end

  def update({repo, model}, model_struct, params) do
    params = fix_params_assoc(params, model)
    model.update_changeset(model_struct, params)
    |> repo.update()
  end

  def update_where({repo, model}, where_clause, params) do
    where_clause = fix_where_assoc(where_clause, model)
    params = fix_params_assoc(params, model) |> Map.to_list
    model
    |> add_where(where_clause)
    |> repo.update_all(set: params)
    |> case do
      {n, _} -> {:ok, n}
    end
  end

  def first(repo_mod, where_clause, opts) do
    case where(repo_mod, where_clause, Keyword.merge(opts, [limit: 1])) do
      [] -> nil
      [result] -> result
    end
  end
  def first_or_create(repo_mod, where_clause, opts) do
    case where(repo_mod, where_clause, [{:limit, 1}|opts]) do
      [result] -> result
      [] ->
        {:ok, result} = create(repo_mod, where_clause)
        result
    end
  end

  # The default `*_changeset` functions accept any fields except those in the pk.
  def create_changeset({_repo, model}, params) do
    pk = model.__schema__(:primary_key)
    fields = model.__schema__(:fields) |> Enum.reject(fn f -> Enum.member?(pk, f) end)
    struct = model.__struct__
    Changeset.cast(struct, params, fields)
  end

  def update_changeset({_repo, model}, model_struct, params) do
    pk = model.__schema__(:primary_key)
    fields = model.__schema__(:fields) |> Enum.reject(fn f -> Enum.member?(pk, f) end)
    Changeset.cast(model_struct, params, fields)
  end

  # Internal functions
  def add_opts(query, [], _allowed_opts), do: query
  def add_opts(query, [{opt, opt_val}|rest], allowed_opts) do
    if opt in allowed_opts do
      apply_opt(query, opt, opt_val)
    else
      query
    end
    |> add_opts(rest, allowed_opts)
  end
  def apply_opt(query, :order_by, order_by), do: Query.order_by(query, ^order_by)
  def apply_opt(query, :limit, limit), do: Query.limit(query, ^limit)
  def apply_opt(query, :preload, preload), do: Query.preload(query, ^preload)

  def fix_where_assoc(where_clause, model) do
    for {field, value} <- where_clause do
      case model.__schema__(:association, field) do
        # only create keys for `belongs_to`, because this table has the foreign key
        ~M{%BelongsTo owner_key, related_key} ->
          {owner_key, Map.get(value, related_key)}
        _ -> {field, value}
      end
    end
  end

  # params needs to be a map
  def fix_params_assoc(params, model) do
    fix_where_assoc(params, model)
    |> Map.new
  end

  def add_where(query, []), do: query
  def add_where(query, [{f, nil}|rest]) do
    (from x in query,
     where: is_nil(field(x, ^f)))
    |> add_where(rest)
  end
  def add_where(query, [{f, v}|rest]) do
    query
    |> Query.where(^[{f, v}])
    |> add_where(rest)
  end
end
