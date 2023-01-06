defmodule Poolex.Monitoring do
  @moduledoc """
  Interfaces to hide monitoring implementation.
  """
  @type monitor_id() :: atom() | reference()
  @type kind_of_process() :: :worker | :caller

  @spec init(Poolex.pool_id()) :: {:ok, monitor_id()}
  def init(pool_id) do
    monitor_id = :ets.new(:"#{pool_id}_references", [:set, :named_table, :private])

    {:ok, monitor_id}
  end

  @spec add(monitor_id(), pid(), kind_of_process()) :: :ok
  def add(monitor_id, process_pid, kind_of_process) do
    reference = Process.monitor(process_pid)
    :ets.insert_new(monitor_id, {reference, process_pid, kind_of_process})

    :ok
  end

  @spec remove(monitor_id(), reference()) :: kind_of_process()
  def remove(monitor_id, monitoring_reference) do
    true = Process.demonitor(monitoring_reference)
    [{_reference, _pid, kind_of_process}] = :ets.lookup(monitor_id, monitoring_reference)
    true = :ets.delete(monitor_id, monitoring_reference)

    kind_of_process
  end
end