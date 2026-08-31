#!/bin/bash
bright=$(brightnessctl get)
max=$(brightnessctl max)
echo $(( bright * 100 / max ))