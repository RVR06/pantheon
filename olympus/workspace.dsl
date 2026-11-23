workspace "Olympus" "The pantheon's control plane: gateway, planning, orchestration and tooling." {
	!identifiers hierarchical
	!impliedRelationships false
	
	model {
		delphi = softwareSystem "Delphi" "External oracle providing LLM completions and embeddings." "External" {
			url "https://platform.openai.com/docs"
		}
		
		olympus = softwareSystem "Olympus" "The pantheon's control plane: gateway, planning, orchestration and tooling." "#olympus" {
			ambrosia = container "Ambrosia" "Shared cache of the gods." "Redis" "#cache, #redis"
			
			hermes = container "Hermes" "Courier carrying commands and events between realms." "Azure Service Bus" "#bus, #azure"
			
			athena = container "Athena Planner" "Plans multi-realm journeys and asks Delphi for advice." "Python / FastAPI" "#api, #python" {
				advice = component "Advice Client" "Calls Delphi for completions." "httpx" "#repo" {
					-> delphi "requests completions from"
				}
				strategy = component "Strategy Engine" "Builds the journey plan." "Python" "#judge" {
					-> advice "enriches plans through"
				}
				plans = component "Plan Endpoint" "POST /plans" "FastAPI" "#endpoint" {
					-> strategy "asks for a plan from"
				}
				
				-> hermes "publishes plan events onto" "AMQP"
				-> delphi "Requests advice"
			}
			
			zeus = container "Zeus Gateway" "Front door for every realm: routing, throttling, authorization and aggregation." "YARP / ASP.NET Core" "#gateway, #dotnet" {
				
				router = component "Router" "Matches requests to realm clusters." "YARP" "#router"
				limiter = component "Rate Limiter" "Applies per-hero quotas." "System.Threading.RateLimiting" "#guard"
				authz = component "Authorization Policy" "Maps token claims to realm permissions." "ASP.NET Core Authorization" "#guard"
				aggregator = component "Aggregator" "Fans out to several realms and merges the responses." "C#" "#judge"
				cachebust = component "Response Cache" "Caches idempotent responses in Ambrosia." "StackExchange.Redis" "#repo"
				
				router -> authz "checks every route with"
				router -> limiter "throttles through"
				router -> aggregator "delegates composite routes to"
				aggregator -> cachebust "reads and writes"
				cachebust -> olympus.ambrosia "caches in"
				
				-> athena "routes planning calls to" "HTTPS"
				-> ambrosia "caches responses in" "RESP"
			}
			
			portal = container "Olympus Portal" "Single page console for operating the pantheon." "React / TypeScript" "#web, #typescript" {
				-> zeus "calls" "HTTPS"
			}
			
			hephaestus = container "Hephaestus CLI" "Forges and deploys realm manifests from a terminal." "Go" "#cli, #go" {
				-> zeus "submits manifests via" "HTTPS"
			}
			forge = container "Forge Worker" "Applies manifests prepared by the CLI." ".NET Worker Service" "#worker, #dotnet" {
				-> hermes "consumes manifests from" "AMQP"
				-> ambrosia "locks deployments in" "RESP"
			}
		}
		
		titan = person "Titan" "A platform engineer who runs the pantheon and reads its telemetry." "" {
			-> olympus "operates the pantheon from"
			-> olympus.portal "operates the pantheon from"
			-> olympus.hephaestus "deploys realms with"
			-> olympus.portal "Opens the plan form"
		}
		
	}
	
	views {
		theme https://raw.githubusercontent.com/rvr06/cornifer-contrib/main/themes/topology/theme.json
		theme https://raw.githubusercontent.com/rvr06/cornifer-contrib/main/themes/heraldry2/theme.json
		
		properties {
			"structurizr.sort" "created"
		}
		
		styles {
			element "#cli" {
				shape Terminal
			}
			element "#worker" {
				shape Folder
			}
			element "#gateway" {
				shape RoundedBox
			}
			element "#olympus" {
				stroke #1E88E5
				icon icons/olympus.svg
			}
		}
		
		systemContext olympus "Olympus_Context" {
			include *
		}
		
		container olympus "Olympus_Containers" {
			include *
		}
		
		component olympus.zeus "Zeus_Components" {
			include *
		}
		
		component olympus.athena "Athena_Components" {
			include *
		}
	}
}
