README
-process_data
	-GBIF_occurrence
		-monthcount: Number of occurrences of each species every month with the centroid coordinates of cell.
		-yearcount: Number of occurrences of each species every year with centroid coordinates.
	-climate
		Aggregated climatic data from 2019-2024.
		aet: Actual Evapotranspiration
		def: Climate Water Deficit
		pet: Potential Evapotranspiration
		ppt: Precipitation
		tmax: Max temperature
		tmin: Min temperature
	-soil
		Soil data complied by cell. Nan are removed.
		bdod: Soil bulky density
		bedrockdepth: Absolute bedrock depth
		clay: Clay proportion
		phh2o: Soil pH
		silt: Silt proportion
		twi: Topographical wetness index
	-terrain
		Terrain data complied by cell. Nan are removed.
		tri: Terrain Ruggedness Index
		mi: Minimum
		Ma: Maximum
		Md: Median
		sd: Standard deviation
		psd: Pooled standard deviation
	
	-cell_id.rda: A file contains cell ID of non-NA FLII raster. Used to clean Nan grids in the above files.
	
-raw_data
	-GBIF202504
		Raw GBIF data by species.
	-climate
		Raw TerraClimate data by year.
	-soil
		Raw data for Absolute depth bedrock, bdod, clay, phh2o, silt, twi
	-terrain
		Raw data for Elevation, Slope and TRI.

Github Repository:
https://github.com/XingJH-1998/FLII
