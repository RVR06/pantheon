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
		zeus = person "Zeus" "Lord of the pantheon, the One: reads its census and health, and orders where its journeys must go next." "bearer:eagle" {
			-> erebos "Checks the pantheon's health in"
			-> asphodel "Reads the census in"
			-> olympus "Orders new plans from"
		}
		
		olympus -> lethe "Checks consent with"
		olympus -> moirai "Spins journeys on"
		moirai -> elysium "Announces milestones to"
		moirai -> erebos "Reports progress and failures to"
		elysium -> asphodel "Streams engagement events to"
		
		// ----- Deployments: one local and one Kubernetes flavour at the system level, then again at the container level -----
		
		local_systems_ = deploymentEnvironment "Local · Systems" {
			laptop = deploymentNode "Developer laptop" "" "Windows 11" "#windows" {
				orchestration_ = deploymentNode "Orchestration" "" "Aspire" "#aspire" {
					asphodel_ = softwareSystemInstance asphodel
					elysium_ = softwareSystemInstance elysium
					erebos_ = softwareSystemInstance erebos
					lethe_ = softwareSystemInstance lethe
					moirai_ = softwareSystemInstance moirai
					olympus_ = softwareSystemInstance olympus
					tartarus_ = softwareSystemInstance tartarus
				}
			}
		}
		
		k8s_systems_ = deploymentEnvironment "Kubernetes · Systems" {
			cluster_ = deploymentNode 			"Pantheon cluster" "" "Kubernetes" "#k8s" {
							olympus_ns_ = deploymentNode "							olympus" "" "Kubernetes ns" "#k8s" {
					olympus_ = softwareSystemInstance olympus
				}
				elysium_ns_ = deploymentNode "				elysium" "" "Kubernetes ns" "#k8s" {
					elysium_ = softwareSystemInstance elysium
				}
				moirai_ns_ = deploymentNode "				moirai" "" "Kubernetes ns" "#k8s" {
					moirai_ = softwareSystemInstance moirai
				}
				lethe_ns_ = deploymentNode "				lethe" "" "Kubernetes ns" "#k8s" {
					lethe_ = softwareSystemInstance lethe
				}
				erebos_ns_ = deploymentNode "				erebos" "" "Kubernetes ns" "#k8s" {
					erebos_ = softwareSystemInstance erebos
				}
				asphodel_ns_ = deploymentNode "				asphodel" "" "Kubernetes ns" "#k8s" {
					asphodel_ = softwareSystemInstance asphodel
				}
				tartarus_ns_ = deploymentNode "				tartarus" "" "Kubernetes ns" "#k8s" {
					tartarus_ = softwareSystemInstance tartarus
				}
			}
		}
		
		local_containers_ = deploymentEnvironment "Local · Containers" {
			laptop = deploymentNode "Developer laptop" "" "Windows 11" "#windows" {
				browser_ = infrastructureNode "Web browser" "" "Firefox" "#firefox, #web"
				
				terminal_ = deploymentNode "Terminal" "" "Windows Terminal" "#terminal" {
					go_ = deploymentNode "Go toolchain" "" "Go" "#go" {
						hephaestus_ = containerInstance olympus.hephaestus
					}
					rust_ = deploymentNode "Rust toolchain" "" "Rust" "#rust" {
						audit_ = containerInstance lethe.audit
					}
				}
				
				emulator_ = deploymentNode "Android emulator" "" "Android Studio" "#android" {
					flutter_ = deploymentNode "Flutter runtime" "" "Flutter" "#flutter" {
						app_ = containerInstance elysium.app
					}
				}
				
				orchestration_ = deploymentNode "Orchestration" "" "Aspire" "#aspire" {
					dashboard_ = infrastructureNode "Aspire Dashboard" "Telemetry and resource overview" "Aspire" "#web, #aspire"
					
					olympus_d_ = deploymentNode "olympus" "" "Aspire hosting" "#aspire" {
						gateway_ = containerInstance olympus.zeus
						athena_ = containerInstance olympus.athena
						portal_ = containerInstance olympus.portal
						forge_ = containerInstance olympus.forge
						hermes_d_ = deploymentNode "servicebus emulator" "" "Docker" "#docker" {
							hermes_ = containerInstance olympus.hermes
						}
						ambrosia_d_ = deploymentNode "redis" "" "Docker" "#docker" {
							ambrosia_ = containerInstance olympus.ambrosia
						}
					}
					elysium_d_ = deploymentNode "elysium" "" "Aspire hosting" "#aspire" {
						feed_ = containerInstance elysium.feed
						fields_ = containerInstance elysium.fields
						muses_ = containerInstance elysium.muses
						nectar_d_ = deploymentNode "cosmos emulator" "" "Docker" "#docker" {
							nectar_ = containerInstance elysium.nectar
						}
						harp_d_ = deploymentNode "kafka" "" "Docker" "#docker" {
							harp_ = containerInstance elysium.harp
						}
						ambrosiaviews_d_ = deploymentNode "elasticsearch" "" "Docker" "#docker" {
							ambrosiaviews_ = containerInstance elysium.ambrosiaviews
						}
					}
					moirai_d_ = deploymentNode "moirai" "" "Aspire hosting" "#aspire" {
						clotho_ = containerInstance moirai.clotho
						lachesis_ = containerInstance moirai.lachesis
						atropos_ = containerInstance moirai.atropos
						spindle_ = containerInstance moirai.spindle
						loom_d_ = deploymentNode "postgresql" "" "Docker" "#docker" {
							loom_ = containerInstance moirai.loom
						}
						signal_d_ = deploymentNode "event grid simulator" "" "Docker" "#docker" {
							signal_ = containerInstance moirai.signal
						}
					}
					lethe_d_ = deploymentNode "lethe" "" "Aspire hosting" "#aspire" {
						api_ = containerInstance lethe.api
						consent_ = containerInstance lethe.consent
						shredder_ = containerInstance lethe.shredder
						river_d_ = deploymentNode "nats" "" "Docker" "#docker" {
							river_ = containerInstance lethe.river
						}
						ledgerdb_d_ = deploymentNode "postgresql" "" "Docker" "#docker" {
							ledgerdb_ = containerInstance lethe.ledgerdb
						}
						vault_d_ = deploymentNode "vault" "" "Docker" "#docker" {
							vault_ = containerInstance lethe.vault
						}
					}
					erebos_d_ = deploymentNode "erebos" "" "Aspire hosting" "#aspire" {
						pager_ = containerInstance erebos.pager
						torch_d_ = deploymentNode "otel collector" "" "Docker" "#docker" {
							torch_ = containerInstance erebos.torch
						}
						watchtower_d_ = deploymentNode "grafana" "" "Docker" "#docker" {
							watchtower_ = containerInstance erebos.watchtower
						}
						shadows_d_ = deploymentNode "loki" "" "Docker" "#docker" {
							shadows_ = containerInstance erebos.shadows
						}
						tracestore_d_ = deploymentNode "tempo" "" "Docker" "#docker" {
							tracestore_ = containerInstance erebos.tracestore
						}
					}
					asphodel_d_ = deploymentNode "asphodel" "" "Aspire hosting" "#aspire" {
						oracle_ = containerInstance asphodel.oracle
						dashboards_d_ = deploymentNode "grafana" "" "Docker" "#docker" {
							dashboards_ = containerInstance asphodel.dashboards
						}
						warehouse_d_ = deploymentNode "clickhouse" "" "Docker" "#docker" {
							warehouse_ = containerInstance asphodel.warehouse
						}
						meadow_d_ = deploymentNode "azurite" "" "Docker" "#docker" {
							meadow_ = containerInstance asphodel.meadow
						}
						reaper_d_ = deploymentNode "spark" "" "Docker" "#docker" {
							reaper_ = containerInstance asphodel.reaper
						}
						schedule_d_ = deploymentNode "airflow" "" "Docker" "#docker" {
							schedule_ = containerInstance asphodel.schedule
						}
					}
					tartarus_d_ = deploymentNode "tartarus" "" "Aspire hosting" "#aspire" {
						cerberus_ = containerInstance tartarus.cerberus
						charon_ = containerInstance tartarus.charon
						minos_ = containerInstance tartarus.minos
						themis_ = containerInstance tartarus.themis
						hecate_d_ = deploymentNode "keycloak" "" "Docker" "#docker" {
							hecate_ = containerInstance tartarus.hecate
						}
						mnemosyne_d_ = deploymentNode "postgresql" "" "Docker" "#docker" {
							mnemosyne_ = containerInstance tartarus.mnemosyne
						}
						styx_d_ = deploymentNode "rabbitmq" "" "Docker" "#docker" {
							styx_ = containerInstance tartarus.styx
						}
						anamnesis_d_ = deploymentNode "pgweb" "" "Docker" "#docker" {
							anamnesis_ = containerInstance tartarus.anamnesis
						}
						clio_d_ = deploymentNode "structurizr" "" "Docker" "#docker" {
							clio_ = containerInstance tartarus.clio
						}
					}
				}
				
				browser_ -> orchestration_.dashboard_ "reads telemetry and credentials" "HTTPS"
				browser_ -> orchestration_.olympus_d_.portal_ "operates the pantheon from" "HTTPS"
				browser_ -> orchestration_.elysium_d_.fields_ "browses the feed on" "HTTPS"
				browser_ -> orchestration_.moirai_d_.spindle_ "steers workflows in" "HTTPS"
				browser_ -> orchestration_.lethe_d_.consent_ "manages consent in" "HTTPS"
				browser_ -> orchestration_.erebos_d_.watchtower_d_.watchtower_ "reads telemetry in" "HTTPS"
				browser_ -> orchestration_.asphodel_d_.dashboards_d_.dashboards_ "reviews usage in" "HTTPS"
				browser_ -> orchestration_.tartarus_d_.cerberus_ "exercises" "HTTPS"
				browser_ -> orchestration_.tartarus_d_.anamnesis_d_.anamnesis_ "inspects the circles through" "HTTPS"
				browser_ -> orchestration_.tartarus_d_.clio_d_.clio_ "explores architecture" "HTTPS"
				browser_ -> orchestration_.tartarus_d_.themis_ "explores technology stack" "HTTPS"
				terminal_.go_.hephaestus_ -> orchestration_.olympus_d_.gateway_ "submits manifests via" "HTTPS"
				terminal_.rust_.audit_ -> orchestration_.lethe_d_.ledgerdb_d_.ledgerdb_ "reads" "SQL"
				emulator_.flutter_.app_ -> orchestration_.elysium_d_.feed_ "reads feeds from" "HTTPS / JSON"
			}
		}
		
		k8s_containers_ = deploymentEnvironment "Kubernetes · Containers" {
			laptop = deploymentNode "Developer laptop" "" "Windows 11" "#windows" {
				browser_ = infrastructureNode "Web browser" "" "Firefox" "#firefox, #web"
				
				terminal_ = deploymentNode "Terminal" "" "Windows Terminal" "#terminal" {
					go_ = deploymentNode "Go toolchain" "" "Go" "#go" {
						hephaestus_ = containerInstance olympus.hephaestus
					}
					rust_ = deploymentNode "Rust toolchain" "" "Rust" "#rust" {
						audit_ = containerInstance lethe.audit
					}
				}
				
				emulator_ = deploymentNode "Android emulator" "" "Android Studio" "#android" {
					flutter_ = deploymentNode "Flutter runtime" "" "Flutter" "#flutter" {
						app_ = containerInstance elysium.app
					}
				}
			}
			
			cluster_ = deploymentNode "Pantheon cluster" "" "Kubernetes" "#k8s" {
				ingress_ = infrastructureNode "Traefik IngressRoutes" "" "Traefik" "#traefik"
				
				olympus_ns_ = deploymentNode "				olympus" "" "Kubernetes ns" "#k8s" {
					gateway_d_ = deploymentNode "zeus-gateway" "" "Docker" "#docker" {
						gateway_ = containerInstance olympus.zeus
					}
					athena_d_ = deploymentNode "athena" "" "Docker" "#docker" {
						athena_ = containerInstance olympus.athena
					}
					portal_d_ = deploymentNode "portal" "" "Docker" "#docker" {
						portal_ = containerInstance olympus.portal
					}
					forge_d_ = deploymentNode "forge" "" "Docker" "#docker" {
						forge_ = containerInstance olympus.forge
					}
					hermes_d_ = deploymentNode "servicebus" "" "Azure" "#azure" {
						hermes_ = containerInstance olympus.hermes
					}
					ambrosia_d_ = deploymentNode "redis" "" "Docker" "#docker" {
						ambrosia_ = containerInstance olympus.ambrosia
					}
				}
				elysium_ns_ = deploymentNode "				elysium" "" "Kubernetes ns" "#k8s" {
					feed_d_ = deploymentNode "feed" "" "Docker" "#docker" {
						feed_ = containerInstance elysium.feed
					}
					fields_d_ = deploymentNode "fields" "" "Docker" "#docker" {
						fields_ = containerInstance elysium.fields
					}
					muses_d_ = deploymentNode "muses" "" "Docker" "#docker" {
						muses_ = containerInstance elysium.muses
					}
					nectar_d_ = deploymentNode "cosmos" "" "Azure" "#azure" {
						nectar_ = containerInstance elysium.nectar
					}
					harp_d_ = deploymentNode "kafka" "" "Docker" "#docker" {
						harp_ = containerInstance elysium.harp
					}
					ambrosiaviews_d_ = deploymentNode "elasticsearch" "" "Docker" "#docker" {
						ambrosiaviews_ = containerInstance elysium.ambrosiaviews
					}
				}
				moirai_ns_ = deploymentNode "				moirai" "" "Kubernetes ns" "#k8s" {
					clotho_d_ = deploymentNode "clotho" "" "Docker" "#docker" {
						clotho_ = containerInstance moirai.clotho
					}
					lachesis_d_ = deploymentNode "lachesis" "" "Docker" "#docker" {
						lachesis_ = containerInstance moirai.lachesis
					}
					atropos_d_ = deploymentNode "atropos" "" "Azure" "#azure" {
						atropos_ = containerInstance moirai.atropos
					}
					spindle_d_ = deploymentNode "spindle" "" "Docker" "#docker" {
						spindle_ = containerInstance moirai.spindle
					}
					signal_d_ = deploymentNode "event grid" "" "Azure" "#azure" {
						signal_ = containerInstance moirai.signal
					}
					loom_d_ = deploymentNode "postgresql" "" "Docker" "#docker" {
						loom_ = containerInstance moirai.loom
					}
				}
				lethe_ns_ = deploymentNode "				lethe" "" "Kubernetes ns" "#k8s" {
					api_d_ = deploymentNode "api" "" "Docker" "#docker" {
						api_ = containerInstance lethe.api
					}
					consent_d_ = deploymentNode "consent" "" "Docker" "#docker" {
						consent_ = containerInstance lethe.consent
					}
					shredder_d_ = deploymentNode "shredder" "" "Docker" "#docker" {
						shredder_ = containerInstance lethe.shredder
					}
					river_d_ = deploymentNode "nats" "" "Docker" "#docker" {
						river_ = containerInstance lethe.river
					}
					ledgerdb_d_ = deploymentNode "postgresql" "" "Docker" "#docker" {
						ledgerdb_ = containerInstance lethe.ledgerdb
					}
					vault_d_ = deploymentNode "vault" "" "Docker" "#docker" {
						vault_ = containerInstance lethe.vault
					}
				}
				erebos_ns_ = deploymentNode "				erebos" "" "Kubernetes ns" "#k8s" {
					pager_d_ = deploymentNode "pager" "" "Docker" "#docker" {
						pager_ = containerInstance erebos.pager
					}
					torch_d_ = deploymentNode "otel collector" "" "Docker" "#docker" {
						torch_ = containerInstance erebos.torch
					}
					watchtower_d_ = deploymentNode "grafana" "" "Docker" "#docker" {
						watchtower_ = containerInstance erebos.watchtower
					}
					shadows_d_ = deploymentNode "loki" "" "Docker" "#docker" {
						shadows_ = containerInstance erebos.shadows
					}
					tracestore_d_ = deploymentNode "tempo" "" "Docker" "#docker" {
						tracestore_ = containerInstance erebos.tracestore
					}
				}
				asphodel_ns_ = deploymentNode "				asphodel" "" "Kubernetes ns" "#k8s" {
					oracle_d_ = deploymentNode "pythia" "" "Docker" "#docker" {
						oracle_ = containerInstance asphodel.oracle
					}
					dashboards_d_ = deploymentNode "grafana" "" "Docker" "#docker" {
						dashboards_ = containerInstance asphodel.dashboards
					}
					warehouse_d_ = deploymentNode "clickhouse" "" "Docker" "#docker" {
						warehouse_ = containerInstance asphodel.warehouse
					}
					meadow_d_ = deploymentNode "data lake" "" "Azure" "#azure" {
						meadow_ = containerInstance asphodel.meadow
					}
					reaper_d_ = deploymentNode "spark" "" "Docker" "#docker" {
						reaper_ = containerInstance asphodel.reaper
					}
					schedule_d_ = deploymentNode "airflow" "" "Docker" "#docker" {
						schedule_ = containerInstance asphodel.schedule
					}
				}
				tartarus_ns_ = deploymentNode "				tartarus" "" "Kubernetes ns" "#k8s" {
					cerberus_d_ = deploymentNode "cerberus" "" "Docker" "#docker" {
						cerberus_ = containerInstance tartarus.cerberus
					}
					charon_d_ = deploymentNode "charon" "" "Docker" "#docker" {
						charon_ = containerInstance tartarus.charon
					}
					minos_d_ = deploymentNode "minos" "" "Docker" "#docker" {
						minos_ = containerInstance tartarus.minos
					}
					hecate_d_ = deploymentNode "hecate" "" "Docker" "#docker" {
						hecate_ = containerInstance tartarus.hecate
					}
					mnemosyne_d_ = deploymentNode "postgresql" "" "Docker" "#docker" {
						mnemosyne_ = containerInstance tartarus.mnemosyne
					}
					styx_d_ = deploymentNode "rabbitmq" "" "Docker" "#docker" {
						styx_ = containerInstance tartarus.styx
					}
					anamnesis_d_ = deploymentNode "pgweb" "" "Docker" "#docker" {
						anamnesis_ = containerInstance tartarus.anamnesis
					}
					clio_d_ = deploymentNode "structurizr" "" "Docker" "#docker" {
						clio_ = containerInstance tartarus.clio
					}
					themis_d_ = deploymentNode "themis" "" "Docker" "#docker" {
						themis_ = containerInstance tartarus.themis
					}
				}
			}
			
			laptop.browser_ -> cluster_.ingress_ "exercises" "HTTPS"
			laptop.terminal_.go_.hephaestus_ -> cluster_.ingress_ "submits manifests via" "HTTPS"
			laptop.terminal_.rust_.audit_ -> cluster_.lethe_ns_.ledgerdb_d_.ledgerdb_ "reads" "SQL"
			laptop.emulator_.flutter_.app_ -> cluster_.ingress_ "reads feeds from" "HTTPS / JSON"
			cluster_.ingress_ -> cluster_.olympus_ns_.gateway_d_.gateway_ "forwards requests to" ""
			cluster_.ingress_ -> cluster_.olympus_ns_.portal_d_.portal_ "forwards requests to" ""
			cluster_.ingress_ -> cluster_.elysium_ns_.feed_d_.feed_ "forwards requests to" ""
			cluster_.ingress_ -> cluster_.elysium_ns_.fields_d_.fields_ "forwards requests to" ""
			cluster_.ingress_ -> cluster_.moirai_ns_.spindle_d_.spindle_ "forwards requests to" ""
			cluster_.ingress_ -> cluster_.lethe_ns_.consent_d_.consent_ "forwards requests to" ""
			cluster_.ingress_ -> cluster_.erebos_ns_.watchtower_d_.watchtower_ "forwards requests to" ""
			cluster_.ingress_ -> cluster_.asphodel_ns_.dashboards_d_.dashboards_ "forwards requests to" ""
			cluster_.ingress_ -> cluster_.tartarus_ns_.cerberus_d_.cerberus_ "forwards requests to" ""
			cluster_.ingress_ -> cluster_.tartarus_ns_.anamnesis_d_.anamnesis_ "forwards requests to" ""
			cluster_.ingress_ -> cluster_.tartarus_ns_.clio_d_.clio_ "forwards requests to" ""
			cluster_.ingress_ -> cluster_.tartarus_ns_.themis_d_.themis_ "forwards requests to" ""
		}
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
		
		dynamic * "ZeusRound" "Zeus' round from the summit: health, census, then thunderous orders that reshape running journeys." {
			zeus -> erebos "Checks the pantheon's health"
			zeus -> asphodel "Reads the census of souls and activity"
			zeus -> olympus "Orders a new plan"
			olympus -> moirai "Re-spins the affected journeys"
			moirai -> erebos "Reports progress and failures"
		}
		
		deployment * local_systems_ "LocalSystems" {
			include *
		}
		
		deployment * k8s_systems_ "KubernetesSystems" {
			include *
		}
		
		deployment * local_containers_ "LocalContainers" {
			include *
		}
		
		deployment * k8s_containers_ "KubernetesContainers" {
			include *
		}
	}
}
