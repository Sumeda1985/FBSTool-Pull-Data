CREATE SCHEMA IF NOT EXISTS core;

-- Create user
-- CREATE USER suafbsdbuser WITH PASSWORD 'xeoEJ7UOxiQQ';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE suafbsdb TO suafbsdbuser;
GRANT ALL PRIVILEGES ON SCHEMA public TO suafbsdbuser;
GRANT ALL PRIVILEGES ON SCHEMA core TO suafbsdbuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO suafbsdbuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA core TO suafbsdbuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO suafbsdbuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA core TO suafbsdbuser;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO suafbsdbuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA core GRANT ALL PRIVILEGES ON TABLES TO suafbsdbuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO suafbsdbuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA core GRANT ALL PRIVILEGES ON SEQUENCES TO suafbsdbuser;

CREATE TABLE dbcountry (
       "id_key" BIGSERIAL PRIMARY KEY,
       "CountryM49" character(20),
       "CPCCode" character(20),
       "ElementCode" character(20),
       "Year" character(20),
       "Value" numeric(21,6),
       "Flag" character(20)
);

ALTER TABLE dbcountry
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE dbcountry_history (LIKE dbcountry);

CREATE TRIGGER versioning_trigger_dbcountry
BEFORE INSERT OR UPDATE OR DELETE ON dbcountry
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'dbcountry_history', true
);

-- Create new table in core schema
CREATE TABLE core.data_tool_2000_2009 (
       "id_key" BIGSERIAL PRIMARY KEY,
       "CountryM49" character(20),
       "CPCCode" character(20),
       "ElementCode" character(20),
       "Year" character(20),
       "Value" numeric(21,6),
       "Flag" character(20)
);

ALTER TABLE core.data_tool_2000_2009
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.data_tool_2000_2009_history (LIKE core.data_tool_2000_2009);

CREATE TRIGGER versioning_trigger_data_tool
BEFORE INSERT OR UPDATE OR DELETE ON core.data_tool_2000_2009
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.data_tool_2000_2009_history', true
);

-- Create tree table
CREATE TABLE tree (
       "id_key" BIGSERIAL PRIMARY KEY,
       "geographicAreaM49" character(20),
       "measuredElementSuaFbs" character(20),
       "measuredItemParentCPC" character(20),
       "measuredItemChildCPC" character(20),
       "timePointYears" character(20),
       "Value" numeric(21,6),
       "flagObservationStatus" character(20),
       "flagMethod" character(20)
);

ALTER TABLE tree
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE tree_history (LIKE tree);

CREATE TRIGGER versioning_trigger_tree
BEFORE INSERT OR UPDATE OR DELETE ON tree
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'tree_history', true
);

-- Create processed_item_datatable in core schema
CREATE TABLE core.processed_item_datatable (
       "id_key" BIGSERIAL PRIMARY KEY,
       "measured_item_cpc" character(20),
       "faostat" character(20),
);

ALTER TABLE core.processed_item_datatable
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.processed_item_datatable_history (LIKE core.processed_item_datatable);

CREATE TRIGGER versioning_trigger_processed_item
BEFORE INSERT OR UPDATE OR DELETE ON core.processed_item_datatable
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.processed_item_datatable_history', true
);

-- Create item_map table in core schema
CREATE TABLE core.item_map (
       "id_key" BIGSERIAL PRIMARY KEY,
       "language" character(20),
       "code" character(20),
       "description" character(500),
       "selectionOnly" boolean,
       "type" character(20)
);

ALTER TABLE core.item_map
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.item_map_history (LIKE core.item_map);

CREATE TRIGGER versioning_trigger_item_map
BEFORE INSERT OR UPDATE OR DELETE ON core.item_map
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.item_map_history', true
);

-- Create zeroweight_coproducts table in core schema
CREATE TABLE core.zeroweight_coproducts (
       "id_key" BIGSERIAL PRIMARY KEY,
       "measured_item_child_cpc" character(20),
       "branch" character(20)
);

ALTER TABLE core.zeroweight_coproducts
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.zeroweight_coproducts_history (LIKE core.zeroweight_coproducts);

CREATE TRIGGER versioning_trigger_zeroweight_coproducts
BEFORE INSERT OR UPDATE OR DELETE ON core.zeroweight_coproducts
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.zeroweight_coproducts_history', true
);

