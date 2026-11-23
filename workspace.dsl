workspace "Da Pantheon" "Cloud landscape." {
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
		erebos = softwareSystem "Erebos" "The darkness between the worlds: logs, traces and alerts for the whole pantheon." "#erebos" {
			url "erebos/workspace.dsl"
		}
		lethe = softwareSystem "Lethe" "The river of forgetting: consent, secrets and right-to-erasure for every realm." "#lethe" {
			url "lethe/workspace.dsl"
		}
		moirai = softwareSystem "Moirai" "The Fates: durable workflows that spin, measure and cut long-running journeys." "#moirai" {
			url "moirai/workspace.dsl"
		}
		olympus = softwareSystem "Olympus" "The pantheon's control plane: gateway, planning, orchestration and tooling." "#olympus" {
			url "olympus/workspace.dsl"
		}
		tartarus = softwareSystem "Tartarus" "The Underworld spike." "#tartarus" {
			url "tartarus/workspace.dsl"
		}

		// Ecosystem personas: they live above the systems and cross several of them, unlike the system-level Hero, Titan or Aeacus.
		psyche = person "Psyche" "A mortal pilgrim whose journey crosses the realms: she consents, is planned for, and is followed from Olympus to Elysium." {
			-> lethe "Grants consent to"
			-> olympus "Asks for a journey from"
			-> elysium "Follows her journey on"
		}
		hades = person "Hades" "Lord of the pantheon: reads its census and health, and orders where its journeys must go next." {
			-> erebos "Checks the pantheon's health in"
			-> asphodel "Reads the census in"
			-> olympus "Orders new plans from"
		}

		olympus -> lethe "Checks consent with"
		olympus -> moirai "Spins journeys on"
		moirai -> elysium "Announces milestones to"
		moirai -> erebos "Reports progress and failures to"
		elysium -> asphodel "Streams engagement events to"
	}
	
	views {
		properties {
			"structurizr.sort" "created"
		}
		
		systemLandscape "Landscape" {
			include *
		}

		dynamic * "PilgrimJourney" "Psyche's pilgrimage: consent, planning, a durable journey, and the feed that tells it." {
			psyche -> lethe "Grants consent to be remembered"
			psyche -> olympus "Asks for a journey across the realms"
			olympus -> lethe "Checks her consent before planning"
			olympus -> moirai "Spins her journey"
			moirai -> elysium "Announces each milestone"
			psyche -> elysium "Follows the journey in her feed"
			elysium -> asphodel "Streams her engagement events"
		}

		dynamic * "HadesRound" "Hades' round: health, census, then new orders that reshape running journeys." {
			hades -> erebos "Checks the pantheon's health"
			hades -> asphodel "Reads the census of souls and activity"
			hades -> olympus "Orders a new plan"
			olympus -> moirai "Re-spins the affected journeys"
			moirai -> erebos "Reports progress and failures"
		}
	}
}
