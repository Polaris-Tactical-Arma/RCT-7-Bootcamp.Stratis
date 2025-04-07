# Shiny's Automated ArmA 3 Bootcamp

This is a system created using ArmA 3, [Pythia](https://github.com/overfl0/Pythia), Flask & Pocketbase. You can also link it up to a Discord bot to send through results by working with the Pocketbase API.

**The bootcamp will only function with a fully configured dedicated server - running a server in game will not work correctly!**


## Mod Dependencies

The current dependencies for both client and server are:

* RHSAFRF
* CBA_A3
* RHSUSAF
* CUP Weapons
* CUP Units
* CUP Vehicles
* Pythia
* ace
* Zeus Enhanced
* Task Force Arrowhead Radio (BETA!!!)
* CUP Terrains - Core

The server also must run the PythonAPI contained within this repository installed as a locally installed mod.

## Setup
### Clone the repository
On your server, with git installed, open terminal and change directory to a suitable folder. Then run the following command:
> git clone https://github.com/Polaris-Tactical-Arma/RCT-7-Bootcamp.Stratis


### Establish the environment
Within the repository folder create a python virtual environment & activate it.
>virtualenv bootcamp_venv

On Windows, run:
> bootcamp_venv\Scripts\activate

On Unix or MacOS, run:
> source bootcamp_venv/bin/activate

Install the requirements by running
> pip install -r requirements.txt

Copy the RCT-7-Bootcamp.Stratis Folder to your server's MPMissions folder.

### Install & Prepare Pocketbase

Follow [the instructions in the Pocketbase Documentation](https://pocketbase.io/docs/).

With Pocketbase running open http://127.0.0.1:8090/_/ in your browser and create your superuser login.

In the bootcamp repository folder create a .env file, paste the following and fill in your username and password for each variable.
```
PB_USERNAME = "USERNAME GOES HERE"
PB_PASSWORD = "PASSWORD GOES HERE"
```
In the browser window create a new collection called "bootcamp"

Keep pocketbase running.

### Launch Flask & your ArmA 3 Server
In your terminal, at the root folder of the repository, run:
> flask run --port 5001

Launch your ArmA 3 **Dedicated** Server using the mods listed under the dependencies above (Ensure PythiaAPI is installed on the server as a local mod!)

### Play the Mission
With Pocketbase, Flask & the ArmA Server now active, connect to the server and select the available slot. As you complete the bootcamp your data should write to the pocketbase for each task. It will also record when you have completed each section, this means that if you disconnect and reconnect to the server you will not have to start all over again and will only have to play through the sections you have not yet finished.

Data is linked to the database using the player's unique ArmA 3 ID.