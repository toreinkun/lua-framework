--- 使用真实时间的定时器管理器
local M = class("SchedulerTimer")

-- @module #Timer 每一个需要更新的定时器
local Timer = {}
-- @filed #function _func 回调接口
Timer._func = nil
-- @field #float _interval 回调时间间隔，如果为0，则每一帧回调
Timer._interval = 0
-- @field #float _elapsed 累计时间，每超过interval则回调一次
Timer._elapsed = 0
-- @field #boolean _invalid 定时器是否无效
Timer._invalid = false
-- @field #int _id 定时器id，用于移除
Timer._id = 0

-- @field array_table#Timer _allTimers 所有使用中的定时器列表
M._allTimers = nil
-- @field #int _allTimerCount 所有使用中的定时器数量
M._allTimerCount = 0
-- @field #int _curTimerId 当前用到的定时器id
M._curTimerId = 0
-- @field #boolean _isLocked 是否正在更新定时器中
M._isLocked = false
-- @field array_table#Timer _toAddTimers 待添加的定时器列表
M._toAddTimers = nil
-- @field #int _toAddTimerCount 待添加的定时器数量
M._toAddTimerCount = 0

-- @field array_table#Timer 定时器对象池
M._timerPoolIns = nil
-- @field #int _timerPoolSize 定时器对象池剩余对象数量
M._timerPoolSize = 0

-- 从对象池获取定时器对象，如果不够了，则创建新的
-- @param self
-- @param #int id
-- @parma #function func 回调对象
-- @param #float interval 时间间隔
-- @return #Timer
local function _getTimer(self, id, func, interval)
	local timerPoolSize = self._timerPoolSize
	if self._timerPoolSize == 0 then
		return {
			_id = id,
			_func = func,
			_interval = interval,
			_elapsed = 0
		}
	end
	local timer = self._timerPoolIns[timerPoolSize]
	self._timerPoolSize = timerPoolSize - 1
	timer._id = id
	timer._func = func
	timer._interval = interval
	timer._elapsed = 0
	return timer
end

-- 归还定时器对象到对象池中
-- @param self 
-- @param #Timer timer
local function _returnTimer(self, timer)
	timer._func = nil
	timer._invalid = false
	self._timerPoolSize = self._timerPoolSize + 1
	self._timerPoolIns[self._timerPoolSize] = timer
end

-- 更新定时器，如果够时间了，执行回调函数
-- @param #Timer timer 定时器
-- @param #float dt 离上一帧时间差
-- @return #boolean 如果定时器已经失效，则返回false
local function _updateTimer(timer, dt)
	local interval = timer._interval
	if interval > 0 then
		timer._elapsed = timer._elapsed + dt
		while timer._elapsed >= interval and not timer._invalid do
			timer._func(interval)
			timer._elapsed = timer._elapsed - interval
		end
	else
		timer._func(dt)
	end
	return not timer._invalid
end

-- 构造函数，初始化数组
-- @param self
function M:ctor()
	self._allTimers = {}
	self._toAddTimers = {}
	self._timerPoolIns = {}
end

-- 定时器管理器是否为空
-- @param self
-- @return #boolean
function M:isEmpty()
	if self._isLocked then
		-- 待加进队列不为空或使用队列存在有效定时器，则返回false
		if self._toAddTimerCount > 0 then
			return false
		end
		for _, timer in ipairs(self._allTimers) do
			if not timer._invalid then
				return false
			end
		end
		return true
	else
		-- 使用队列不为空，则返回false
		return self._allTimerCount == 0
	end
end

-- 更新定时器管理器
-- @parma self 
-- @param #float dt
function M:update(dt)
	self._isLocked = true
	local timers = self._allTimers
	local i = 1
	while i <= #timers do
		local timer = timers[i]
		-- 更新定时器，如果定时器失效了，则移除
		if timer._invalid or not _updateTimer(timer, dt) then
			table.remove(timers, i)
			_returnTimer(self, timer)
			self._allTimerCount = self._allTimerCount - 1
		else
			i = i + 1
		end
	end
	if self._toAddTimerCount > 0 then 
		local curTimerCount = self._allTimerCount
		local toAddTimers = self._toAddTimers
		for i, timer in ipairs(toAddTimers) do 
			toAddTimers[i] = nil
			timers[curTimerCount + i] = timer
		end 
		self._allTimerCount = curTimerCount + self._toAddTimerCount
		self._toAddTimerCount = 0
	end 
	self._isLocked = false
end

-- 延迟一段时间执行一个方法
-- @param self
-- @parma #function func
-- @parma #float delay
-- @return #int
function M:performFuncAfterDelay(func, delay)
	local timerId = nil
	timerId = self:scheduleFuncPerTime(function(dt)
		self:unscheduleFunc(timerId)
		return func(dt)
	end, delay or 0)
	return timerId
end

-- 每一帧执行一个方法
-- @param self
-- @parma #function func
-- @return #int
function M:scheduleFuncPerFrame(func)
	return self:scheduleFuncPerTime(func, 0)
end

-- 每隔一段时间执行一个方法
-- @param self
-- @parma #function func
-- @param #float interval
-- @return #int
function M:scheduleFuncPerTime(func, interval)
	local curTimerId = self._curTimerId + 1
	local timer = _getTimer(self, curTimerId, func, interval)
	if self._isLocked then
		self._toAddTimerCount = self._toAddTimerCount + 1
		self._toAddTimers[self._toAddTimerCount] = timer
	else
		self._allTimerCount = self._allTimerCount + 1
		self._allTimers[self._allTimerCount] = timer
	end
	self._curTimerId = curTimerId
	return curTimerId
end

-- 移除一个定时器
-- @param self
-- @param #int id
function M:unscheduleFunc(id)
	if self._isLocked then
		for i, timer in ipairs(self._toAddTimers) do
			if timer._id == id then
				table.remove(self._toAddTimers, i)
				_returnTimer(self, timer)
				self._toAddTimerCount = self._toAddTimerCount - 1
				return
			end
		end
		for i, timer in ipairs(self._allTimers) do
			if timer._id == id then
				timer._invalid = true
				return
			end
		end
	else
		for i, timer in ipairs(self._allTimers) do
			if timer._id == id then
				table.remove(self._allTimers, i)
				_returnTimer(self, timer)
				self._allTimerCount = self._allTimerCount - 1
				return
			end
		end
	end
end

return M 