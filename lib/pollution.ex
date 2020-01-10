defmodule Station do

  defstruct location: {0,0},  sensors: %{}

end


defmodule Data do

  defstruct date: 0, time: 0, value: 0

end

defmodule Pollution do
  @moduledoc false


  def import(filename \\ "pollution.csv") do
    File.read!(filename) |> String.split("\r\n")
  end

  def create_monitor() do
    %{}
  end

  def parse_line(line) do

    {s_date, s_time, s_x, s_y, s_value} = line |> String.split(",") |> :erlang.list_to_tuple
    date = s_date |> String.split("-") |> Enum.reverse |> Enum.map(&String.to_integer/1) |> :erlang.list_to_tuple
    time = s_time |> String.split(":") |> Enum.map(&String.to_integer/1) |> :erlang.list_to_tuple
    location = {s_x |> String.to_float, s_y |> String.to_float,}
    value = s_value |> String.to_integer
    {date, time, location, value}

  end

  def parse_data(line) do

    {date, time, {x,y}, value} = parse_line(line)
    {"station_#{x}_#{y}", "PM10", %Data{date: date, time: time, value: value}}

  end

  def parse_station(line) do

    {s_date, s_time, {x, y}, s_value} = parse_line(line)
    station = %Station{location: {x, y}, sensors: %{"PM10" => []}}
    {"station_#{x}_#{y}", station}

  end

  def load_stations(stations) do

    list = import() |> Enum.map(&parse_station/1)
    map = for e <- list, into: %{}, do: e
    map

  end

  def load_data(stations) do

      data_load = import() |> Enum.map(&parse_data/1)

      Enum.reduce(data_load, stations, fn data, stations -> put_data(data, stations) end)

  end

  def put_data(data, stations) do

    {key, param, value} = data
    stations = Map.update(stations, key, %Station{}, fn station -> put_to_sensor(station, param, value) end)
    stations

  end

  def put_to_sensor(station, param, value) do
    station = %{station | sensors: Map.update(station.sensors, param, [], fn sensor -> [value | sensor] end)}
    station

  end

  def get_mean(sensor)do Enum.reduce(sensor, {0,0}, fn data, {amount, sum} -> {amount + 1, sum + data.value}end) end

  def get_station_mean(stations, station_key, param) do

    station = Map.get(stations, station_key)
    sensor = Map.get(station.sensors, param)
    {amount, sum} = get_mean(sensor)
    sum / amount

  end

  def get_daily_mean(stations, date, param) do
    {amount, sum} = Enum.reduce(stations, {0,0}, fn station, {amount, sum} ->
      {d_amount,d_sum} = get_daily_station_mean(station, date, param); {amount + d_amount, sum + d_sum} end)
    sum / amount
  end

  def get_daily_station_mean(station, date, param) do

    {key, value} = station
    sensor = Map.get(value.sensors, param)
    sensor = daily_filter(sensor, date)
    mean = get_mean(sensor)
  end

  def daily_filter(sensor, date) do
    Enum.filter(sensor, fn data -> if(data.date == date)do true else false end end)
  end

  def test() do
    stations = %{}
    stations = load_stations(stations)
    stations = load_data(stations)
    get_daily_mean(stations, {2017, 5, 3}, "PM10")

  end

  def load_station_time() do
    stations = %{}
    fn -> load_stations(stations) end |> :timer.tc |> elem(0)
  end

  def load_data_time() do
    stations = %{}
    stations = load_stations(stations)
    fn -> load_data(stations) end |> :timer.tc |> elem(0)
  end

end



