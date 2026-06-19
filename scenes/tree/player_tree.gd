class_name PlayerTree
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var tree_node = Node2D.new()
	add_child(tree_node)

	tree_node.scale = Vector2(0.7, 0.7)
	
	var tree = createpoints()
	var width = get_viewport().get_visible_rect().size.x
	var height = get_viewport().get_visible_rect().size.y

	var base_width = 50.0
	var taper_factor = 0.7
	var branch_index = 0
	
	var max_value = -INF
	var min_value = INF

	for branch in tree:
		max_value = max(max_value, branch[0])
		max_value = max(max_value, branch[1])
		max_value = max(max_value, branch[2])
		max_value = max(max_value, branch[3])

	print(max_value)
	
	for branch in tree:
		min_value = min(min_value, branch[0])
		min_value = min(min_value, branch[1])
		min_value = min(min_value, branch[2])
		min_value = min(min_value, branch[3])
	print(min_value)
	
	if min_value < 0:
		min_value = 1+abs(min_value)
	
	max_value = max(min_value, max_value)
	var scaler = 1/max_value

	for branch in tree:
		var layer = int(floor(log(branch_index + 1) / log(2)))
			

		var start_scale = pow(taper_factor, layer)
		var end_scale = pow(taper_factor, layer + 1)

		var line = Line2D.new()
		
		
		line.z_index = layer
		
		
		line.width = base_width
		line.default_color = Color.BLACK

		var taper = Curve.new()
		taper.add_point(Vector2(0.0, start_scale))
		taper.add_point(Vector2(1.0, end_scale))
		line.width_curve = taper

		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		var scaled_width = (0.5 + (branch[0] - 0.5) * scaler) * width
		var scaled_height = (1+(branch[1] - 1) * scaler) * height
		
		var scaled_width1 = (0.5 + (branch[2] - 0.5) * scaler) * width
		var scaled_height1 = (1+(branch[3] - 1) * scaler) * height

		line.add_point(Vector2(scaled_width,scaled_height))

		line.add_point(Vector2(scaled_width1,scaled_height1))

		tree_node.add_child(line)
		if branch_index > 6:
			for j in range(6):
				var circle = Polygon2D.new()
				circle.z_index = layer + 1

				var points = PackedVector2Array()
				var rand_size = randf_range(2.0, 7.0)

				for i in range(16):
					var angle = TAU * i / 16.0
					points.append(Vector2(cos(angle), sin(angle)) * rand_size)

				var rand_locationx = randf_range(-20.0, 20.0)
				var rand_locationy = randf_range(-20.0, 20.0)

				circle.polygon = points
				circle.color = Color.BLUE
				circle.position = Vector2(
					scaled_width1 + rand_locationx,
					scaled_height1 + rand_locationy
				)

				tree_node.add_child(circle)
		branch_index += 1

	
	
func createpoints():
	# Initialize the very first line segment  ( the trunk) of the tree
	var arr = []
	arr.resize(5)
	var start_x = float(0.5)
	var start_y = float(1.0)
	var end_x = float(0.5)
	var end_y = float(0.7)
	var angle = 0.0
	arr[0] = start_x
	arr[1] = start_y
	arr[2] = end_x
	arr[3] = end_y
	arr[4] = angle
	
	# InitiIalize the array of arrays that will store the line segments that makeup the tree.
	var tree = []
	tree.resize(1)
	tree[0] = arr
	var layers = 10
	var branches = pow(2, layers- 1) - 2
	var i = 0
	while i < branches:
		var start_point_x = tree[i][2]
		var start_point_y = tree[i][3]
		var old_angle = tree[i][4]

		# Left branch
		var arr2 = []
		arr2.resize(5)

		var rand_angle = deg_to_rad(randi_range(-20, 0))
		var rand_length = randf_range(0.1, 0.2)
		var new_angle = old_angle + rand_angle

		arr2[0] = start_point_x
		arr2[1] = start_point_y
		arr2[4] = new_angle

		var branchv = Vector2(0, -rand_length)
		var rotated_branch = branchv.rotated(new_angle)

		arr2[2] = rotated_branch.x + start_point_x
		arr2[3] = rotated_branch.y + start_point_y

		tree.append(arr2)

		# Right branch
		var arr3 = []
		arr3.resize(5)

		var rand_angle2 = deg_to_rad(randi_range(0, 20))
		var rand_length2 = randf_range(0.1, 0.2)
		var new_angle2 = old_angle + rand_angle2

		arr3[0] = start_point_x
		arr3[1] = start_point_y
		arr3[4] = new_angle2

		var branchv2 = Vector2(0, -rand_length2)
		var rotated_branch2 = branchv2.rotated(new_angle2)

		arr3[2] = rotated_branch2.x + start_point_x
		arr3[3] = rotated_branch2.y + start_point_y

		tree.append(arr3)

		i += 1
	
	print(tree)
	return tree
		
		
		
		
		
		
		
		
		
	
	
