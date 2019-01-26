local M = class("BehaviourMulti", import(".BehaviourBase", ...))

M._children = nil

function M:ctor(behaviours)
	for _, behaviour in ipairs(behaviours) do
		behaviour:setParent(self)
	end
	self._children = Array.new()
	self._children:pack(behaviours)
	M.super.ctor(self)
end

return M 