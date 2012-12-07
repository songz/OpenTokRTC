object @room
attributes *Room.column_names

child :liveClients do
  attributes *Client.column_names
end
