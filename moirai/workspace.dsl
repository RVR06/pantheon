workspace "Moirai" "The Fates: durable workflows that spin, measure and cut long-running journeys." {
	!identifiers hierarchical
	!impliedRelationships false
	
	model {
		moirai = softwareSystem "Moirai" "The Fates: durable workflows that spin, measure and cut long-running journeys." "#moirai" {
			loom = container "Loom" "Persists workflow histories." "PostgreSQL" "#db, #postgresql"
			clotho = container "Clotho" "Starts workflows." "Temporal Worker (.NET)" "#worker, #dotnet" {
				-> loom "writes histories to" "SQL"
			}
			lachesis = container "Lachesis" "Measures progress and exposes workflow state." ".NET|gRPC" "#api, #dotnet" {
				-> loom "reads histories from" "SQL"
			}
			atropos = container "Atropos" "Cuts expired workflows on a schedule." "Azure Function" "#worker, #function, #azure" {
				-> loom "deletes expired histories from" "SQL"
			}
			spindle = container "Spindle Console" "Operators watch and steer workflows." "Vue|TypeScript" "#web, #vue" {
				-> lachesis "queries" "gRPC-Web"
			}
			signal = container "Signal Hub" "Receives external signals for workflows." "Azure Event Grid" "#bus, #azure" {
				-> clotho "wakes" "HTTPS"
			}
		}
		
		titan = person "Titan" "A platform engineer who runs the pantheon and reads its telemetry." "" {
			-> moirai "steers workflows in"
			-> moirai.spindle "steers workflows in"
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
				shape Folder
			}
			element "#moirai" {
				stroke #D4A017
				icon icons/moirai.svg
			}
		}
		
		systemContext moirai "Moirai_Context" {
			include *
		}
		
		container moirai "Moirai_Containers" {
			include *
		}
	}
}
