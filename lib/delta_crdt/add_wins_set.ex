defmodule DeltaCrdt.AddWinsSet do
  defstruct state: %DeltaCrdt.Causal{state: %DeltaCrdt.DotMap{}}

  def replace_bottom(:bottom), do: %DeltaCrdt.DotMap{}
  def replace_bottom(state), do: state

  def add(%{state: %{state: s, context: c}}, i, e) do
    s = replace_bottom(s)
    d = [DeltaCrdt.Causal.next(c, i)] |> Enum.into(MapSet.new())
    new_c = Map.get(s.map, e, %DeltaCrdt.DotSet{}).dots |> MapSet.union(d)

    %__MODULE__{
      state: %DeltaCrdt.Causal{
        context: new_c,
        state: %DeltaCrdt.DotMap{
          map: %{
            e => %DeltaCrdt.DotSet{
              dots: d
            }
          }
        }
      }
    }
  end

  def add(map, i, e), do: add(%{state: map}, i, e)

  def remove(%{state: %{state: s, context: c}}, i, e) do
    d = [DeltaCrdt.Causal.next(c, i)] |> Enum.into(MapSet.new())

    %__MODULE__{
      state: %DeltaCrdt.Causal{
        context:
          DeltaCrdt.DotStore.dots(Map.get(s.map, e, %DeltaCrdt.DotSet{}))
          |> Enum.into(MapSet.new()),
        state: %DeltaCrdt.DotMap{}
      }
    }
  end

  def clear(%{state: %{state: s, context: c}}, _i) do
    %__MODULE__{
      state: %DeltaCrdt.Causal{
        context: DeltaCrdt.DotStore.dots(s) |> Enum.into(MapSet.new()),
        state: %DeltaCrdt.DotMap{}
      }
    }
  end

  def read(%{state: %{state: %{map: map}, context: c}} = thing) do
    Map.keys(map)
  end
end
