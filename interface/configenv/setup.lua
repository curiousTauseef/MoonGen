local Flow = require "configenv.flow"
local Packet = require "configenv.packet"

return function(env, error, flows)
		function env.Flow(tbl)
			if type(tbl) ~= "table" then
				error("Invalid usage of Flow. Try Flow{...)")
				return
			end

			local name = tbl[1]

			-- check for characters that
			-- - would complicate shell argument parsing ( ;)
			-- - interfere with flow parameter syntax (:,)
			if string.find(name, "[ ;:,]") then
				error("Invalid flow name %q. Names cannot include the characters ' ;:,'.", name)
			end

			local pname = tbl.parent
			if type(pname) == "string" then
				local parent = flows[pname]
				error:assert(parent, "Unknown parent %q of flow %q.", pname, name)
				tbl.parent = parent
			end

			flows[name] = Flow.new(name, tbl, error)
		end

		local packetmsg = "Invalid usage of Packet. Try Packet.proto{...}."
		local function _packet_error() error(3, packetmsg) end
		env.Packet = setmetatable({}, {
			__newindex = _packet_error,
			__call = _packet_error,
			__index = function(_, proto)
				if type(proto) ~= "string" then
					_packet_error()
					return function() end
				end

				return function(tbl)
					if type(tbl) ~= "table" then
						_packet_error()
					else
						return Packet.new(proto, tbl, error)
					end
				end
			end
		})
end
