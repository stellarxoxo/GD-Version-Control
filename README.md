# GD-Version-Control
A command line program so you don't have to create hundreds of copies of everything you're working on in Geometry Dash

## Powershell Install Command
1) Open powershell in administrator and run this command. then you are done
```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-Expression "& { $(Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/stellarxoxo/GD-Version-Control/main/install.ps1') }"
```

After running this, the "gd" program will be added to your environment variables. Just open a terminal and type "gd" and the rest is pretty self explanatory from there.
You must be in the GD editor to commit.

## Manual Installation
Download the `GD Version Control` zip file and then just put it somewhere. Then, add the folder to your Environment Variables.
When you type "gd" in a command prompt you might get an error that the python module `rich` is not installed. Type `pip3 install rich` to fix this.
Then it should all work ^_^
