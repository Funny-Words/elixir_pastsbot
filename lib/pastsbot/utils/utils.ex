defmodule Pastsbot.Utils do
  defguard is_paste(paste) when is_map(paste) and map_size(paste) > 1
end
