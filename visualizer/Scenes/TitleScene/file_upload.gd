extends FileDialog

# Code modified from https://github.com/Pukkah/HTML5-File-Exchange-for-Godot/
#  (linked addon only supports images... re-writing code to serve our purposes)

signal file_read(data)
signal in_focus
signal reading_begun

var use_js = OS.get_name() == "HTML5" and OS.has_feature('JavaScript')


func _notification(notification: int):
	if notification == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		emit_signal("in_focus")


func _ready():
	if use_js:
		_define_js()


var default: Rect2
func popup(_rect: Rect2 = default):
	# If built for web, FileDialog won't work
	if use_js:
		load_file()
	else:
		.popup()


func load_file():
	if not use_js:
		return
	
	# Call our upload function
	JavaScript.eval("upload();", true)
	
	# Wait for prompt to close and for async data load 
	yield(self, "in_focus")
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Check that upload wasn't canceled
	if JavaScript.eval("canceled;", true):
		return
	
	emit_signal("reading_begun")
	
	# Wait until full data has loaded
	var file_data: PoolByteArray
	while true:
		file_data = JavaScript.eval("fileData;", true)
		if file_data != null:
			break
		yield(get_tree().create_timer(1), "timeout")
	
	# Optionally check file type
	#var file_type = JavaScript.eval("fileType;", true)
	
	emit_signal("file_read", file_data)


func _define_js():
	# Create global JS variables to store file upload state
	# Create input element to allow upload
	JavaScript.eval(
		"""
		var fileData;
		var fileType;
		var fileName;
		var canceled;
		function upload(){
			fileData = null;
			fileType = null;
			fileName = null;
			canceled = true;
			var input = document.createElement('INPUT'); 
			input.setAttribute("type", "file");
			input.click();
			input.addEventListener('change', event => {
				if (event.target.files.length > 0){
					canceled = false;
				}
				var file = event.target.files[0];
				var reader = new FileReader();
				fileType = file.type;
				fileName = file.name;
				reader.readAsArrayBuffer(file);
				reader.onloadend = function (evt) {
					if (evt.target.readyState == FileReader.DONE) {
						fileData = evt.target.result;
					}
				}
			});
		}
		"""
	, true)
