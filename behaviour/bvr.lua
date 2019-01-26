local CURRENT_MODULE_NAME = ...

module("bvr", package.seeall)

BehaviourBase = import(".BehaviourBase", CURRENT_MODULE_NAME)

BehaviourContainer = import(".BehaviourContainer", CURRENT_MODULE_NAME)

BehaviourMulti = import(".BehaviourMulti", CURRENT_MODULE_NAME)
BehaviourOrderSelector = import(".BehaviourOrderSelector", CURRENT_MODULE_NAME)
BehaviourParallel = import(".BehaviourParallel", CURRENT_MODULE_NAME)
BehaviourSequence = import(".BehaviourSequence", CURRENT_MODULE_NAME)

BehaviourRunable = import(".BehaviourRunable", CURRENT_MODULE_NAME)

BehaviourTrigger = import(".BehaviourTrigger", CURRENT_MODULE_NAME)

return nil