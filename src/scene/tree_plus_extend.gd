extends TreePlus

func _apply_custom_filter(item:TreeItem,column:int,custom_filters)->bool:
	if custom_filters:
		return !item.get_children()
	return true
