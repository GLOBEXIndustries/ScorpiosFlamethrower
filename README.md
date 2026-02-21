# ScorpiosFlamethrower
Scorpios Flamethrower iOS Network Stress Test Utility

# `README.md`

<h1 align="center">Scorpio's Flamethrower</h1>

<p align="center">
  <strong>A High-Output, Jetsam-Resistant Network Stress Utility for iOS</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS-lightgrey.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Language-SwiftUI-orange.svg" alt="Language">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License">
  <img src="https://img.shields.io/badge/Status-Redlining-red.svg" alt="Status">
</p>

---

## 🚀 Overview
**Scorpio's Flamethrower** is a precision tool designed for systems administrators, network engineers, nerds, and others to stress test their networks from the comfort of their iPhone. It was built for long runs and to be highly resistant to background termination from iOS. 



## 🔥 Key Features
* **Maximum Resistance:** Designed with a small memory footprint to remain ahead of iOS's notoriously aggressive memory reclamation
* **High-Entropy Streams:** Leverages multiple concurrent `URLSession` tasks to saturate bandwidth. 
* **Real-time Telemetry:** Monitor Mbps throughput and cumulative GB consumption with a responsive refresh rate.

## 🛠 Installation
As this utility bypasses standard App Store background limitations, it is distributed exclusively via **Sideloading**.

1.  **Download:** Grab the latest `.ipa` from the [Releases](https://github.com/GLOBEXIndustries/ScorpiosFlamethrower/releases) section.
2.  **Sideload:** Use AltStore, SideStore, or an MDM Provider if you have one. 
3.  **Trust:** Navigate to `Settings > General > VPN & Device Management` to trust the developer profile.

## 📡 Usage Configuration

To use, set the URL to a server hosting a large, multigigabyte file that is geographically close to you, then select the runtime from the dropdown

<p align="center">
  <img src="https://github.com/GLOBEXIndustries/ScorpiosFlamethrower/blob/main/screenshot1.png">
  <img src="https://github.com/GLOBEXIndustries/ScorpiosFlamethrower/blob/main/screenshot2.png">
</p>
