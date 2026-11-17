workspace "Asphodel" "The meadow of the ordinary dead: analytics lake, warehouse and dashboards." {
	!identifiers hierarchical
	!impliedRelationships false
	
	model {
		asphodel = softwareSystem "Asphodel" "The meadow of the ordinary dead: analytics lake, warehouse and dashboards." "#asphodel" {
			warehouse = container "Warehouse" "Columnar store for reports." "ClickHouse" "#db, #clickhouse"
			
			meadow = container "Meadow" "Raw landing zone for every event." "Azure Data Lake" "#db, #azure"
			
			reaper = container "Reaper" "Batch ETL that harvests the meadow into the warehouse." "Apache Spark" "#worker, #apache" {
				load = component "Loader" "Writes into the warehouse." "JDBC" "#jdbc" {
					-> asphodel.warehouse "writes to"
				}
				cleanse = component "Cleanser" "Deduplicates and validates records." "PySpark" "#spark" {
					-> load "hands over to"
				}
				extract = component "Extractor" "Reads raw parquet files." "Spark SQL" "#spark" {
					-> cleanse "streams to"
					-> asphodel.meadow "reads from"
				}
				
				-> meadow "reads" "ABFS"
				-> warehouse "loads" "JDBC"
			}
			
			oracle = container "Pythia API" "GraphQL endpoint for analysts." "Node.js / Apollo" "#api, #nodejs" {
				loader = component "Data Loader" "Batches warehouse lookups." "DataLoader" "#dataloader" {
					-> asphodel.warehouse "queries"
				}
				resolvers = component "Resolvers" "Map GraphQL fields to queries." "Apollo Server" "#appollo" {
					-> loader "batches through"
				}
				
				-> warehouse "queries" "HTTP"
			}
			
			dashboards = container "Dashboards" "Interactive charts for analysts." "Grafana" "#web, #grafana" {
				-> oracle "queries" "GraphQL"
			}
			
			schedule = container "Harvest Scheduler" "Triggers the nightly harvest." "Airflow" "#worker, #airflow" {
				-> reaper "triggers" "REST"
			}
		}
		
		aeacus = person "Aeacus" "A judge of the dead who audits consent and erasure requests." "" {
			-> asphodel "reviews usage in"
			-> asphodel.dashboards "reviews usage in"
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
			element "#asphodel" {
				stroke #7a4a8c
				icon icons/asphodel.svg
			}
		}
		
		systemContext asphodel "Asphodel_Context" {
			include *
		}
		
		container asphodel "Asphodel_Containers" {
			include *
		}
		
		component asphodel.reaper "Reaper_Components" {
			include *
		}
		
		component asphodel.oracle "Pythia_Components" {
			include *
		}
	}
}
