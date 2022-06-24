extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var arrdict: Array = [
		[3, 8, 2],
		[9, 3, 10],
		[4, 1, 4],
		[8, 2, 10],
		[5, 2, 4],
		[2, 6, 2],
		[6, 3, 4],
		[7, 1, 10],
		[1, 4, 2]
	]
	
	arrdict.sort_custom(self, "_multi_column_sort")
	print(arrdict)

func _multi_column_sort(a,b):
	if a[2] < b[2]:
		return true
	elif a[2] == b[2] and a[1] < b[1]:
		return true
	return false

#	var arrayin = [1, 2, 3, 9, 3, 2, 7, 8, 10, 11, 12, 11, 13, 14, 15, 16, 17, 16, 15]
#	_nine_clear(arrayin)
#	print(arrayin)
#
#func _nine_clear(array: Array) -> Array:
#	for i in range(array.size()):
#		var nexidx: int = i + 1 if (i + 1) < array.size() else 0
#		if array[i-1] == array[nexidx]:
#			var a = array[i]
#			var b = array[i-1]
#			array.erase(a)
#			array.erase(b)
#			return _nine_clear(array)
#	return array
