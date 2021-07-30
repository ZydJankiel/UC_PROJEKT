# Verilog project

- [Verilog project](#verilog-project)
  - [Introduction](#introduction)
  - [Usage](#usage)
  - [Game mechanic](#game-mechanic)
    - [Overview](#overview)
    - [Singleplayer](#singleplayer)
    - [Multiplayer](#multiplayer)

## Introduction

This is a game based on [Undertale: Bad Time Simulator](https://gry.jeja.pl/35389,undertale-bad-time-simulator.html) but way easier.

We implemented multiplayer with UART communication. Details are in [multiplayer](#multiplayer) section.

Project is written mostly in Verilog hardware description language. We are using Digilent's BASYS 3 FPGA board and Xilinx Vivado software 2017.3 version.

**Requirements:**

- BASYS 3 FPGA board
- VGA monitor with at least 1024x768 resolution (and VGA cable)
- USB mouse
- Micro USB cable to power on BASYS 3
- PC with Vivado on it

For playing in multiplayer count everything times two.

## Usage

Press and hold the shift key, then press the left mouse button on project folder. Choose "Open PowerShell window here" and type `vivado -mode tcl -source run.tcl -tclargs open` to open Vivado GUI. From there click "Generate Bitstream" in bottom left corner. Open Hardware Manager than Open Target and Auto Connect. When Generate Bitstream is done choose Program Device.

For playing on multiplayer it is necessary to do it on both PC's and BASYS.

## Game mechanic

### Overview

Our goal is to make a game similar to Undertale's fight
mechanic but with mouse instead of keyboard. The sole purpose of the game is surviving as long as possible. In multiplayer mode player can win by surviving more time than opponent.

### Singleplayer

As said before the only objective of this mode is to survive as long as possible. Move mouse to avoid obstacles.

### Multiplayer

In multiplayer your goal is to survive longer than opponent. It is made only for two persons.

In lobby BASYS is sending 'R' letter constantly via UART to other player. The game starts when both UART's receive 'R' letters. When someone loose the game he sends 'L' letter to other player and game over screen is displayed. Receiving 'L' letter is interpreted as winning over enemy so victory screen will show. It is simple but is suits our need for multiplayer purpose.

***Connecting with other player***

UART communication between two BASYS connected to different PC can be done by connecting COM ports over TCP/IP. The easiest way is to be connected to the same network. It can by bypassed by using tools like Hamachi.

For connecting COM ports from two PC we used [Serial to Ethernet connector](https://www.serial-over-ethernet.com). It has 14 days free trial with is enough to test it. Another great software for it is [VSPE](http://www.eterlogic.com/Products.VSPE.html). It has free version for 32-bit systems. Unfortunately 64-bit system application is paid only.

After connecting COM ports, everything should work.

