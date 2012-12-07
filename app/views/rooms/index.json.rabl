collection @rooms
attributes *Room.column_names

child :liveClients => :clients do
  attributes *Client.column_names
end
