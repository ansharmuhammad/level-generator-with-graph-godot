extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	var array = [1,2,3,4]
#	print(array)
##	pv(array)
#
#
#	var satu = array[1]
#	var tiga = array[3]
#
#	print(satu)
#	print(tiga)
#
#	array.erase(satu)
#	array.erase(tiga)
#	print(array)
#
#	print(satu)
#	print(tiga)
#
	var arrayin = [1,2,3,4,5,6]
	var arrayOut = []
	print(arrayin)
	print(arrayOut)
	rek(arrayin, arrayOut)
	print(arrayin)
	print(arrayOut)

func pv(array):
	for i in array:
		i + 2
	array.append(5)

func rek(arrayin: Array, arrayout: Array):
	for i in arrayin:
		arrayout.append(i)
		arrayin.erase(i)
		rek(arrayin, arrayout)
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
