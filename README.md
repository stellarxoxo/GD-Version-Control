# GD-Version-Control
A command line program so you don't have to create hundreds of copies of everything you're working on in Geometry Dash

## Powershell Install Command
```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-Expression "& { $(Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/stellarxoxo/GD-Version-Control/main/install.ps1') }"
```

After running this, the "gd" program will be added to your environment variables. Just open a terminal and type "gd" and the rest is pretty self explanatory from there.
You must be in the GD editor to commit.
