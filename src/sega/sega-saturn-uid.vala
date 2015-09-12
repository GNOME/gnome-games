// This file is part of GNOME Games. License: GPLv3

private class Games.SegaSaturnUID: Object {
	private SegaSaturnHeader header;
	private string uid;

	public SegaSaturnUID (SegaSaturnHeader header) {
		this.header = header;
	}

	public string get_uid () throws Error {
		if (uid != null)
			return uid;

		var product_number = header.get_product_number ();
		var areas = header.get_areas ();
		uid = @"sega-saturn-$product_number-$areas".down ();

		return uid;
	}
}
