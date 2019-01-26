--- <summary>
--- Entry#Entry 定时器，保存要定时触发的对象的信息。
--- _register : bool#bool 标记定时器是否将要移除，如果是false，则会在事件分发结束后移除。
--- _running : bool#bool 标记定时器是否在运行状态，如果是false，则就算接收到事件，也不会回调对象和函数。
--- _countdown : int#int 定时器的倒计时，当为0的时候会触发，作用于频率大于1的定时器。
--- _rate : int#int 定时器触发的频率。
--- </summary>
local Entry = class("Entry");
Entry._register = true;
Entry._rate = 0;
Entry._running = true;
Entry._countdown = 0;

--- <summary>
--- self : Entry#Entry
--- rate : int#int 定时器触发的频率。
--- </summary>
function Entry:ctor(rate)
    self._rate = rate or 0;
    self._countdown = interval;
end

--- <summary>
--- 获取定时器的标记。
--- self : Entry#Entry
--- </summary>
--- <returns type="object#object"></returns>
function Entry:getTag() end;

--- <summary>
--- 定时器更新接口。
--- self : Entry#Entry
--- </summary>
function Entry:update() end;

--- <summary>
--- FunctionEntry#FunctionEntry 函数触发定时器。
--- _tag : int#int 标记定时器的键值，每创建一个新定时器，会自增1。
--- _func : function#function(int#int) 定时器回调函数。
--- </summary>
local FunctionEntry = class("FunctionEntry", Entry);

FunctionEntry._tag = nil;
FunctionEntry._func = nil;

--- <summary>
--- self : FunctionEntry#FunctionEntry
--- tag : int#int 定时器标记。
--- func : function#function(int#int) 定时器回调函数。
--- rate : int#int 定时器触发的频率。
--- </summary>
function FunctionEntry:ctor(tag, func, rate)
    self._tag = tag;
    self._func = func;
    FunctionEntry.super.ctor(self, rate);
end

--- <summary>
--- self : FunctionEntry#FunctionEntry
--- </summary>
function FunctionEntry:update(dt)
    return self._func(dt);
end

--- <summary>
--- self : FunctionEntry#FunctionEntry
--- </summary>
--- <returns type="int#int"></returns>
function FunctionEntry:getTag()
    return self._tag;
end

--- <summary>
--- TargetEntry#TargetEntry 对象触发定时器。
--- _target : LuaTimer#LuaTimer 回调对象。
--- </summary>
local TargetEntry = class("TargetEntry", Entry);

TargetEntry._target = nil;

--- <summary>
--- self : FunctionEntry#FunctionEntry
--- target : LuaTimer#LuaTimer 回调对象。
--- rate : int#int 定时器触发的频率。
--- </summary>
function TargetEntry:ctor(target, rate)
    self._target = target;
    TargetEntry.super.ctor(self, rate);
end

--- <summary>
--- self : TargetEntry#TargetEntry
--- </summary>
function TargetEntry:update(dt)
    return self._target:update(dt);
end

--- <summary>
--- self : TargetEntry#TargetEntry
--- </summary>
--- <returns type="LuaTimer#LuaTimer"></returns>
function TargetEntry:getTag()
    return self._target;
end

--- <summary>
--- #SchedulerFrequency 定时器管理器
--- _entryArr : array_table#Entry 定时器数组容器，用于更新的时候，定时器的遍历。
--- _entryMap : map_table#Entry 定时器hash容器，用于寻找定时器。
--- _adds : array_table#Entry 待加入的定时器数组容器，如果在定时器的触发的过程中加入定时器，则会先加入到这个容器。
--- _update : bool#bool 标记在定时器的触发过程中，是否存在增删操作。
--- _guard : int#int 标记当前是否在定时器触发的过程中。
--- _currentTag : int#int 当前定时器标签用到的值。
--- </summary>
local M = class("SchedulerFrequency");
M._entryArr = nil;
M._entryMap = nil;
M._adds = nil;
M._update = false;
M._guard = 0;
M._currentTag = 0;
M._clear = false;

--- <summary>
--- 尝试添加定时器，如果在定时器在触发的过程中，则先加入到待添加定时器容器，等更新完毕后再加入到更新容器。
--- self : M#M
--- entry : Entry#Entry 定时器
--- </summary>
local function _tryAddEntry(self, entry)
    -- 把定时器加入到用于hash寻找的容器中。
    self._entryMap[entry:getTag()] = entry;
    if self._guard > 0 then
        -- 标记在更新状态中存在增操作。
        self._update = true;
        return table.insert(self._adds, entry);
    else
        return table.insert(self._entryArr, entry);
    end
