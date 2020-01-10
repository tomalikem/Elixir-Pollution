defmodule Mod do

  defstruct a: 0, b: 0

end

defmodule Testing do
  @moduledoc false

  def test() do
    map = %{}
    val1 = %Mod{a: 1, b: 1}
    val2 = %Mod{a: 2, b: 2}
    key1 = "key"
    key2 = "key"

    map = Map.put(map, "key", [])
    map = Map.update(map, key1 ,[], fn x -> put(x, val1) end)
    map = Map.update(map, key2 ,[], fn x -> put(x, val2) end)

  end

  def put(list, val)do
    [val | list]
  end

end
