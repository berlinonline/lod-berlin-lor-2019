berlinonline_url = https://raw.githubusercontent.com/berlinonline/lod-berlin-bo/main/data/static/berlinonline.ttl
lod_unit_url = https://raw.githubusercontent.com/berlinonline/lod-berlin-lor/main/data/vocab/units.ttl
wfs_base = https://fbinter.stadt-berlin.de/fb/wfs/data/senstadt/
bezirke_layer = s_wfs_alkis_bezirk
bezirke_wfs_url = $(wfs_base)$(bezirke_layer)

data/temp/void.nt: data/temp
	@echo "converting void.ttl to $@ ..."
	@rdfpipe -o ntriples void.ttl > $@

data/temp/berlinonline.ttl: data/temp
	@echo "downloading $(berlinonline_url)..."
	@curl -s -o $@ "$(berlinonline_url)"

data/vocab/units.ttl:
	@echo "downloading $(lod_unit_url)..."
	@curl -s -o $@ "$(lod_unit_url)"

# This target creates the RDF file that serves as the input to the static site generator.
# All data should be merged in this file. This should include at least the VOID dataset
# description and the actual data.
# The target works by merging all prerequisites 
data/temp/all.nt: data/temp void.ttl data/temp/berlinonline.ttl data/target/lors.ttl data/vocab/units.ttl
	@echo "combining $(filter-out $<,$^) to $@ ..."
	@rdfpipe -o ntriples $(filter-out $<,$^) > $@

cbds: _includes/cbds data/temp/all.nt
	@echo "computing concise bounded descriptions for all subjects in input data"
	@python bin/compute_cbds.py --base="https://berlinonline.github.io/lod-berlin-lor-2019/"

# LOR-related targets

# Conversion of source data to RDF
data/target/lors.ttl: data/temp/bezirke.geojson data/temp/prog.geojson data/temp/bez.geojson data/temp/plan.geojson
	@echo "writing Turtle to $@ ..."
	@python bin/geojson2rdf.py --output=$@

# getting the source data for Bezirke
data/temp/bezirke.xml: data/temp
	@echo "getting layer $(bezirke_layer) from $(bezirke_wfs_url) ..."
	@echo "writing to $@ ..."
	@curl --output $@ "$(bezirke_wfs_url)?service=wfs&version=2.0.0&request=GetFeature&typeNames=$(bezirke_layer)"

# getting the source data for Prognoseraum, Bezirksregion, Planungsraum
.PRECIOUS: data/temp/%.xml
data/temp/%.xml: data/temp
	$(eval LAYER := "s_lor_$(basename $(notdir $@))")
	@echo "getting layer $(LAYER) from $(wfs_base)$(LAYER) ..."
	@echo "writing to $@ ..."
	@curl --output $@ "$(wfs_base)$(LAYER)?service=wfs&version=2.0.0&request=GetFeature&typeNames=$(LAYER)"

# Conversion of source data to GeoJSON and projecting to WGS84
data/temp/%.geojson: data/temp/%.xml
	@echo "converting $< to geojson"
	@ogr2ogr -fieldTypeToString All -f "GeoJSON" $@ -s_srs EPSG:25833 -t_srs WGS84 $<

# Just for looking: formatting the source data
data/temp/%.formatted.xml: data/temp/%.xml
	@echo "formatting $<, writing to $@ ..."
	@xmllint --format $< > $@

# Housekeeping

.PHONY: serve-local
serve-local: data/temp/all.nt cbds
	@echo "serving local version of static LOD site ..."
	@bundle exec jekyll serve

clean: clean-temp clean-cbds clean-jekyll

clean-temp:
	@echo "deleting temp folder ..."
	@rm -rf data/temp

data/temp:
	@echo "creating temp directory ..."
	@mkdir -p data/temp

_includes/cbds:
	@echo "creating $@ directory ..."
	@mkdir -p $@

clean-cbds:
	@echo "deleting cbd folder ..."
	@rm -rf _includes/cbds

clean-jekyll:
	@echo "deleting jekyll artifacts ..."
	@rm -rf _site
	@rm -rf .jekyll-cache