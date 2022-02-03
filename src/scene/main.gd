extends Control

export(NodePath) var tree_plus_path
onready var tree_plus:TreePlus = get_node_or_null(tree_plus_path)

export(NodePath) var search_path
onready var search := get_node_or_null(search_path)

export(NodePath) var button_custom_filter_path
onready var button_custom_filter := get_node_or_null(button_custom_filter_path)

export(NodePath) var buttons_cont_path
onready var buttons_cont := get_node_or_null(buttons_cont_path)

class Item:
	var text := ""
	var parent:Item
	func _init(new_text:String,new_parent=null):
		text = new_text
		parent = new_parent
		
	func get_all_parents()->Array:
		var res:=[]
		var tmp=parent
		while tmp is Item:
			res.push_back(tmp)
			tmp=tmp.parent
		return res
	
	static func sort_items(a:Item,b:Item):
		return a in b.get_all_parents()
	
var items:=[]

func _ready():
	items.push_back(Item.new("root"))
	items.push_back(Item.new("test1",items.front()))
	items.push_back(Item.new("test_child",items.back()))
	items.push_back(Item.new("test2",items.front()))
	reset_tree()

func _on_tree_plus_drop_tree_items(tree_items, to_tree_item, shift):
	
	var valid:=true
	tree_items=tree_plus.get_items_without_children(tree_items)
	for k in tree_plus.get_all_parent_items(to_tree_item):
		if k in tree_items:
			valid=false
	if valid:
		var to_item:Item=to_tree_item.get_metadata(0)
		for k in tree_items:
			var item=k.get_metadata(0)
			if item is Item:
				item.parent=to_item
	reset_tree()


	
func reset_tree():
	tree_plus.clear()
	for item in items:
		items.sort_custom(Item,"sort_items")
		var parents:=tree_plus.get_items_by_metadata(item.parent)
		var parent=null
		if !parents.empty():
			parent=parents.front()
		var new_tree_item :TreeItem= tree_plus.create_item(parent)
		new_tree_item.set_text(0,item.text)
		new_tree_item.set_metadata(0,item)
		new_tree_item.set_editable(0,true)
		new_tree_item.set_icon(0,load("res://scene/main.theme::1436"))
	tree_plus.finish_init(search.text,button_custom_filter.pressed)


func _on_search_text_changed(_new_text):
	reset_tree()


func _on_tree_plus_item_edited():
	var tree_item:=tree_plus.get_last_selected()
	if tree_item is TreeItem:
		var item:Item=tree_item.get_metadata(0)
		if item is Item:
			item.text=tree_item.get_text(0)


func _on_popup_menu2_index_pressed(index):
	var tree_item:=tree_plus.get_last_selected()
	if tree_item is TreeItem:
		var item:Item=tree_item.get_metadata(0)
		if item:
			match index:
				0:
					items.push_back(Item.new("new_item",item))
					reset_tree()
				1:
					tree_plus.toggle_collapse_all(tree_item)
				2:
					items.erase(item)
					reset_tree()


func _on_button_custom_filter_pressed():
	reset_tree()


func _on_button_pressed():
	var tmp:=Button.new()
	tmp.name="Button"
	tmp.rect_min_size.y=40
	buttons_cont.add_child_below_node(buttons_cont.get_child(buttons_cont.get_child_count()-1),tmp,true)
	tmp.text=tmp.name


func _on_button_delete_pressed():
	if buttons_cont.get_child_count()>3:
		buttons_cont.remove_child(buttons_cont.get_child(buttons_cont.get_child_count()-1))
