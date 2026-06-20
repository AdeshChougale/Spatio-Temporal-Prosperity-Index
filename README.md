# 🏙️ Spatio-Temporal Prosperity Index (STPI)

![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)
![PySpark](https://img.shields.io/badge/PySpark-Distributed_Computing-E25A1C?logo=apachespark)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker)
![Google Earth Engine](https://img.shields.io/badge/Earth_Engine-Petabyte_Scale-4285F4)
![Uber H3](https://img.shields.io/badge/Uber_H3-Spatial_Indexing-black)

## 📌 Project Overview
The Spatio-Temporal Prosperity Index is a big-data spatial engineering pipeline designed to measure neighborhood prosperity and physical gentrification in New York City. 

Instead of relying solely on traditional economic indicators (like housing prices), this architecture fuses three independent data dimensions into a unified, mathematically rigorous index:
1. **Economic Gravity:** Property valuation via Airbnb listing data.
2. **Social Infrastructure:** Amenity accessibility (gyms, pubs, transit) extracted live via the OpenStreetMap API.
3. **Physical Environment:** High-resolution urban land classifications (concrete, trees, water) extracted from petabyte-scale Google Earth Engine (Dynamic World) satellite datasets.

<img width="5176" height="5872" alt="STPI_Flowchart drawio" src="https://github.com/user-attachments/assets/d6d72d45-74cc-421a-93c3-847b463172b6" />


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

### 1. The Explainable AI Pivot (Dynamic World)
Traditional spatial embeddings rely on abstract 64-dimensional vectors, which create a "Black Box" problem for stakeholders. I bypassed this by engineering a connection to Google's public **Dynamic World** dataset, extracting a 9-dimensional vector of exact, explainable physical traits (e.g., % Built Area, % Trees). This allowed the pipeline to mathematically prove *why* a neighborhood changed, not just *that* it changed.

### 2. Measuring Gentrification via Temporal Drift
To measure urban transformation, the pipeline extracts physical satellite vectors for both 2017 and 2024. By calculating the **Cosine Distance** between these vectors for every specific hexagon, the system detects physical anomalies and generates a `Temporal Drift Score`, successfully highlighting rapidly gentrifying or redeveloped areas.

### 3. Geographically Weighted PCA (GWPCA)
Because the definition of "prosperity" shifts geographically (e.g., Midtown concrete vs. Central Park greenery), standard global PCA fails. I implemented a localized k-ring GWPCA that calculates covariance matrices uniquely for every micro-neighborhood based *only* on its immediate surroundings, outputting a highly accurate, context-aware `Prosperity Score`.

### 4. Overcoming Containerization & API Bottlenecks
* **Docker Network Loopback:** Engineered a bypass for Docker's internal bridge network restrictions (`SPARK_LOCAL_IP=127.0.0.1`), allowing PySpark master and worker nodes to communicate without timeouts.
* **Persistent API Authentication:** Configured secure local volume mounts and Python monkey-patching to allow the Google Earth Engine API to persist OAuth credentials across ephemeral container reboots.
* **Library Bug Bypasses:** Bypassed a known `geemap`/`pandas` dimension-dropping bug by directly parsing Earth Engine's raw JSON response payloads into custom DataFrames.

---

## 📊 Pipeline Flow

1. **Ingestion & Spatial Mapping:** Clean Kaggle pricing data and cast raw coordinates to `ST_Point` geometries via Apache Sedona. Map to H3 Resolution 9 honeycomb grid.
2. **Distance Decay Modeling:** Project points to EPSG:3857 (meters) and apply a Gaussian Distance Decay algorithm (`ST_DWithin`) to calculate the weighted social gravity of local amenities.
3. **Cloud Extraction:** Securely interface with Google Earth Engine to sample petabyte-scale raster data at thousands of individual hex centroids.
4. **Statistical Fusion:** Combine economic, social, and physical vectors. Execute GWPCA and Temporal Drift math.
5. **Interactive Rendering:** Output a dual-layer, high-contrast Folium dashboard to visualize localized prosperity and 7-year urban transformation.

### 🗺️ Live Interactive Maps (Web Previews)
Click the links below to interact with the full Folium dashboards directly in your browser:
* **[🌍 View Full NYC Prosperity & Drift Map](https://adeshchougale.github.io/Spatio-Temporal-Prosperity-Index/assets/index.htm)**
* **[🎯 View Top 10 Neighborhoods Highlight Map](https://adeshchougale.github.io/Spatio-Temporal-Prosperity-Index/assets/index_top10.htm)**

---



## 💻 How to Run (Dockerized)

This project is fully containerized for zero-dependency deployment.

### 1. Clone the repository
```bash
git clone [https://github.com/AdeshChougale/Spatio-Temporal-Prosperity-Index.git](https://github.com/AdeshChougale/Spatio-Temporal-Prosperity-Index.git)
cd YOUR_REPO_NAME
```


### 2. Build and Spin Up the Container

docker-compose up --build



### 3. Access the Environment

Look at your terminal output for the Jupyter Server URL (it will look like `http://127.0.0.1:8888/lab?token=...`). Click it to open the lab. Open `notebooks/stpi_prototype.ipynb` and run all cells. *(Note: You will be prompted to authenticate with your Google account for Earth Engine access on the first run).*



