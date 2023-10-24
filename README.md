<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  

  <h1 align="center">World Link</h1>
  <p align="center">
    Character creation and documentation platform
    <br />
    <a href="https://github.com/phamdangtrung/world_link">View Demo</a>
    ·
    <a href="https://github.com/phamdangtrung/world_link/issues">Feature Request - Bug Report</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

WorldLink is a working-in-progress side project for me to satisfy my artistic needs and also a playground for me to work with Elixir and Phoenix.
This project consists of mostly backend stuff and some of the frontend for administration and statistics.
Client's frontend is in another repo.


Features (these features are still being developed and subjected to change):
* Character creation and organization:
  * Creating a character with description and additional info.
  * Creating additional timelines or alternate universes for characters with independent description and info.
  * Assigning or organizing characters based on world, alternate universe (AU), folder.
  * Linking worlds, events relationships and characters.
* Image upload:
  * Uploading image to an album, a character's profile page or an article.
  * Using image as album's, character's profile's or article's header.
  * Uploading image as avatar
* Album creation:
  * An image can be assigned to multiple albums or none.
  * Albums are strictly for character (tbd).
* Article:
  * Timeline-based articles
  * Wiki-like article for character's and user's profile, also world and timeline.
  * Personal profile's article.
* More


<!-- GETTING STARTED -->
## Getting Started
### Prerequisites
* asdf-vm for managing environment
* Elixir: 1.14.4
* Erlang-OTP: 25.2.2
* Phoenix: 1.7.2
* Postgres: 15.2

### Installation
1. Clone the repo
   ```sh
   git clone https://github.com/phamdangtrung/world_link.git
   ```
2. CD
   ```sh
   cd world_link
   ```
3. Get all the dependencies
   ```sh
   mix deps.get && mix deps.compile
   mix compile
   ```
3. Change the database credentials in lib/world_link/repo.ex
   ```elixir
   def init(_, config) do
    config =
      config
      |> Keyword.put(:username, System.get_env("PGUSER"))
      |> Keyword.put(:password, System.get_env("PGPASSWORD"))
      |> Keyword.put(:database, System.get_env("PGDATABASE"))
      |> Keyword.put(:hostname, System.get_env("PGHOST"))
      |> Keyword.put(:port, System.get_env("PGPORT"))

    {:ok, config}
   end
   ```
4. Deploy database
   ```sh
   mix ecto.setup
   ```
5. Setup, build and deploy assets
   ```sh
   mix assets.setup
   mix assets.build
   mix assets.deploy
   ```
6. Run the server

   with iex shell
   ```sh
   iex -S mix phx.server
   ```
   without iex shell
   ```sh
   mix phx.server
   ```
<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

TBD

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [x] Add README and LICENSE
- [ ] tbd
  - tbd

See the [open issues](https://github.com/phamdangtrung/world_link/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

<p>Contributions are *greatly appreciated*. Though I have the *RIGHTS* to reject any contribution I deem unsuitable!!</p>
<p>If you have any suggestion that would make this better and want to contribute, please fork the repo and create a pull request.</p>
<p>If you have no knowledge about coding, you can also simply open an issue with the tag "enhancement" or "feature-request".</p>

### How to open a pull request:
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Available branches:
1. feature
2. bug
3. hotfix
4. enhancement
<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

You can contact me directly via any platform in this link:

Trung Pham - trung@phamdangtrung.com

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
<!-- ## Acknowledgments

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!

* [Choose an Open Source License](https://choosealicense.com)
* [GitHub Emoji Cheat Sheet](https://www.webpagefx.com/tools/emoji-cheat-sheet)
* [Malven's Flexbox Cheatsheet](https://flexbox.malven.co/)
* [Malven's Grid Cheatsheet](https://grid.malven.co/)
* [Img Shields](https://shields.io)
* [GitHub Pages](https://pages.github.com)
* [Font Awesome](https://fontawesome.com)
* [React Icons](https://react-icons.github.io/react-icons/search)

<p align="right">(<a href="#readme-top">back to top</a>)</p> -->