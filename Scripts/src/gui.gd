extends CanvasLayer

var items :Array = ["grenade","molotov","none","none"] #T,R,B,L

var selecting :bool = false
var threshold :int = 20
var choosed_item:int = 0
var ind :=0

func _process(_delta):
	$"Control/Throwables Inventory".visible= selecting
	Global.can_rotate_cam = !selecting
	$Control/Label.text = "choosed item: "+str(items[choosed_item])
	for i in range(4):
		if(i==ind):
			$"Control/Throwables Inventory".get_child(i).scale = 0.6 * Vector2(1,1)
		else:
			$"Control/Throwables Inventory".get_child(i).scale = 0.55 * Vector2(1,1)
	

func _input(event):
	if Input.is_action_just_pressed("ctrl"):
		selecting = true
		
	if(Input.is_action_just_released("ctrl")):
		choosed_item = ind
		ind = -1
		if choosed_item == 0:
			$Control/Equiped/Grenade.visible = true
			$Control/Equiped/MolotovCocktail.visible=false
		elif choosed_item ==1:
			$Control/Equiped/MolotovCocktail.visible=true
			$Control/Equiped/Grenade.visible=false
		else:
			$Control/Equiped/MolotovCocktail.visible=false
			$Control/Equiped/Grenade.visible=false
		selecting=false
		
	if event is InputEventMouseMotion and selecting:
		var event_velocity :Vector2 = event.velocity
		if(abs(event_velocity.x)<abs(event_velocity.y)):
			ind=2 if event_velocity.y>0 else 0
		else:
			ind=3 if event_velocity.x<0 else 1
			
			
		