-- Create pop_sws table
CREATE TABLE pop_sws (
       "id_key" BIGSERIAL PRIMARY KEY,
       "geographicAreaM49" character(20),
       "measuredElement" character(20),
       "timePointYears" character(20),
       "Value" numeric(21,6),
       "flagObservationStatus" character(20),
       "flagMethod" character(20)
);

ALTER TABLE pop_sws
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE pop_sws_history (LIKE pop_sws);

CREATE TRIGGER versioning_trigger_pop_sws
BEFORE INSERT OR UPDATE OR DELETE ON pop_sws
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'pop_sws_history', true
);

-- Create utilization_table in core schema
CREATE TABLE core.utilization_table (
       "id_key" BIGSERIAL PRIMARY KEY,
       "fcl_code" character(20),
       "cpc_code" character(20),
       "primary_item" character(20),
       "proxy_primary" character(20),
       "derived" character(20),
       "food_item" character(20),
       "stock" character(20),
       "orphan" character(20),
       "feed" character(20),
       "feed_desc" character(20)
);

ALTER TABLE core.utilization_table
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.utilization_table_history (LIKE core.utilization_table);

CREATE TRIGGER versioning_trigger_utilization
BEFORE INSERT OR UPDATE OR DELETE ON core.utilization_table
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.utilization_table_history', true
);

-- Create zero_weight table in core schema
CREATE TABLE core.zero_weight (
       "id_key" BIGSERIAL PRIMARY KEY,
       "x" character(20)
);

ALTER TABLE core.zero_weight
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.zero_weight_history (LIKE core.zero_weight);

CREATE TRIGGER versioning_trigger_zero_weight
BEFORE INSERT OR UPDATE OR DELETE ON core.zero_weight
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.zero_weight_history', true
);

-- Create nutrient_data table
CREATE TABLE nutrient_data (
       "id_key" BIGSERIAL PRIMARY KEY,
       "geographicAreaM49" character(20),
       "measuredElement" character(20),
       "measuredItemCPC" character(20),
       "timePointYearsSP" character(20),
       "Value" numeric(21,6)
);

ALTER TABLE nutrient_data
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE nutrient_data_history (LIKE nutrient_data);

CREATE TRIGGER versioning_trigger_nutrient_data
BEFORE INSERT OR UPDATE OR DELETE ON nutrient_data
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'nutrient_data_history', true
);

-- Create fbs_tree table
CREATE TABLE fbs_tree (
       "id_key" BIGSERIAL PRIMARY KEY,
       "id1" character(20),
       "id2" character(20),
       "id3" character(20),
       "id4" character(20),
       "item_sua_fbs" character(20)
);

ALTER TABLE fbs_tree
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE fbs_tree_history (LIKE fbs_tree);

CREATE TRIGGER versioning_trigger_fbs_tree
BEFORE INSERT OR UPDATE OR DELETE ON fbs_tree
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'fbs_tree_history', true
);

-- Create share_up_down_tree table in core schema
CREATE TABLE core.share_up_down_tree (
       "id_key" BIGSERIAL PRIMARY KEY,
       "geographicAreaM49" character(20),
       "measuredElementSuaFbs" character(20),
       "measuredItemParentCPC" character(20),
       "measuredItemChildCPC" character(20),
       "timePointYears" character(20),
       "shareUpDown" numeric(21,6)
);

ALTER TABLE core.share_up_down_tree
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.share_up_down_tree_history (LIKE core.share_up_down_tree);

CREATE TRIGGER versioning_trigger_share_up_down
BEFORE INSERT OR UPDATE OR DELETE ON core.share_up_down_tree
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.share_up_down_tree_history', true
);

-- Create fbs_standardized_wipe table in core schema
CREATE TABLE core.fbs_standardized_wipe (
       "id_key" BIGSERIAL PRIMARY KEY,
       "geographicAreaM49" character(20),
       "measuredElementSuaFbs" character(20),
       "measuredItemFbsSua" character(20),
       "timePointYears" character(20),
       "Value" numeric(21,6),
       "flagObservationStatus" character(20),
       "flagMethod" character(20)
);

ALTER TABLE core.fbs_standardized_wipe
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.fbs_standardized_wipe_history (LIKE core.fbs_standardized_wipe);

CREATE TRIGGER versioning_trigger_fbs_standardized_wipe
BEFORE INSERT OR UPDATE OR DELETE ON core.fbs_standardized_wipe
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.fbs_standardized_wipe_history', true
);

