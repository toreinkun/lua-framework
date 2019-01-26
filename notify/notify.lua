local CURRENT_MODULE_NAME = ...

setglobal("AopUtil", import(".AopUtil", CURRENT_MODULE_NAME))
setglobal("AopType", import(".AopType", CURRENT_MODULE_NAME))
setglobal("Observable", import(".Observable", CURRENT_MODULE_NAME))
setglobal("EventDispatcher", import(".EventDispatcher", CURRENT_MODULE_NAME)) 