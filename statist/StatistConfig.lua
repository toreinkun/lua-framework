local M = class("StatistConfig")

-- @field #string statistId 统计id
M.statistId = nil
-- @field #string statistName
M.statistName = nil
-- @field #string eventId 事件id
M.eventId = nil
-- @field #string customHandler 自定义处理方法名，是对应的统计工具对象的方法
M.customHandler = nil

return M