-- Create fbs_balanced_wipe table in core schema
CREATE TABLE core.fbs_balanced_wipe (
       "id_key" BIGSERIAL PRIMARY KEY,
       "geographicAreaM49" character(20),
       "measuredElementSuaFbs" character(20),
       "measuredItemFbsSua" character(20),
       "timePointYears" character(20),
       "Value" numeric(21,6),
       "flagObservationStatus" character(20),
       "flagMethod" character(20)
);

ALTER TABLE core.fbs_balanced_wipe
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.fbs_balanced_wipe_history (LIKE core.fbs_balanced_wipe);

CREATE TRIGGER versioning_trigger_fbs_balanced_wipe
BEFORE INSERT OR UPDATE OR DELETE ON core.fbs_balanced_wipe
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.fbs_balanced_wipe_history', true
);

-- Create parent_nodes table in core schema
CREATE TABLE core.parent_nodes (
       "id_key" BIGSERIAL PRIMARY KEY,
       "node" character(20),
       "level" character(20)
);

ALTER TABLE core.parent_nodes
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.parent_nodes_history (LIKE core.parent_nodes);

CREATE TRIGGER versioning_trigger_parent_nodes
BEFORE INSERT OR UPDATE OR DELETE ON core.parent_nodes
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.parent_nodes_history', true
);

-- Create food_demand table in core schema
CREATE TABLE core.food_demand (
       "id_key" BIGSERIAL PRIMARY KEY,
       "CPCCode" character(20),
       "FBSCode" character(20),
       "Food_Demand" character(20),
       "Food_Function" character(20),
       "Description" character(20),
       "Elasticity" numeric(21,6)
);

ALTER TABLE core.food_demand
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.food_demand_history (LIKE core.food_demand);

CREATE TRIGGER versioning_trigger_food_demand
BEFORE INSERT OR UPDATE OR DELETE ON core.food_demand
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.food_demand_history', true
);

-- Create food_classification table
CREATE TABLE food_classification (
       "id_key" BIGSERIAL PRIMARY KEY,
       "CPCCode" character(20),
       "Type" character(20)
);

ALTER TABLE food_classification
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE food_classification_history (LIKE food_classification);

CREATE TRIGGER versioning_trigger_food_classification
BEFORE INSERT OR UPDATE OR DELETE ON food_classification
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'food_classification_history', true
);

-- Create gdp_data table in core schema
CREATE TABLE core.gdp_data (
       "id_key" BIGSERIAL PRIMARY KEY,
       "Year" character(20),
       "CountryM49" character(20),
       "GDP_per_capita_usd_const_2015" numeric(21,6)
);

ALTER TABLE core.gdp_data
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.gdp_data_history (LIKE core.gdp_data);

CREATE TRIGGER versioning_trigger_gdp_data
BEFORE INSERT OR UPDATE OR DELETE ON core.gdp_data
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.gdp_data_history', true
);

-- Create trade_map table in core schema
CREATE TABLE core.trade_map (
       "id_key" BIGSERIAL PRIMARY KEY,
       "area" character(20),
       "flow" character(20),
       "hs" character(20),
       "cpc" character(20)
);

ALTER TABLE core.trade_map
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.trade_map_history (LIKE core.trade_map);

CREATE TRIGGER versioning_trigger_trade_map
BEFORE INSERT OR UPDATE OR DELETE ON core.trade_map
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.trade_map_history', true
);

-- Create loss_ratios table
CREATE TABLE loss_ratios (
       "id_key" BIGSERIAL PRIMARY KEY,
       "CountryM49" character(20),
       "CPCCode" character(20),
       "ElementCode" character(20),
       "Year" character(20),
       "Value" numeric(21,6),
       "Flag" character(20)
);

ALTER TABLE loss_ratios
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE loss_ratios_history (LIKE loss_ratios);

CREATE TRIGGER versioning_trigger_loss_ratios
BEFORE INSERT OR UPDATE OR DELETE ON loss_ratios
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'loss_ratios_history', true
);

-- Create feed_ratios table
CREATE TABLE feed_ratios (
       "id_key" BIGSERIAL PRIMARY KEY,
       "CountryM49" character(20),
       "CPCCode" character(20),
       "ElementCode" character(20),
       "Year" character(20),
       "Value" numeric(21,6),
       "Flag" character(20)
);

ALTER TABLE feed_ratios
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE feed_ratios_history (LIKE feed_ratios);

CREATE TRIGGER versioning_trigger_feed_ratios
BEFORE INSERT OR UPDATE OR DELETE ON feed_ratios
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'feed_ratios_history', true
);