end

--- <summary>
--- 在触发完定时器后，更新那些过程中被增删的定时器。
--- self : M#M
--- </summary>
local function _updateAllEntries(self)
    if self._guard > 0 or not self._update then
        return;
    end
    if self._clear then
        self._clear = false;
        self._entryArr = { };
    else
        local entries = self._entryArr;
        for i = #entries, 1, -1 do
            if not entries[i]._register then
                table.remove(entries, i);
            end
        end
    end
    if #self._adds > 0 then
        for _, entry in ipairs(self._adds) do
            table.insert(entries, entry);
        end
        self._adds = { };
    end
    self._update = false;
end

--- <summary>
--- 删除定时器，如果在触发的过程中，则先标记它，在之后再删除。
--- self : M#M
--- tag : object#object tag 定时器的标签
--- </summary>
local function _removeEntry(self, tag)
    local removeEntry = self._entryMap[tag];
    if removeEntry == nil then
        return;
    end
    self._entryMap[tag] = nil;

    if self._guard > 0 then
        -- 标记这个定时器是删除状态。
        removeEntry._register = false;
        -- 标记在触发状态中存在增操作。
        self._update = true;
        -- 从待加入的定时器中删除它
        for i, entry in ipairs(self._adds) do
            if removeEntry == entry then
                return table.remove(self._adds, i);
            end
        end
    else
        -- 不是在触发的过程中，直接从主容器删除。
        for i, entry in ipairs(self._entryArr) do
            if removeEntry == entry then
                return table.remove(self._entryArr, i);
            end
        end
    end
end

--- <summary>
--- 暂停定时器。
--- self : M#M
--- tag : object#object tag 定时器的标签
--- </summary>
local function _pauseEntry(self, tag)
    local entry = self._entryMap[tag];
    if entry == nil then
        return;
    end
    entry._running = false;
end

--- <summary>
--- 恢复定时器。
--- self : M#M
--- tag : object#object tag 定时器的标签
--- </summary>
local function _resumeEntry(self, tag)
    local entry = self._entryMap[tag];
    if entry == nil then
        return;
    end
    entry._running = true;
end

--- <summary>
--- self : M#M
--- </summary>
function M:ctor()
    self._adds = { };
    self._entryArr = { };
    self._entryMap = { };
end

--- <summary>
--- 定时器更新
--- self : M#M
--- </summary>
function M:update()
    self._guard = self._guard + 1;
    for _, entry in ipairs(self._entryArr) do
        if entry._register and entry._running then
            if entry._rate == 0 then
                entry:update(1);
            else
                local countdown = entry._countdown - 1;
                if countdown <= 0 then
                    entry:update(entry._rate);
                    countdown = entry._rate;
                end
                entry._countdown = countdown;
            end
        end
    end
    self._guard = self._guard - 1;
    _updateAllEntries(self);
end

--- <summary>
--- 通过回调对象注册定时器。
--- self : M#M
--- target : LuaTimer#LuaTimer 回调对象
--- rate : int#int 定时器更新的频率
--- pause : bool#bool 定时器是否暂停状态
--- </summary>
function M:scheduleTarget(target, rate, pause)
    if type(target) ~= "table" and type(target) ~= "userdata" then
        log.wfmt(0, "the parameter of target:%s is not userdata or table", tostring(target));
        return;
    end
    if type(target.update) ~= "function" and type(target.update) ~= "table" then
        log.w(0, "the parameter of target has not a update function");
        return;
    end
    rate = rate or 0;
    if type(rate) ~= "number" then
        log.wfmt(0, "the parameter of rate:%s is not number", tostring(rate));
    end
    pause = pause or false;
    if type(pause) ~= "boolean" then
        log.wfmt(0, "the parameter of pause:%s is not boolean", tostring(pause));
    end
    local entry = TargetEntry.new(target, rate);
    entry._running = not pause;
    return _tryAddEntry(self, entry);
end

