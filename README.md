# 🏙️ Spatio-Temporal Prosperity Index (STPI)

## 📌 Project Overview

The Spatio-Temporal Prosperity Index is a big-data spatial engineering pipeline designed to measure neighborhood prosperity and physical gentrification in New York City.

Instead of relying solely on traditional economic indicators (like housing prices), this architecture fuses three independent data dimensions into a unified, mathematically rigorous index:

1. **Economic Gravity:** Property valuation via Airbnb listing data.
2. **Social Infrastructure:** Amenity accessibility (gyms, pubs, transit) extracted live via the OpenStreetMap API.
3. **Physical Environment:** High-resolution, 64-dimensional urban land classifications extracted directly from Google Earth Engine's enterprise AlphaEarth (`SATELLITE_EMBEDDING/V1/ANNUAL`) dataset.

---

## 🛠️ Tech Stack & Architecture

* **Containerization:** Docker & Docker Compose
* **Distributed Computing:** Apache Spark / PySpark
* **Spatial Processing:** Apache Sedona (Distributed Spatial SQL)
* **Hexagonal Binning:** Uber H3 (Resolution 9)
* **Cloud Data APIs:** Google Earth Engine API, OSMnx
* **Statistical Modeling:** Geographically Weighted PCA (GWPCA), Cosine Distance
* **Visualization:** Folium (Interactive GeoJSON multi-layer mapping)

---

## 🚀 Key Engineering Highlights

### 1. Enterprise Spatial Embeddings (AlphaEarth)

Instead of relying on public proxy datasets, this pipeline directly interfaces with Google's restricted `SATELLITE_EMBEDDING/V1/ANNUAL` collection. It extracts a highly complex, 64-dimensional vector for every single hexagon, capturing the deep physical reality of the neighborhood layout from space.

### 2. Measuring Gentrification via 64-Dim Temporal Drift

To measure urban transformation, the pipeline extracts these 64-dimensional satellite vectors for both 2017 and 2024. By calculating the **Cosine Distance** across all 64 dimensions for every specific hexagon, the system detects spatial anomalies and generates a `Temporal Drift Score`, mathematically highlighting rapidly gentrifying or redeveloped areas over the 7-year span.

### 3. Geographically Weighted PCA (GWPCA)

Because the definition of "prosperity" shifts geographically (e.g., Midtown concrete vs. Central Park greenery), standard global PCA fails. I implemented a localized k-ring GWPCA that handles a massive 66-feature covariance matrix (64 satellite dims + 2 socio-economic dims). It calculates this matrix uniquely for every micro-neighborhood based *only* on its immediate surroundings, outputting a highly accurate, context-aware `Prosperity Score`.

### 4. Overcoming Containerization & API Bottlenecks

* **Spatial Indexing & Mosaics:** Re-engineered spatial extraction queries to use `.mosaic()` instead of `.first()`, successfully stitching global tiles into a continuous layer to prevent "0 element" indexing misses on localized city bounding boxes.
* **Custom JSON Bypass:** Engineered a native API bypass to overcome a known `geemap` vs. `pandas` version conflict. By extracting the raw `.getInfo()` HTTP payload from Google's servers, I wrote a custom parser to map internal `A00-A63` array keys directly into the PySpark DataFrame, preventing container crashes.
* **Network Loopbacks:** Configured a bypass for Docker's internal bridge network restrictions (`SPARK_LOCAL_IP=127.0.0.1`), allowing PySpark master and worker nodes to communicate without timeouts.

---

## 📊 Pipeline Flow

1. **Ingestion & Spatial Mapping:** Clean Kaggle pricing data and cast raw coordinates to `ST_Point` geometries via Apache Sedona. Map to H3 Resolution 9 honeycomb grid.
2. **Distance Decay Modeling:** Project points to EPSG:3857 (meters) and apply a Gaussian Distance Decay algorithm (`ST_DWithin`) to calculate the weighted social gravity of local amenities.
3. **Cloud Extraction:** Securely interface with Google Earth Engine to sample petabyte-scale 64-dimensional raster data at thousands of individual hex centroids.
4. **Statistical Fusion:** Combine economic, social, and 64-dim physical vectors. Execute GWPCA and Temporal Drift math.
5. **Interactive Rendering:** Output a dual-layer, high-contrast Folium dashboard to visualize localized prosperity and 7-year urban transformation.

### 🗺️ Live Interactive Maps (Web Previews)
Click the links below to interact with the full Folium dashboards directly in your browser:
* **[🌍 View NEW AlphaEarth Prosperity & Drift Map](https://adeshchougale.github.io/Spatio-Temporal-Prosperity-Index/assets/index_sat.htm)**
* **[🎯 View NEW AlphaEarth Top 10 Highlight Map](https://adeshchougale.github.io/Spatio-Temporal-Prosperity-Index/assets/index_sat_top10.htm)**

*(Note: The original 9-dimensional explainable AI maps are still available for comparison [here](https://adeshchougale.github.io/Spatio-Temporal-Prosperity-Index/assets/index.htm) and [here](https://adeshchougale.github.io/Spatio-Temporal-Prosperity-Index/assets/index_top10.htm)).*
---

## 💻 How to Run (Dockerized)

This project is fully containerized for zero-dependency deployment.

### 1. Clone the repository

```bash
git clone https://github.com/AdeshChougale/Spatio-Temporal-Prosperity-Index.git
cd Spatio-Temporal-Prosperity-Index

```

### 2. Build and Spin Up the Container

```bash
docker-compose up --build

```

### 3. Access the Environment

Look at your terminal output for the Jupyter Server URL (it will look like `http://127.0.0.1:8888/lab?token=...`). Click it to open the lab. Open `notebooks/stpi_prototype.ipynb` and run all cells. *(Note: You will be prompted to authenticate with your Google account for Earth Engine access on the first run).*
