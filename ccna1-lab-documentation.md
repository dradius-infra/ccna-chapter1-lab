# CCNA 200-301 Domain 1: Network Fundamentals

A terminal-based interactive evaluation platform designed for the CCNA (200-301) certification, focused entirely on Domain 1 (Network Fundamentals). The script stress-tests both theoretical core concepts and practical proficiency in Cisco IOS CLI diagnostics and baseline configuration syntax.

---

## Exam Syllabus Coverage (Domain 1 Breakdown)

The runtime evaluates 100% of the Cisco CCNA Domain 1 blueprint requirements:

* **Architecture & Topologies:**
* Three-Tier Campus Model (Core, Distribution, Access layer duties).
* Data Center Spine-Leaf fabric architecture, East-West vs. North-South packet routing.
* WAN topologies (Full Mesh link math $N \times (N-1) / 2$, Hub-and-Spoke latency factors).


* **Layer 1 Physical Layer & Media:**
* Single-Mode Fiber (SMF) vs. Multi-Mode Fiber (MMF) mechanics and modal dispersion.
* Twisted-pair copper classes (Cat5e, Cat6, Cat6a) operational limits and channel rates.
* T568A vs. T568B pinning order, Straight-Through, Crossover, and Rollover RJ-45 console cables.
* Power over Ethernet (PoE) IEEE standards (802.3af, 802.3at PoE+, 802.3bt Type 3/4).
* Hot-swappable transceivers (SFP, SFP+, QSFP28).


* **Layer 2 Data Link & Ethernet Switching:**
* CSMA/CD operational boundaries and Full/Half Duplex link states.
* 48-bit MAC address architecture (EUI-48), Organizationally Unique Identifier (OUI), Unicast/Multicast/Broadcast frames.
* CAM/MAC table decision engine (ingress source learning, egress destination lookup, unknown unicast flooding).
* Collision domain and broadcast domain delineation.


* **Layer 3 Forwarding & Addressing (IPv4 & IPv6):**
* IPv4 header mechanics, TTL decrement behavior, and ICMP Type 11 generation.
* Dedicated spaces (RFC 1918 Private, RFC 6598 CGNAT, APIPA 169.254.0.0/16, loopback testing).
* VLSM subnetting calculations (/26 through /31 Point-to-Point under RFC 3021).
* RFC 5952 IPv6 compression rules.
* IPv6 scope classes (GUA, LLA, ULA, Multicast) and SLAAC EUI-64 identifier construction.
* Neighbor Discovery Protocol (NDP: RS/RA, NS/NA, Duplicate Address Detection).


* **Layer 4 Transport Layer Protocols:**
* TCP vs. UDP structural trade-offs, TCP control flags (SYN, ACK, FIN, RST), and dynamic buffer windowing.
* Well-known Layer 4 service ports (DNS 53, DHCP 67/68, TFTP 69, NTP 123, SNMP 161/162, SSH 22, Telnet 23).


* **Virtualization, Cloud & Modern Security:**
* Bare-metal Hypervisors (Type 1) vs. Hosted (Type 2) vs. Container kernel namespaces.
* Cloud service tiers (IaaS, PaaS, SaaS demarcation boundaries).
* WLAN architecture (2.4 GHz non-overlapping channels 1/6/11, 5 GHz, Split-MAC functions, CAPWAP tunnels).
* Wireless security standards (WPA2 AES/CCMP vs. WPA3 SAE dictionary defense).
* Next-Gen Firewalls (NGFW Layer 7 inspection), VRF routing table segmentation, and SDN Southbound controllers.



---

## Mechanics & Rules

### 1. System Integrity (Lives)

* You begin the session with **3 Integrity Blocks** `[ █ █ █ ]`.
* Every incorrect selection strips 1 block.
* Reaching 0 Integrity triggers an immediate **Integrity Collapse**, rolling your progress back to the latest unlocked Checkpoint.

### 2. Checkpoints & State Persistence

* **Checkpoint 1:** Unlocks after completing **Apex Escalation #2** (Stage 21).
* **Checkpoint 2:** Unlocks after completing **Apex Escalation #4** (Stage 41).
* Upon collapse, System Integrity resets to full capacity (3/3), run statistics revert to the saved checkpoint metrics, and all remaining pending modules are reshuffled via Fisher-Yates randomization.

### 3. Tactical Intel Dossier (`[H]`)

* Pressing `H` during any question brings up targeted technical reference data.
* Accessing the dossier initiates a **strict 10-second countdown timer**.
* If the countdown runs out before an option is selected:
* 1 Integrity point is forfeited.
* The screen clears the intel block entirely to prevent reference carry-over.
* The active module returns to manual prompt mode for a retry.



### 4. Apex Escalations (Milestone Scenarios)

Five multi-step escalation audits occur at fixed intervals:

* **Apex #1 (Stage 10):** Spine-Leaf data center remediation, duplex matching, and medium selection.
* **Apex #2 (Stage 20 — Checkpoint 1 Lock):** EUI-64 interface math, DAD protocol verification, and IPv6 formatting.
* **Apex #3 (Stage 35):** VLSM emergency allocation and point-to-point interface sizing.
* **Apex #4 (Stage 40 — Checkpoint 2 Lock):** Data plane attack triage, bitwise AND routing logic, and runt frame identification.
* **Apex #5 (Stage 58 — Final Run):** Enterprise WLAN management, WPA3 authentication mechanisms, and CAPWAP firewall traversal.

Clearing an Apex scenario restores 1 lost Integrity point (capped at 3/3).

---

## Evaluation & Scoring Algorithm

The final performance index is derived from the following calculation:

$$\text{Final Grade} = 100 - \text{Penalties} + \text{Bonus}$$

* **Baseline Score:** 100 PTS.
* **Incorrect Choices:** $-2.5\text{ PTS}$ per failure.
* **Timer Expirations:** $-4.0\text{ PTS}$ per timeout.
* **Streak Bonus:** $+1\text{ PT}$ awarded per 5 consecutive correct answers (capped at $+6\text{ PTS}$).
* **Score Bounds:** Automatically clamped between $0\text{ PTS}$ and $100\text{ PTS}$.