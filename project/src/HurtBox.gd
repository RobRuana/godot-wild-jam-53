class_name HurtBox
extends Area2D


func disable():
	self.set_deferred("monitoring", false)
	self.set_deferred("monitorable", false)


func enable():
	self.set_deferred("monitoring", true)
	self.set_deferred("monitorable", true)


func reset():
	self.monitoring = false
	self.monitorable = false
	self.set_deferred("monitoring", true)
	self.set_deferred("monitorable", true)