-- Create seed_rates table
CREATE TABLE seed_rates (
       "id_key" BIGSERIAL PRIMARY KEY,
       "CountryM49" character(20),
       "CPCCode" character(20),
       "ElementCode" character(20),
       "Year" character(20),
       "Value" numeric(21,6),
       "Flag" character(20)
);

ALTER TABLE seed_rates
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE seed_rates_history (LIKE seed_rates);

CREATE TRIGGER versioning_trigger_seed_rates
BEFORE INSERT OR UPDATE OR DELETE ON seed_rates
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'seed_rates_history', true
);

-- Create fish table
CREATE TABLE fish (
       "id_key" BIGSERIAL PRIMARY KEY,
       "CPCCode" character(20),
       "ElementCode" character(20),
       "Year" character(20),
       "Value" numeric(21,6),
       "Flag" character(20)
);

ALTER TABLE fish
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE fish_history (LIKE fish);

CREATE TRIGGER versioning_trigger_fish
BEFORE INSERT OR UPDATE OR DELETE ON fish
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'fish_history', true
);

-- Create TourismNoIndustrial table in core schema
CREATE TABLE core.TourismNoIndustrial (
       "id_key" BIGSERIAL PRIMARY KEY,
       "TourismNoIndustrial" integer(6)
);

ALTER TABLE core.TourismNoIndustrial
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.TourismNoIndustrial_history (LIKE core.TourismNoIndustrial);

CREATE TRIGGER versioning_trigger_TourismNoIndustrial
BEFORE INSERT OR UPDATE OR DELETE ON core.TourismNoIndustrial
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.TourismNoIndustrial_history', true
);

-- Create flagValidTable in core schema
CREATE TABLE core.flagValidTable (
       "id_key" BIGSERIAL PRIMARY KEY,
       "flagObservationStatus" character(20),
       "Valid" boolean,
       "Protected" boolean
);

ALTER TABLE core.flagValidTable
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.flagValidTable_history (LIKE core.flagValidTable);

CREATE TRIGGER versioning_trigger_flagValidTable
BEFORE INSERT OR UPDATE OR DELETE ON core.flagValidTable
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.flagValidTable_history', true
);

-- Create SUA_Commodities table in core schema
CREATE TABLE core.SUA_Commodities (
       "id_key" BIGSERIAL PRIMARY KEY,
       "language" character(20),
       "CPCCode" character(20),
       "Commodity" character(20)
);

ALTER TABLE core.SUA_Commodities
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.SUA_Commodities_history (LIKE core.SUA_Commodities);

CREATE TRIGGER versioning_trigger_SUA_Commodities
BEFORE INSERT OR UPDATE OR DELETE ON core.SUA_Commodities
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.SUA_Commodities_history', true
);

-- Create elementMap table in core schema
CREATE TABLE core.elementMap (
       "id_key" BIGSERIAL PRIMARY KEY,
       "language" character(20),
       "code" character(20),
       "description" character(20),
       "selectionOnly" boolean,
       "type" character(20)
);

ALTER TABLE core.elementMap
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.elementMap_history (LIKE core.elementMap);

CREATE TRIGGER versioning_trigger_elementMap
BEFORE INSERT OR UPDATE OR DELETE ON core.elementMap
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.elementMap_history', true
);

-- Create itemCodeKey table in core schema
CREATE TABLE core.itemCodeKey (
       "id_key" BIGSERIAL PRIMARY KEY,
       "itemtype" character(20),
       "description_en" character(20),
       "description_es" character(20),
       "description_fr" character(20),
       "description_ar" character(20),
       "areaharvested" character(20),
       "yield" character(20),
       "factor" numeric(21,6),
       "production" character(20),
       "imports" character(20),
       "exports" character(20),
       "stock" character(20),
       "food" character(20),
       "feed" character(20),
       "seed" character(20),
       "loss" character(20),
       "industrial" character(20),
       "tourist" character(20),
       "residual" character(20),
       "foodmanufacturing" character(20)
);

ALTER TABLE core.itemCodeKey
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.itemCodeKey_history (LIKE core.itemCodeKey);

CREATE TRIGGER versioning_trigger_itemCodeKey
BEFORE INSERT OR UPDATE OR DELETE ON core.itemCodeKey
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.itemCodeKey_history', true
);

-- Create output_elements table in core schema
CREATE TABLE core.output_elements (
       "id_key" BIGSERIAL PRIMARY KEY,
       "language" character(20),
       "ElementCode" character(20),
       "ElementType" character(20),
       "Unit" character(20),
       "Name" character(20),
       "include_fbs" boolean
);

