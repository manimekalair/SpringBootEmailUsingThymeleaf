package com.exercise;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class MapSet {

	public static void main(String[] args) {
		Set<String> shops=new HashSet<String>();
		shops.add("Vegetable Shops");
		shops.add("WorkShop");
		shops.add("Flavour Mill");
		Set<String> temples=new HashSet<String>();
		temples.add("Perumal Kovil");
		temples.add("Sivan Kovil");
		temples.add("Munni Kovil");
		
		Map<String, Object> myStreet=new HashMap<String, Object>();
		myStreet.put("Hotels", shops);
		myStreet.put("Temples", temples);
		System.out.println(myStreet);
		//System.out.println(shops);
		//System.out.println(temples);
	}

}
