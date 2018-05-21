var all = document.querySelectorAll('select[id]');


for (i = 0; i< all.length; i++){
	console.log(i);
	if (localStorage.getItem(all[i].id) != null){
		retrieve_selection(all[i].id);
	} else {
		save_selection(all[i].id, '0');
	}
}


function save_selection(address, selection) {
	// Store
	localStorage.setItem(address, selection.toString());
}

function retrieve_selection(address){
	// Retrieve
	selection = Number(localStorage.getItem(address));	
	document.getElementById(address).selectedIndex = selection;
}