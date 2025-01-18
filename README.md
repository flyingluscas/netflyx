# Netflyx

Netflyx is a self-hosted personal media server designed to simplify the process of managing, downloading, and streaming your favorite movies and TV shows. It integrates various services to provide a seamless and efficient experience. The core components include:

- **Plex**: Serves as the media server to stream content.
- **Radarr**: Manages and monitors movies.
- **Sonarr**: Manages and monitors TV shows.
- **Prowlarr**: Handles torrent indexers.
- **Transmission**: Acts as the download client.
- **Overseerr**: Provides a centralized interface for users to request movies and TV shows.

## Prerequisites

Before setting up Netflyx, ensure you have the following installed:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/flyingluscas/netflyx.git
   cd netflyx
   ```

2. **Configure Environment Variables**:

   - Duplicate the `.env.example` file and rename it to `.env`:

     ```bash
     cp .env.example .env
     ```

   - Open the `.env` file and adjust the variables as needed. This file contains configuration settings for the various services.

3. **Start the Services**:

   Use Docker Compose to build and start the containers:

   ```bash
   docker compose up -d
   ```

   This command will download the necessary Docker images and start the services defined in the `docker-compose.yml` file.

## Accessing the Services

Once the containers are up and running, you can access the services through the following URLs:

- **Plex**: `http://localhost:32400`
- **Radarr**: `http://localhost:7878`
- **Sonarr**: `http://localhost:8989`
- **Prowlarr**: `http://localhost:9696`
- **Transmission TV**: `http://localhost:9091`
- **Transmission Movies**: `http://localhost:9092`
- **Overseerr**: `http://localhost:5055`

Replace `localhost` with your server's IP address if accessing remotely.

## Usage

WIP...

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes.

## License

This project is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

## Disclaimer

This project is provided for personal and educational purposes only. The author(s) are not responsible for any misuse of this software, including illegal activities. Commercial use, including selling or incorporating this project into paid products, is strictly prohibited without explicit permission from the author.
