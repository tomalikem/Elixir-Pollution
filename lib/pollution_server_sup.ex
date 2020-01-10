defmodule PollutionServerSup.Supervisor do
  @moduledoc false
  


  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init() do
    children = [
      worker(PollutionGenSever, [], restart: :temporary)
    ]

    supervise(children, strategy: :one_for_one)
  end
end