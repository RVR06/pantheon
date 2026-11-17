workspace "Elysium" "The blessed realm: citizen app, activity feed and recommendations for heroes." {
	!identifiers hierarchical
	!impliedRelationships false
	
	model {
		elysium = softwareSystem "Elysium" "The blessed realm: citizen app, activity feed and recommendations for heroes." "#elysium" {
			nectar = container "Nectar" "Stores feeds and profiles." "Azure Cosmos DB" "#db, #cosmosdb"
			harp = container "Harp" "Streams engagement events." "Apache Kafka" "#bus, #kafka"
			ambrosiaviews = container "Ambrosia Search" "Full-text search over the feed." "Elasticsearch" "#db, #elasticsearch"
			
			feed = container "Feed Service" "Serves each hero's activity feed." "Java / Spring Boot" "#api, #springboot" {
				
				ranker = component "Ranker" "Orders feed entries by relevance." "Java" "#java"
				store = component "Feed Repository" "Reads and writes feed documents." "Spring Data Cosmos" "#spring" {
					-> nectar "reads and writes"
				}
				publisher = component "Event Publisher" "Pushes engagement events onto the harp." "Spring Kafka" "#kafka" {
					-> harp "publishes onto"
				}
				
				controller = component "Feed Controller" "GET /feed" "Spring MVC" "#spring" {
					-> ranker "orders results with"
					-> store "loads feeds from"
					-> publisher "reports views through"
				}
				
				-> nectar "stores feeds in" "SQL API"
				-> harp "publishes engagement onto" "Kafka"
				-> ambrosiaviews "queries" "REST"
			}
			
			app = container "Elysium App" "Mobile app used by heroes." "Flutter" "#mobile, #flutter" {
				-> feed "reads feeds from" "HTTPS / JSON"
			}
			fields = container "Elysian Fields" "Web version of the citizen app." "Angular" "#web, #angular" {
				-> feed "reads feeds from" "HTTPS / JSON"
			}
			
			muses = container "Muses" "Derives recommendations from engagement events." "Kotlin Worker" "#worker" {
				scorer = component "Recommendation Model" "Scores candidate entries." "ONNX Runtime" "#judge"
				consumer = component "Event Consumer" "Reads engagement events." "Kafka Streams" "#ferry" {
					-> scorer "feeds"
				}
				
				-> harp "consumes engagement from" "Kafka"
				-> nectar "writes recommendations to" "SQL API"
			}
		}
		
		hero = person "Hero" "A living mortal who visits the realms and uses the Elysium citizen app." "" {
			-> elysium "browses the feed on"
			-> elysium.app "browses the feed on"
			-> elysium.fields "browses the feed on"
		}
	}
	
	views {
		theme https://raw.githubusercontent.com/rvr06/cornifer-contrib/main/themes/topology/theme.json
		theme https://raw.githubusercontent.com/rvr06/cornifer-contrib/main/themes/heraldry2/theme.json
		
		properties {
			"structurizr.sort" "created"
		}
		
		styles {
			element "#worker" {
				shape RoundedBox
			}
			element "#elysium" {
				stroke #e0a526
				icon icons/elysium.svg
			}
		}
		
		systemContext elysium "Elysium_Context" {
			include *
		}
		
		container elysium "Elysium_Containers" {
			include *
		}
		
		component elysium.feed "Feed_Components" {
			include *
		}
		
		component elysium.muses "Muses_Components" {
			include *
		}
	}
}
