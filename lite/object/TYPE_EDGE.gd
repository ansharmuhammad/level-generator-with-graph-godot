extends Node

class_name TYPE_EDGE

##
## Type Edge
##
## @desc:
##     class which contain types of edge
##

## type edge which connecting between two vertex
const PATH: String = "PATH"

## type edge which connecting the lock with his key
const KEY_LOCK: String = "KEY_LOCK"

## type edge which connecting between two element vertex
const ELEMENT: String = "ELEMENT"

## type edge which connecting between two place with hidden path
const HIDDEN: String = "HIDDEN"

## type edge which connecting between two adjacent place unconnected
const WINDOW: String = "WINDOW"

## type edge which connecting between two vertex with one way direction
const GATE: String = "GATE"
