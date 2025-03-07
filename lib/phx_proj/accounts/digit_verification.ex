defmodule PhxProj.Accounts.DigitVerification do
  use GenServer

  @pin_storage :pin_storage

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec init(any()) :: {:ok, %{}}
  def init(_) do
    :ets.new(:pin_storage, [:named_table, :public, read_concurrency: true])
    {:ok, %{}}
  end

@spec store_pin(any(), any()) :: true
def store_pin(user_id, pin) do
  :ets.insert(@pin_storage, {user_id, pin, NaiveDateTime.utc_now()})
end

@spec get_pin(any()) :: :not_found | {:ok, binary(), any()}
def get_pin(user_id) do
  case :ets.lookup(@pin_storage, user_id) do
    [{^user_id, pin, timestamp}] ->
       {:ok, pin, timestamp}
    [] ->
      :not_found
  end
end

@spec generate_pin(integer()) :: {:ok, bitstring()}
def generate_pin(length \\ 6) do
  pin =
  for _ <- 1..length, into: "", do: Integer.to_string(:rand.uniform(10) - 1)

  {:ok, pin}
end

@spec confirm_pin(any(), any()) :: :correct | :expired | :incorrect | :not_found
def confirm_pin(user_id, pin) do
  case get_pin(user_id) do
    {:ok, stored_pin, timestamp} ->
      current_time = NaiveDateTime.utc_now()
      ten_minutes_ago = NaiveDateTime.add(current_time, -600)
      if NaiveDateTime.compare(timestamp, ten_minutes_ago) == :gt do
        if pin == stored_pin do
          :correct
        else
          :incorrect
        end
      else
        :expired
      end

    :not_found -> :not_found
  end
end
end
