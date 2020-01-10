defmodule PolGen do
  @moduledoc false
  


  use GenServer

  def start_link() do  GenServer.start_link(__MODULE__, :ok, []) end

  def init(_opts) do {:ok, Pollution.create_monitor} end

  def load_stations(server) do  GenServer.cast(server, :load_stations) end

  def load_data(server) do GenServer.cast(server, :load_data) end

  def get_station_mean(server, station, param) do GenServer.call(server, {:get_station_mean, station, param}) end

  def get_daily_mean(server, date, param) do GenServer.call(server, {:get_daily_mean, date, param}) end

  def handle_call(msg, _from, stations) do
    case msg do
      {:get_station_mean, station, param} -> {:reply, Pollution.get_station_mean(stations, station, param), stations}
      {:get_daily_mean, date, param} -> {:reply, Pollution.get_daily_mean(stations, date, param), stations}
    end

  end

  def handle_cast(msg, stations) do
    case msg do
      :load_stations -> {:noreply, Pollution.load_stations(stations)}
      :load_data -> {:noreply, Pollution.load_data(stations)}
    end
  end

  def test1() do
    {:ok, pid} = PolGen.start_link()
    PolGen.init(pid)
    PolGen.load_stations(pid)
    PolGen.load_data(pid)
    fn -> PolGen.get_station_mean(pid,"station_20.06_49.986", "PM10") end |> :timer.tc

  end

  def test2() do
    {:ok, pid} = PolGen.start_link()
    PolGen.init(pid)
    PolGen.load_stations(pid)
    PolGen.load_data(pid)
    fn -> PolGen.get_daily_mean(pid,{2017, 5, 3}, "PM10") end |> :timer.tc
  end



end