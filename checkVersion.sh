#!/bin/bash

# Check latest Astrolog release version
curl -sSI "https://github.com/CruiserOne/Astrolog/releases/latest" | grep "^location:" | grep -Eo "[0-9]+[.][0-9]+"