--- <summary>
--- 通过回调对象删除定时器。
--- self : M#M
--- target : LuaTimer#LuaTimer 回调对象
--- </summary>
function M:unscheduleTarget(target)
    if type(target) ~= "table" and type(target) ~= "userdata" then
        log.wfmt(0, "the parameter of target:%s is not userdata or table", tostring(target));
        return;
    end
    return _removeEntry(self, target);
end

--- <summary>
--- 通过回调对象暂停定时器。
--- self : M#M
--- target : LuaTimer#LuaTimer 回调对象
--- </summary>
function M:pauseTarget(target)
    if type(target) ~= "table" and type(target) ~= "userdata" then
        log.wfmt(0, "the parameter of target:%s is not userdata or table", tostring(target));
        return;
    end
    return _pauseEntry(self, target);
end

--- <summary>
--- 通过回调对象恢复定时器。
--- self : M#M
--- target : LuaTimer#LuaTimer 回调对象
--- </summary>
function M:resumeTarget(target)
    if type(target) ~= "table" and type(target) ~= "userdata" then
        log.wfmt(0, "the parameter of target:%s is not userdata or table", tostring(target));
        return;
    end
    return _resumeEntry(self, target);
end

--- <summary>
--- 通过回调函数注册定时器，返回定时器的标签。
--- self : M#M
--- func : function#function(int#int) 定时器回调函数
--- rate : int#int 定时器更新的频率
--- pause : bool#bool 定时器是否暂停状态
--- </summary>
--- <returns type="int#int"></returns>
function M:scheduleFunc(func, rate, pause)
    if type(func) ~= "function" and type(func) ~= "table" then
        log.wfmt(0, "the parameter of func:%s is not function or table", tostring(func));
        return 0;
    end
    rate = rate or 0;
    if type(rate) ~= "number" then
        log.wfmt(0, "the parameter of rate:%s is not number", tostring(rate));
        return 0;
    end
    pause = pause or false;
    if type(pause) ~= "boolean" then
        log.wfmt(0, "the parameter of pause:%s is not boolean", tostring(pause));
        return 0;
    end
    local tag = self._currentTag + 1;
    local entry = FunctionEntry.new(tag, func, rate);
    entry._running = not pause;
    _tryAddEntry(self, entry);
    self._currentTag = tag;
    return tag;
end

--- <summary>
--- 通过定时器的标签来删除定时器。
--- self : M#M
--- tag : int#int 定时器标签
--- </summary>
function M:unscheduleFunc(tag)
    if type(tag) ~= "number" then
        log.wfmt(0, "the parameter of tag:%s is not number", tostring(tag));
        return;
    end
    return _removeEntry(self, tag);
end

--- <summary>
--- 通过定时器的标签来暂停定时器。
--- self : M#M
--- tag : int#int 定时器标签
--- </summary>
function M:pauseFunc(tag)
    if type(tag) ~= "number" then
        log.wfmt(0, "the parameter of tag:%s is not number", tostring(tag));
        return;
    end
    return _pauseEntry(self, tag);
end

--- <summary>
--- 通过定时器的标签来恢复定时器。
--- self : #M
--- tag : int#int 定时器标签
--- </summary>
function M:resumeFunc(tag)
    if type(tag) ~= "number" then
        log.wfmt(0, "the parameter of tag:%s is not number", tostring(tag));
        return;
    end
    return _resumeEntry(self, tag);
end

--- <summary>
--- 注册一个过几帧回调的函数，返回这个定时器的标签。
--- self : M#M
--- func : function#function(int#int) 回调函数
--- delay : int#int 延迟回调的帧数
--- </summary>
function M:performFuncAfterDelay(func, delay)
    if type(func) ~= "function" and type(func) ~= "table" then
        log.wfmt(0, "the parameter of func:%s is not function or table", tostring(func));
        return 0;
    end
    delay = delay or 0;
    if type(delay) ~= "number" then
        log.wfmt(0, "the parameter of delay:%s is not number", tostring(delay));
        return 0;
    end
    local tag = nil;
    tag = self:scheduleFunc( function(rate)
        self:unscheduleFunc(tag);
        return func(rate);
    end , delay);
    return tag;
end

function M:unscheduleAll()
    self._entryMap = { };
    if self._guard > 0 then
        self._adds = { };
        self._clear = true;
        self._update = true;
        for i, entry in ipairs(self._entryArr) do
            entry._register = false;
        end
    else
        self._entryArr = { };
    end
end 

return M;