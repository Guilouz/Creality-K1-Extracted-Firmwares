#!/bin/sh

PWR_PIN=PB28
RESET_PIN=PA07

cmd_gpio set_func ${PWR_PIN} output0
cmd_gpio set_func ${RESET_PIN} output0
sleep 1
cmd_gpio set_func ${PWR_PIN} output1
cmd_gpio set_func ${RESET_PIN} output1

