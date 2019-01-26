local StatistConfig = import(".StatistConfig")

local M = class("StatistManager")

local instance = nil

function M:getInstance()
	if not instance then
		instance = M.new()
	end
	return instance
end

function M:destroyInstance()
	instance = nil
end

M._configs = nil
M._statists = nil

function M:logEventByConfig(config, ...)
	local statistImpl = self._statists[config.statistName]
	if not statistImpl then
		return
	end
	if config.customHandler then
		statistImpl[config.customHandler](statistImpl, config.eventId, ...)
	else
		statistImpl:logEvent(config.eventId, ...)
	end
end

function M:hasStatistByName(statistName)
	if not self._statists then
		return false
	end
	return self._statists[statistName] ~= nil
end

function M:logEvent(id, ...)
    local configs = self:getConfigs(id)
    if not configs then 
        return 
    end 
	for _, config in ipairs(configs) do
		self:_logEventByConfig(config, ...)
	end
end

function M:getConfigs(id)
	if not self._configs or not self._statists then
		return
    end
    return self._configs[id]
end

function M:init(typePath, configPath)
	assert(type(typePath) == "string", string.format("the paramter of typePath:%s is not string", tostring(typePath)))
	assert(type(configPath) == "string", string.format("the paramter of configPath:%s is not string", tostring(configPath)))
	
	local values = table.load(typePath)
	for key, value in pairs(values) do
		local statistImpl = require(value).new()
		assert(type(statistImpl) == "table", "create the impl of statist fail")
	end
	self._statistImpls = values
	
	self._configs = {}
	local values = table.load(configPath)
	for _, config in ipairs(values) do
		setmetatable(config, StatistConfig)
		local configs = self._configs[config.statistId]
		if not configs then
			configs = {}
			self._configs[config.statistId] = configs
		end
		local statistImpl = self._statistImpls[config.statistName]
		assert(type(statist) ~= nil, string.format("there is not a impl for name:%s", config.statistName))
		local customHandler = statistImpl[config.customHandler]
		assert(customHandler == nil or type(customHandler) == "function" or type(customHandler) == "table", string.format("there is not a function for name:%s", tostring(customHandler)))
		table.insert(configs, config)
	end
end

return M 