ALTER TABLE core.output_elements
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.output_elements_history (LIKE core.output_elements);

CREATE TRIGGER versioning_trigger_output_elements
BEFORE INSERT OR UPDATE OR DELETE ON core.output_elements
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.output_elements_history', true
);

-- Create cpc2.1 table in core schema
CREATE TABLE core."cpc2.1" (
       "id_key" BIGSERIAL PRIMARY KEY,
       "CPCCode" character(20),
       "Commodity" character(500),
       "language" character(20)
);

ALTER TABLE core."cpc2.1"
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core."cpc2.1_history" (LIKE core."cpc2.1");

CREATE TRIGGER versioning_trigger_cpc2_1
BEFORE INSERT OR UPDATE OR DELETE ON core."cpc2.1"
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core."cpc2.1_history"', true
);

-- Create elements_all table in core schema
CREATE TABLE core."elements_all" (
       "id_key" BIGSERIAL PRIMARY KEY,
       "ElementCode" character(20),
       "Element" character(500),
       "language" character(20)
);

ALTER TABLE core."elements_all"
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core."elements_all_history" (LIKE core."elements_all");

CREATE TRIGGER versioning_trigger_elements_all
BEFORE INSERT OR UPDATE OR DELETE ON core."elements_all"
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core."elements_all_history"', true
);

-- Create country table in core schema
CREATE TABLE core."country" (
       "id_key" BIGSERIAL PRIMARY KEY,
       "CountryM49" character(20),
       "Country" character(500),
       "language" character(20)
);

ALTER TABLE core."country"
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core."country_history" (LIKE core."country");

CREATE TRIGGER versioning_trigger_elements_all
BEFORE INSERT OR UPDATE OR DELETE ON core."country"
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core."country_history"', true
);

-- Create flags table in core schema
CREATE TABLE core.flags (
       "id_key" BIGSERIAL PRIMARY KEY,
       "Flag" character(20),
       "Source" character(500),
       "language" character(20)
);

ALTER TABLE core.flags
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.flags_history (LIKE core.flags);

CREATE TRIGGER versioning_trigger_flags
BEFORE INSERT OR UPDATE OR DELETE ON core.flags
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.flags_history', true
);

-- Create fbs_commodities table in core schema
CREATE TABLE core.fbs_commodities (
       "id_key" BIGSERIAL PRIMARY KEY,
       "FBSCode" character(20),
       "Commodity" character(500),
       "language" character(20)
);

ALTER TABLE core.fbs_commodities
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.fbs_commodities_history (LIKE core.fbs_commodities);

CREATE TRIGGER versioning_trigger_fbs_commodities
BEFORE INSERT OR UPDATE OR DELETE ON core.fbs_commodities
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.fbs_commodities_history', true
);

-- Create nutrient_elements table in core schema
CREATE TABLE core.nutrient_elements (
       "id_key" BIGSERIAL PRIMARY KEY,
       "language" character(20),
       "ElementCode" character(20),
       "Element" character(500),
       "Unit" character(100),
       "measuredElement_code" character(20),
       "measuredElement" character(500)
);

ALTER TABLE core.nutrient_elements
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.nutrient_elements_history (LIKE core.nutrient_elements);

CREATE TRIGGER versioning_trigger_nutrient_elements
BEFORE INSERT OR UPDATE OR DELETE ON core.nutrient_elements
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.nutrient_elements_history', true
);

-- Create trade_commodities table in core schema
CREATE TABLE core.trade_commodities (
       "id_key" BIGSERIAL PRIMARY KEY,
       "HS6" character(500),
       "CPCCode" character(20),
       "Commodity" character(500),
       "language" character(20)
);

ALTER TABLE core.trade_commodities
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.trade_commodities_history (LIKE core.trade_commodities);

CREATE TRIGGER versioning_trigger_trade_commodities
BEFORE INSERT OR UPDATE OR DELETE ON core.trade_commodities
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.trade_commodities_history', true
);

-- Create food_function table in core schema
CREATE TABLE core.food_function (
       "id_key" BIGSERIAL PRIMARY KEY,
       "food_function" character(20),
       "description" character(100),
       "language" character(20)
);

ALTER TABLE core.food_function
  ADD COLUMN "sys_period" tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

CREATE TABLE core.food_function_history (LIKE core.food_function);

CREATE TRIGGER versioning_trigger_food_function
BEFORE INSERT OR UPDATE OR DELETE ON core.food_function
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'core.food_function_history', true
);
