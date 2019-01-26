local CURRENT_MODULE_NAME = ...

module("struct", package.seeall)

setglobal("Array", import(".ArrayList", CURRENT_MODULE_NAME))
setglobal("LinkedList", import(".LinkedList", CURRENT_MODULE_NAME))
setglobal("Map", import(".HashMap", CURRENT_MODULE_NAME))
setglobal("Set", import(".HashSet", CURRENT_MODULE_NAME))
setglobal("Queue", import(".ArrayQueue", CURRENT_MODULE_NAME))
setglobal("Stack", import(".Stack", CURRENT_MODULE_NAME))
setglobal("Heap", import(".Heap", CURRENT_MODULE_NAME))

MaxHeap = import(".MaxHeap", CURRENT_MODULE_NAME)
MinHeap = import(".MinHeap", CURRENT_MODULE_NAME)
LinkedQueue = import(".LinkedQueue", CURRENT_MODULE_NAME)
HashQueue = import(".HashQueue", CURRENT_MODULE_NAME)

return nil 