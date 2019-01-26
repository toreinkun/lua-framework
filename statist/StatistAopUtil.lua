local StatistAopConfig = import(".StatistAopConfig")

local M = class("StatistAopUtil")

local function _insertAop(statistManager, config)
	AopUtil.insertAspectByFile(
	config.aopClass, config.aopMethod, config.aopType, function(...)
		local configs = statistManager:getConfigs(config.statistId)
		if not configs then
			return
		end
		for _, config in ipairs(configs) do
			if config.customHandler then
				statistManager:logEventByConfig(config, ...)
			else
				statistManager:logEventByConfig(config)
			end
		end
	end)
end

function M.init(statistManager, path)
	assert(type(path) == "string", string.format("the paramter of path:%s is not string", tostring(path)))
	
	local values = table.load(path)
	for _, value in ipairs(values) do
		local config = setmetatable(value, StatistAopConfig)
		_insertAop(statistManager, config)
	end
end

return M 