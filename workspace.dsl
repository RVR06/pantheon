workspace "Pantheon2" "Cloud landscape." {
	!identifiers hierarchical
	!impliedRelationships false
	
	configuration {
		scope landscape
	}
	
	model {
		asphodel = softwareSystem "Asphodel" "The meadow of the ordinary dead: analytics lake, warehouse and dashboards." "#asphodel" {
			url "asphodel/workspace.dsl"
		}
		
		elysium = softwareSystem "Elysium" "The blessed realm: citizen app, activity feed and recommendations for heroes." "#elysium" {
			url "elysium/workspace.dsl"
		}
		
		aeacus = person "Aeacus" "A platform engineer who runs the pantheon and reads its telemetry." "" {
			-> asphodel "reviews usage in"
			-> asphodel.dashboards "reviews usage in"
		}
		
		hero = person "Hero" "A living mortal who visits the realms and uses the Elysium citizen app." "#soul" {
			-> elysium "browses the feed on"
			-> elysium.app "browses the feed on"
			-> elysium.fields "browses the feed on"
		}
	}
	
	views {
		properties {
			"structurizr.sort" "created"
		}
		
		systemLandscape "Landscape" {
			include *
		}
	}
}
