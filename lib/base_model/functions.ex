defmodule BaseModel.Functions do
  @moduledoc false
  import Ecto.Query, only: [from: 2, from: 1]
  import ShorterMaps
  alias Ecto.{Query, Changeset, Association.BelongsTo}

  def all({repo, model}, opts) do
    query = case Keyword.get(opts, :order_by) do
      nil -> model
      order_by -> model |> Query.order_by(^order_by)
    end
    repo.all(query)
  end

  def create(repo_mod, args) when is_list(args), do: create(repo_mod, Enum.into(args, %{}))
  def create({repo, model}, args) do
    assoc_fields = model.__schema__(:associations)

    # This section handles populating foreign keys for `:belongs_to` associations
    new_args =
      for {field, value} <- args do
        case model.__schema__(:association, field) do
          ~M{%BelongsTo owner_key, related_key} ->
            {owner_key, Map.get(value, related_key)}
          _ -> nil
        end
      end |> Enum.reject(&is_nil/1) |> Map.new
    args = Map.merge(args, new_args)
    changeset = model.create_changeset(args)
    repo.insert(changeset)
  end

  def find({repo, model}, id, opts) do
    [pk] = model.__schema__(:primary_key)
    (from x in model,
     where: field(x, ^pk) == ^id)
    |> add_opts(opts, [:preload])
    |> repo.one
  end

  def where({repo, model}, where_clause, opts) do
    model
    |> Query.where(^where_clause)
    |> add_opts(opts, [:order_by, :limit, :preload])
    |> repo.all
  end

  def count({repo, model}, where_clause) do
    model
    |> Query.where(^where_clause)
    |> Query.select([], count(1))
    |> repo.one
  end

  def delete({repo, model}, id) do
    [pk] = model.__schema__(:primary_key)
    case repo.delete_all(from x in model, where: field(x, ^pk) == ^id) do
      {1, _} -> :ok
      {0, _} -> {:error, :not_found}
    end
  end

  def delete_where({repo, model}, where_clause) do
    model
    |> Query.where(^where_clause)
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

  def update(repo_mod, model_struct, param_list) when is_list(param_list) do
    update(repo_mod, model_struct, Enum.into(param_list, %{}))
  end
  def update({repo, model}, model_struct, params) do
    model.update_changeset(model_struct, params)
    |> repo.update()
  end

  def update_where(repo_mod, where_clause, param_map) when is_map(param_map) do
    update_where(repo_mod, where_clause, Map.to_list(param_map))
  end
  def update_where({repo, model}, where_clause, params) do
    model
    |> Query.where(^where_clause)
    |> repo.update_all(set: params)
    |> case do
      {n, _} -> {:ok, n}
    end
  end

  # The default `*_changeset` functions accept any fields except those in the pk.
  def create_changeset({repo, model}, params) do
    pk = model.__schema__(:primary_key)
    fields = model.__schema__(:fields) |> Enum.reject(fn f -> Enum.member?(pk, f) end)
    struct = model.__struct__
    Changeset.cast(struct, params, fields)
  end

  def update_changeset({repo, model}, model_struct, params) do
    pk = model.__schema__(:primary_key)
    fields = model.__schema__(:fields) |> Enum.reject(fn f -> Enum.member?(pk, f) end)
    Changeset.cast(model_struct, params, fields)
  end

  # Internal functions
  def add_opts(query, [], _allowed_opts), do: query
  def add_opts(query, [{opt, opt_val}|rest], allowed_opts) do
    if opt in allowed_opts, do: apply_opt(query, opt, opt_val), else: query
    |> add_opts(rest, allowed_opts)
  end
  def apply_opt(query, :order_by, order_by), do: Query.order_by(query, ^order_by)
  def apply_opt(query, :limit, limit), do: Query.limit(query, ^limit)
  def apply_opt(query, :preload, preload), do: Query.preload(query, ^preload)

end
