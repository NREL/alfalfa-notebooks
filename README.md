# Setup
1. Download this repository and save it to a folder on your computer.
1. Create `small_office.zip` by zipping the contents of the `twobldgs` folder together. (This is the method of preparing an osw for run with alfalfa and may be extended to any osw)
1. Install [poetry](https://python-poetry.org/docs/).
1. Open your command line interface and navigate to this folder.
1. Run `poetry install` (this project requires python 3.7+ to run, if you don't have that we reccomend using a python virtual environment manager such as [pyenv](https://github.com/pyenv/pyenv#getting-pyenv))
1. Run `poetry run jupyter lab` to launch JupyterLab or interact with notebooks in an editor (ex: VSCode) that supports Jupyter Notebooks natively.
1. In the browser window with jupyter lab in it select the twobldgs.ipnb file.
1. If you are running the alfalfa server locally no changes are required. If not, change the the url in the second cell ('http://localhost' by default) to the url of your alfalfa server. (Trailing slashes in the URL can lead to errors. This will be fixed in the future but as of now it is still a bug)
1. You can now run the contents of the notebook. (Note: this notebook runs two models simulaneously, this means your alfalfa server will need at least two workers)

## Installation Troubleshooting
### Poetry is not using the correct version of Python
1. Run `poetry env list` to list the current environments poetry has created
1. If there is one with the incorrect version of python run `poetry env remove {environment name}`
1. Run `poetry env use 3.8` (replace 3.8 with whatever version of python 3.7 or higher you would like to use)
1. If that fails you may need to make sure that you have that version of python installed and if using pyenv make sure it is configured correctly.
1. Run `poetry install` hopefully with no problems this time