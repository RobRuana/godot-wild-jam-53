extends Node


signal resource_loaded


var thread: Thread
var mutex: Mutex
var sem: Semaphore

var time_max: int = 100 # Milliseconds.

var queue: = []
var pending: = {}


func _ready():
	start()


func _lock(_caller: String):
	mutex.lock()


func _unlock(_caller: String):
	mutex.unlock()


func _post(_caller: String):
	sem.post()


func _wait(_caller: String):
	sem.wait()


func load_async(path: String, in_front: bool = false, no_cache: bool = false):
	if OS.get_name() == "HTML5":
		yield(get_tree().create_timer(0.0), "timeout")
		return ResourceLoader.load(path)

	call_deferred("queue_resource", path, in_front, no_cache)
	var loaded_path: String = yield(self, "resource_loaded")
	while loaded_path != path:
		loaded_path = yield(self, "resource_loaded")
	return get_resource(path)


func queue_resource(path: String, in_front: bool = false, no_cache: bool = false):
	_lock("queue_resource")
	if not path in pending:

		if not no_cache and ResourceLoader.has_cached(path):
			var resource = ResourceLoader.load(path)
			pending[path] = resource
			call_deferred("emit_signal", "resource_loaded", path)

		else:
			var loader: = ResourceLoader.load_interactive(path)
			if loader:
				loader.set_meta("path", path)
				if in_front:
					queue.insert(0, loader)
				else:
					queue.push_back(loader)
				pending[path] = loader
			else:
				pending[path] = null
				call_deferred("emit_signal", "resource_loaded", path)
			_post("queue_resource")

	_unlock("queue_resource")


func cancel_resource(path: String):
	_lock("cancel_resource")
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			queue.erase(pending[path])
		pending.erase(path)
	_unlock("cancel_resource")


func get_progress(path: String) -> float:
	_lock("get_progress")
	var progress: float = -1.0
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			progress = float(pending[path].get_stage()) / float(pending[path].get_stage_count())
		else:
			progress = 1.0
	_unlock("get_progress")
	return progress


func is_ready(path: String) -> bool:
	_lock("is_ready")
	var ready: bool
	if path in pending:
		ready = !(pending[path] is ResourceInteractiveLoader)
	else:
		ready = false
	_unlock("is_ready")
	return ready


func _wait_for_resource(loader: ResourceInteractiveLoader, path: String):
	_unlock("wait_for_resource")
	while true:
		VisualServer.sync()
		OS.delay_usec(16000) # Wait approximately 1 frame.
		_lock("wait_for_resource")
		if queue.size() == 0 || queue[0] != loader:
			return pending[path]
		_unlock("wait_for_resource")


func get_resource(path: String) -> Resource:
	_lock("get_resource")
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			var loader: = pending[path] as ResourceInteractiveLoader
			if loader != queue[0]:
				var index: = queue.find(loader)
				queue.remove(index)
				queue.insert(0, loader)

			var resource = _wait_for_resource(loader, path)
			pending.erase(path)
			_unlock("get_resource")
			return resource
		else:
			var resource = pending[path]
			pending.erase(path)
			_unlock("get_resource")
			return resource
	else:
		_unlock("get_resource")
		return ResourceLoader.load(path)


func thread_process():
	_wait("thread_process")
	_lock("process")

	while queue.size() > 0:
		var loader: = queue[0] as ResourceInteractiveLoader
		_unlock("process_poll")
		var err: = loader.poll()
		_lock("process_check_queue")

		if err == ERR_FILE_EOF || err != OK:
			var path = loader.get_meta("path")
			if path in pending: # Else, it was already retrieved.
				pending[path] = loader.get_resource()
			# Something might have been put at the front of the queue while
			# we polled, so use erase instead of remove.
			queue.erase(loader)

			call_deferred("emit_signal", "resource_loaded", path)
	_unlock("process")


func thread_func(_u):
	while true:
		thread_process()


func start():
	mutex = Mutex.new()
	sem = Semaphore.new()
	thread = Thread.new()
	thread.start(self, "thread_func", 0)
