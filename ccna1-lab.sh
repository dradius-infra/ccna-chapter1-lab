#!/usr/bin/env bash

BOLD=$(printf '\033[1m')
DIM=$(printf '\033[2m')
NC=$(printf '\033[0m')

C_BLUE=$(printf '\033[38;5;39m')
C_CYAN=$(printf '\033[38;5;51m')
C_GREEN=$(printf '\033[38;5;48m')
C_RED=$(printf '\033[38;5;196m')
C_YELLOW=$(printf '\033[38;5;220m')
C_ORANGE=$(printf '\033[38;5;208m')
C_PURPLE=$(printf '\033[38;5;141m')
C_WHITE=$(printf '\033[38;5;255m')

BG_ACCEPT=$(printf '\033[48;5;22m\033[38;5;15m')
BG_DROP=$(printf '\033[48;5;52m\033[38;5;15m')
BG_WARN=$(printf '\033[48;5;130m\033[38;5;15m')
BG_ESCALATION=$(printf '\033[48;5;53m\033[38;5;15m')
BG_META=$(printf '\033[48;5;236m\033[38;5;255m')

INTEGRITY=3
MAX_INTEGRITY=3
USER_INPUT=""
STREAK=0
MAX_STREAK=0
MISTAKES_COUNT=0
TIMEOUTS_COUNT=0
CURRENT_CHECKPOINT=1
SESSION_START_TIME=$(date +%s)

CKPT_MISTAKES=0
CKPT_TIMEOUTS=0
CKPT_MAX_STREAK=0
CKPT_START_TIME=$SESSION_START_TIME

render_header() {
    local lvl_num="$1"
    local lvl_title="$2"
    local mode="${3:-CCNA FUNDAMENTALS}"
    clear
    printf "%b\n" "${C_PURPLE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    printf "%b\n" "${C_PURPLE}║${NC}    ${BOLD}${C_CYAN}CCNA 200-301 MASTER DRILL${NC} ── ${C_YELLOW}MODULE $lvl_num/60${NC}"
    
    local ib1="${DIM}░${NC}" local ib2="${DIM}░${NC}" local ib3="${DIM}░${NC}"
    [ "$INTEGRITY" -ge 1 ] && ib1="${C_GREEN}█${NC}"
    [ "$INTEGRITY" -ge 2 ] && ib2="${C_GREEN}█${NC}"
    [ "$INTEGRITY" -ge 3 ] && ib3="${C_GREEN}█${NC}"

    printf "%b\n" "${C_PURPLE}║${NC}    INTEGRITY: [ $ib1 $ib2 $ib3 ] ($INTEGRITY/3)  MODE: ${BOLD}${C_GREEN}$mode${NC}  STREAK: ${C_YELLOW}$STREAK (MAX: $MAX_STREAK)${NC}"
    printf "%b\n" "${C_PURPLE}╠════════════════════════════════════════════════════════════════════════════╣${NC}"
    printf "%b\n" "${C_PURPLE}║${NC}    TOPIC: ${BOLD}${C_WHITE}$lvl_title${NC}"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
}

render_tracer() {
    local src="$1"
    local node="$2"
    local dst="$3"
    local status="$4"

    printf "%b\n" "${BOLD}${C_BLUE}─── [FRAME/PACKET PIPELINE SIMULATION] ──────────────────────────────────────${NC}"
    sleep 0.08
    printf "%b\n" "  [INGRESS/SRC] : ${BOLD}${C_CYAN}$src${NC}"
    printf "%s\n" "                    │"
    printf "%s\n" "                    ▼"
    printf "%b\n" "  [PROCESSING]  : ${BOLD}${C_PURPLE}►► $node ◄◄${NC}"
    
    if [ "$status" == "FORWARD" ]; then
        printf "%b\n" "                    │ ${C_GREEN}✔ L2/L3 DETERMINATION OK (FORWARDED)${NC}"
        printf "%s\n" "                    ▼"
        printf "%b\n" "  [EGRESS/DST]  : ${BOLD}${C_GREEN}$dst${NC}"
    else
        printf "%b\n" "                    ${C_RED}✖ FRAME DROPPED / FLUSHED${NC}"
        printf "%s\n" "                    ▼"
        printf "%b\n" "                  ${DIM}[DISCARDED: NO ROUTE / CORRUPT CHECKSUM / UNKNOWN]${NC}"
    fi
    printf "%b\n\n" "${BOLD}${C_BLUE}─────────────────────────────────────────────────────────────────────────────${NC}"
}

show_contextual_dossier() {
    local mod_id="$1"
    printf "\n%b\n" "${C_PURPLE}╔════ TARGETED INTEL DOSSIER (CCNA EXAM RADAR) ══════════════════════════════╗${NC}"
    case "$mod_id" in
        1)  printf "%b\n" "║ • Core Layer: High-speed forwarding backbone; strictly NO ACL or QoS overhead.║\n║ • Distribution Layer: Routing, policy boundaries, security ACLs, VLAN SVIs. ║\n║ • Access Layer: Direct endpoint connection, PoE, Port Security, STP edges.  ║" ;;
        2)  printf "%b\n" "║ • Spine-Leaf: Every leaf connects to every spine. Zero spine-to-spine links.║\n║ • Traffic flow: Designed for East-West server-to-server traffic. Deterministic║\n║   2-hop latency across entire fabric (Leaf -> Spine -> Leaf).                ║" ;;
        3)  printf "%b\n" "║ • CSMA/CD: Carrier Sense Multiple Access with Collision Detection.          ║\n║ • Full-Duplex: Separate Tx/Rx pairs; collisions physically impossible;     ║\n║   CSMA/CD is completely disabled on full-duplex Ethernet switch interfaces.║" ;;
        4)  printf "%b\n" "║ • Single-Mode Fiber (SMF): 9µm core, laser diode, long-haul (kilometers).    ║\n║ • Multi-Mode Fiber (MMF): 50-62.5µm core, LED/VCSEL light, modal dispersion. ║\n║   Restricted to short campus/DC runs (up to 300-500 meters).                 ║" ;;
        5)  printf "%b\n" "║ • 802.3af (PoE Type 1): 15.4W at PSE, 12.95W delivered at PD.               ║\n║ • 802.3at (PoE+ Type 2): 30W at PSE, 25.5W delivered at PD (powers dual APs).║\n║ • 802.3bt (PoE++ Type 3/4): Delivers 60W to 90W+ using all four copper pairs. ║" ;;
        6)  printf "%b\n" "║ • Straight-Through: Heterogeneous nodes (PC to Switch, Switch to Router).   ║\n║ • Crossover: Like devices (Switch to Switch, Router to PC, Router to Router)║\n║ • Auto-MDIX: Dynamically detects and swaps Tx/Rx pairs on modern NICs.      ║" ;;
        7)  printf "%b\n" "║ • MAC Address: 48 bits (EUI-48). First 24 bits = OUI (vendor identifier).   ║\n║ • Final 24 bits = Vendor-assigned NIC serial number.                        ║\n║ • Broadcast MAC: FF:FF:FF:FF:FF:FF. Multicast: Starts with 01:00:5E (IPv4). ║" ;;
        8)  printf "%b\n" "║ • CAM Table (MAC Table): Learns by inspecting Ingress SOURCE MAC.            ║\n║ • Forwards based on DESTINATION MAC: Known Unicast -> out specific port;     ║\n║   Unknown Unicast / Broadcast / Multicast -> Floods out all ports in VLAN.  ║" ;;
        9)  printf "%b\n" "║ • Collision Domain: Delimited by every single full-duplex switch port.        ║\n║ • Broadcast Domain: Delimited strictly by Layer 3 boundaries (Routers/VLANs).║\n║ • Hub: A 16-port hub is a single collision domain and single broadcast domain.║" ;;
        10) printf "%b\n" "║ • TCP: 20-byte base header, reliable, windowing, ordered sequence, ACKs.   ║\n║ • UDP: 8-byte fixed header, connectionless, unreliable, low-overhead voice. ║\n║ • Flags: SYN, ACK, FIN (graceful teardown), RST (instant socket abort).     ║" ;;
        11) printf "%b\n" "║ • DNS: UDP 53 (queries), TCP 53 (zone transfers > 512 bytes).                ║\n║ • DHCP: UDP 67 (Server), UDP 68 (Client). TFTP: UDP 69. NTP: UDP 123.       ║\n║ • SNMP: UDP 161 (polling), UDP 162 (traps). SSH: TCP 22. Telnet: TCP 23.     ║" ;;
        12) printf "%b\n" "║ • IPv4 Header: 20 bytes min. TTL decremented by 1 at every L3 hop.          ║\n║ • At TTL=0: Router drops packet and returns ICMP Type 11 (Time Exceeded).   ║\n║ • Protocol field: 1 = ICMP, 6 = TCP, 17 = UDP, 89 = OSPF.                  ║" ;;
        13) printf "%b\n" "║ • RFC 1918 Private: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16.              ║\n║ • RFC 6598 (CGNAT): 100.64.0.0/10. APIPA (Link-Local): 169.254.0.0/16.      ║\n║ • Loopback: 127.0.0.0/8 (127.0.0.1 for local TCP/IP stack verification).     ║" ;;
        14) printf "%b\n" "║ • Magic Number = 256 - [interesting octet mask]. Subnet sizes:              ║\n║ • /26 = .192 (block 64), /27 = .224 (block 32), /28 = .240 (block 16).      ║\n║ • /29 = .248 (block 8), /30 = .252 (block 4, 2 hosts), /31 = RFC 3021 (P2P).║" ;;
        15) printf "%b\n" "║ • Host Gateway Logic: Bitwise AND of Destination IP with local subnet mask.║\n║ • Match = Local subnet -> ARP directly for host MAC.                        ║\n║ • Mismatch = Remote subnet -> Forward frame to Default Gateway MAC address. ║" ;;
        16) printf "%b\n" "║ • IPv6 Compression: 1) Omit leading zeros inside any 16-bit hex group.      ║\n║ • 2) Replace single contiguous sequence of all-zero groups with '::' (once).║\n║ • 2001:0db8:0000:0000:00A8:0000:0000:0001 -> 2001:db8::a8:0:0:1.            ║" ;;
        17) printf "%b\n" "║ • GUA (Global Unicast): 2000::/3. ULA (Unique Local): fc00::/7 (fd00::/8).   ║\n║ • LLA (Link-Local): fe80::/10. Multicast: ff00::/8 (ff02::1 all, ff02::2 rtr)║\n║ • Loopback: ::1/128. Unspecified (used during DAD): ::/128.                 ║" ;;
        18) printf "%b\n" "║ • EUI-64: Split 48-bit MAC in half -> insert FFFE in middle -> invert 7th   ║\n║   bit (universal/local). MAC 0011:2233:4455 -> 0211:22FF:FE33:4455.          ║" ;;
        19) printf "%b\n" "║ • NDP (RFC 4861): Replaces ARP and ICMP router discovery.                    ║\n║ • RS (Router Solicitation, ff02::2) / RA (Router Advertisement, ff02::1).   ║\n║ • NS (Neighbor Solicitation, ARP request / DAD) / NA (Neighbor Advertisement)║" ;;
        20) printf "%b\n" "║ • Type 1 Hypervisor: Bare-metal OS (ESXi, Hyper-V). High performance.        ║\n║ • Type 2 Hypervisor: Hosted on OS (Workstation, VirtualBox). High overhead.  ║\n║ • Containers: Share host OS kernel, isolated user-space processes (Docker). ║" ;;
        21) printf "%b\n" "║ • IaaS: Vendor hosts compute/storage; user manages OS & apps (AWS EC2).     ║\n║ • PaaS: Vendor manages OS & platform; user pushes code (Beanstalk).          ║\n║ • SaaS: Fully turnkey software application (Office 365, Salesforce).         ║" ;;
        22) printf "%b\n" "║ • 2.4 GHz: Channels 1, 6, 11 are non-overlapping (20 MHz). High interference║\n║ • 5 GHz: 24+ non-overlapping 20 MHz channels. Wi-Fi 6E/7: 6 GHz spectrum.    ║\n║ • BSSID: Layer 2 MAC address of the AP radio. SSID: Human network name.      ║" ;;
        23) printf "%b\n" "║ • WEP: RC4 (broken). WPA2: AES/CCMP enterprise standard.                      ║\n║ • WPA3: SAE (Simultaneous Authentication of Equals) prevents dictionary attacks║" ;;
        24) printf "%b\n" "║ • Split-MAC: LAP handles real-time MAC (beacons, ACKs, frame exchanges).     ║\n║ • WLC handles management (802.11 auth, association, roaming, QoS, RRM).      ║\n║ • CAPWAP: Control plane UDP 5246 (DTLS encrypted), Data plane UDP 5247.      ║" ;;
        25) printf "%b\n" "║ • VRF: Virtual Routing & Forwarding. Isolates multiple routing tables on   ║\n║   the same router, enabling overlapping IP subnets without route leakage.   ║" ;;
        26) printf "%b\n" "║ • Giants: Frames exceeding interface MTU (>1518 bytes untagged).             ║\n║ • Runts: Frames smaller than 64-byte minimum (caused by collisions/noise).  ║\n║ • CRC/FCS Errors: Corrupted frames due to bad copper crimping or EMI noise. ║" ;;
        27) printf "%b\n" "║ • Speed/Duplex Mismatch: One side Full, other side Half Duplex.              ║\n║ • Symptom: Link is UP, but duplex mismatch produces late collisions & errors.║" ;;
        28) printf "%b\n" "║ • Full Mesh Links Formula: N*(N-1)/2. For 6 nodes = 6*5/2 = 15 links.        ║\n║ • Hub-and-Spoke: Dual-hop latency between spokes through hub (hairpinning).  ║" ;;
        29) printf "%b\n" "║ • SFP: 1 Gbps. SFP+: 10 Gbps (same form factor). QSFP28: 100 Gbps channel.  ║\n║ • Cat5e: 1 Gbps up to 100m. Cat6: 10 Gbps up to 55m. Cat6a: 10 Gbps to 100m. ║" ;;
        30) printf "%b\n" "║ • Rollover Console Cable: Reverses pin sequence (1 to 8, 2 to 7). Connects  ║\n║   RJ45 console port to DB9/USB terminal serial port for OOB management.    ║" ;;
        31) printf "%b\n" "║ • T568A: W/Green, Green, W/Orange, Blue, W/Blue, Orange, W/Brown, Brown.     ║\n║ • T568B: W/Orange, Orange, W/Green, Blue, W/Blue, Green, W/Brown, Brown.     ║" ;;
        32) printf "%b\n" "║ • DAD (Duplicate Address Detection): NS sent to own solicited-node address.  ║\n║ • SLAAC: Client learns prefix from RA, auto-generates 64-bit host identifier.║" ;;
        33) printf "%b\n" "║ • TCP Windowing: Flow control buffer mechanism adjusting data volume sent   ║\n║   before requiring an ACK reply.                                            ║" ;;
        34) printf "%b\n" "║ • Next-Gen Firewall (NGFW): L7 Deep Packet Inspection, AVC, threat telemetry.║\n║ • Multilayer Switch: Integrates ASIC-accelerated L3 CEF routing with L2 ports║" ;;
        35) printf "%b\n" "║ • Cisco DNA / Catalyst Center: Centralized SDN controller managing fabrics. ║" ;;
        *)  printf "%b\n" "║ • Review CCNA Domain 1: L1 physical, L2 switching, L3 routing & IPv6 basics.║" ;;
    esac
    printf "%b\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n\n" "${BG_WARN} ⚠ INTEL ACCESSED: 10 SECONDS TIMEOUT RUNNING! ⚠ ${NC}"
}

ask_with_timer_or_manual() {
    local prompt_text="$1"
    local valid_regex="$2"
    local mod_id="$3"
    USER_INPUT=""

    while true; do
        printf "\0337"
        read -rp "$prompt_text" USER_INPUT
        if [[ "$USER_INPUT" =~ ^[hH]$ ]]; then
            show_contextual_dossier "$mod_id"
            local input_received=false
            local timeout_val=10
            
            for ((sec=timeout_val; sec>0; sec--)); do
                local bar=""
                for ((b=1; b<=timeout_val; b++)); do
                    [ "$b" -le "$sec" ] && bar+="${C_GREEN}█${NC}" || bar+="${DIM}░${NC}"
                done
                printf "\r\033[K[ %b ] %ds remaining | Selection: " "$bar" "$sec"
                read -t 1 timer_ans
                if [ -n "$timer_ans" ]; then
                    input_received=true
                    USER_INPUT="$timer_ans"
                    printf "\n"
                    break
                fi
            done

            printf "\0338\033[J"

            if [ "$input_received" = false ]; then
                printf "%s" "$prompt_text"
                printf "\n\n%b\n\n" "${BG_DROP} ⏰ TIMEOUT REACHED! PACKET FLUSHED! (-1 INTEGRITY) ${NC}"
                INTEGRITY=$((INTEGRITY - 1))
                TIMEOUTS_COUNT=$((TIMEOUTS_COUNT + 1))
                STREAK=0
                return 99
            else
                [[ "$USER_INPUT" =~ $valid_regex ]] && return 0
            fi
        elif [[ "$USER_INPUT" =~ $valid_regex ]]; then
            return 0
        else
            printf "%b\n" "${C_RED}Invalid choice. Select from available options or press [H] for Intel.${NC}"
        fi
    done
}

update_streak_success() {
    STREAK=$((STREAK + 1))
    [ "$STREAK" -gt "$MAX_STREAK" ] && MAX_STREAK="$STREAK"
}

update_streak_failure() {
    STREAK=0
    MISTAKES_COUNT=$((MISTAKES_COUNT + 1))
}

shuffle_remaining_modules() {
    local start_i="$1"
    local n="${#modules[@]}"
    local len=$((n - start_i))
    if [ "$len" -gt 1 ]; then
        for ((idx_k = n - 1; idx_k > start_i; idx_k--)); do
            local range=$((idx_k - start_i + 1))
            local rand_pick=$((start_i + (RANDOM % range)))
            local swp=${modules[idx_k]}
            modules[idx_k]=${modules[rand_pick]}
            modules[rand_pick]=$swp
        done
    fi
}

module_1() {
    local lvl="$1"; while true; do render_header "$lvl" "Three-Tier Campus Architecture Hierarchy"
    printf "%b\n" "${BG_META} [NETWORK TOPOLOGY AUDIT] ${NC}"
    printf "%s\n" "  A network engineer configures CPU-intensive security ACLs, complex QoS policies,"
    printf "%s\n\n" "  and terminates VLAN SVIs directly on the backbone Core switches."
    printf "%b\n" "${BOLD}QUESTION: Why violates this Cisco 3-Tier Campus Design principles?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} The Core Layer must focus solely on high-speed uninhibited packet switching."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} ACLs and SVIs can only be placed on Access switches."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} The Core Layer cannot perform Layer 3 routing."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "1"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! CORE LAYER OPTIMIZATION VERIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} The Core Layer is optimized for high throughput. Policy boundaries, ACLs, and VLAN termination belong in the ${BOLD}Distribution Layer${NC}."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_2() {
    local lvl="$1"; while true; do render_header "$lvl" "Data Center Spine-Leaf Fabric Dynamics"
    printf "%b\n" "${BG_META} [DATA CENTER FABRIC AUDIT] ${NC}"
    printf "%s\n" "  A modern cloud data center hosts microservices with heavy East-West traffic flows."
    printf "%s\n\n" "  Server A on Leaf-1 sends packets to Server B on Leaf-4 across the spine switches."
    printf "%b\n" "${BOLD}QUESTION: What is the deterministic traversal path and hop-count?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Variable latency depending on STP blocking port states."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Exactly two hops with zero spine-to-spine links."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Three hops minimum traversing multiple inter-connected spine nodes."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "2"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "2" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! DETERMINISTIC 2-HOP FABRIC VALIDATED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} In a Spine-Leaf topology, spines never connect to spines, and leaves connect to every spine, ensuring consistent 2-hop East-West latency."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_3() {
    local lvl="$1"; while true; do render_header "$lvl" "Full-Duplex Media Access & CSMA/CD"
    printf "%b\n" "${BG_META} [PHYSICAL / MAC LAYER AUDIT] ${NC}"
    printf "%s\n" "  A workstation connects to a Cisco Catalyst 2960 port operating at 1 Gbps Full-Duplex."
    printf "%s\n\n" "  Traffic bursts are observed simultaneously in both transmitting and receiving directions."
    printf "%b\n" "${BOLD}QUESTION: How does CSMA/CD operate on this active link?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} It sets backoff timers whenever collisions occur."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} It is completely disabled because collisions are physically impossible."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} It monitors carrier sense but ignores jam signals."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "3"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "2" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! CSMA/CD BYPASS CONFIRMED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Full-Duplex uses dedicated transmit and receive wire pairs. Collisions cannot happen, so CSMA/CD is completely disabled."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_4() {
    local lvl="$1"; while true; do render_header "$lvl" "Fiber Optic Dispersion & Core Geometry"
    printf "%b\n" "${BG_META} [MEDIA TRANSMISSION AUDIT] ${NC}"
    printf "%s\n" "  You are linking two buildings separated by 2,500 meters across a campus."
    printf "%s\n\n" "  The budget contains 50-micron Multi-Mode Fiber (MMF) reels and patch cables."
    printf "%b\n" "${BOLD}QUESTION: Why will this MMF cabling fail at this distance?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Modal dispersion causes light rays to arrive out of phase over long runs."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} MMF requires single-laser diodes which overheat past 100 meters."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Fiber optic standards cap all optical fiber runs at 100 meters."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "4"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! MODAL DISPERSION IDENTIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} MMF has a wide core (50-62.5µm) leading to modal dispersion. Spans over 500m require Single-Mode Fiber (SMF) with a 9µm core."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_5() {
    local lvl="$1"; while true; do render_header "$lvl" "Power over Ethernet (PoE) IEEE Standards"
    printf "%b\n" "${BG_META} [INFRASTRUCTURE POWER AUDIT] ${NC}"
    printf "%s\n" "  A new Cisco Wi-Fi 6 Access Point requires 22.5W of continuous delivered power."
    printf "%s\n\n" "  The legacy switch supports only baseline IEEE 802.3af (Type 1 PoE)."
    printf "%b\n" "${BOLD}QUESTION: What is the limitation of 802.3af vs the AP requirement?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} 802.3af delivers max 12.95W at the Powered Device."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} 802.3af delivers 30W but only over Cat6a cabling."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} 802.3af only supports IP Phones and disables wireless APs."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "5"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! POE POWER CAPACITY BUDGETED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} 802.3af provides 15.4W at PSE (12.95W at PD). Devices drawing 22.5W require 802.3at PoE+ (30W PSE / 25.5W PD)."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_6() {
    local lvl="$1"; while true; do render_header "$lvl" "Ethernet Twisted-Pair Pinout Matching"
    printf "%b\n" "${BG_META} [LAYER 1 CABLING AUDIT] ${NC}"
    printf "%s\n" "  You are connecting a Cisco Router GigabitEthernet 0/0 interface directly to a PC NIC"
    printf "%s\n\n" "  in a lab environment where Auto-MDIX has been administratively disabled."
    printf "%b\n" "${BOLD}QUESTION: What cable pinout termination is mandatory to achieve link UP?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Straight-Through Cable"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Crossover Cable"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Rollover Cable"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "6"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "2" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! PIN CROSSOVER MAPPED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Routers and PCs transmit on the exact same pin pairs (1 & 2). Without Auto-MDIX, connecting them directly requires a Crossover cable."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_7() {
    local lvl="$1"; while true; do render_header "$lvl" "Layer 2 MAC Addressing & OUI Anatomy"
    printf "%b\n" "${BG_META} [DATA LINK ADDRESSING AUDIT] ${NC}"
    printf "%b\n" "  An ingress Ethernet frame reveals source MAC address ${C_CYAN}00:1A:2B:3C:4D:5E${NC}."
    printf "%s\n\n" "  The engineer needs to identify the IEEE-assigned hardware manufacturer."
    printf "%b\n" "${BOLD}QUESTION: Which portion of the address represents the OUI?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} The first 24 bits"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} The final 24 bits"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} The entire 48 bits"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "7"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! OUI SPECIFICATION CONFIRMED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} An EUI-48 MAC address dedicates the first 24 bits to the Organizationally Unique Identifier (OUI) and the last 24 bits to the device serial."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_8() {
    local lvl="$1"; while true; do render_header "$lvl" "CAM Table Unknown Unicast Flooding Logic"
    printf "%b\n" "${BG_META} [SWITCH DATA PLANE AUDIT] ${NC}"
    printf "%s\n" "  A switch receives an ingress frame on Gi0/1 with Source MAC AAAA and Dest MAC BBBB."
    printf "%s\n\n" "  The CAM table contains an entry for AAAA, but has NO entry for BBBB."
    printf "%b\n" "${BOLD}QUESTION: What action does the switch take with this frame?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Drops the frame and generates an ICMP Unreachable packet."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Floods the frame out all ports within the ingress VLAN except Gi0/1."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Broadcasts an ARP request for Destination MAC BBBB."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "8"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "2" ]; then update_streak_success; render_tracer "Gi0/1 (AAAA)" "CAM Unknown Unicast" "Flooded to VLAN" "FORWARD"
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! UNKNOWN UNICAST FLOODING EXECUTED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} When the Destination MAC is absent from the CAM table, the switch floods the frame across all ports in that VLAN except the ingress port."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_9() {
    local lvl="$1"; while true; do render_header "$lvl" "Collision vs. Broadcast Domain Boundaries"
    printf "%b\n" "${BG_META} [SEGMENTATION BOUNDARIES AUDIT] ${NC}"
    printf "%s\n" "  A network consists of one 24-port switch configured with 3 separate VLANs."
    printf "%s\n\n" "  All ports operate in Full-Duplex mode."
    printf "%b\n" "${BOLD}QUESTION: How many collision domains and broadcast domains exist?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} 24 Collision Domains and 3 Broadcast Domains"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} 1 Collision Domain and 24 Broadcast Domains"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} 3 Collision Domains and 24 Broadcast Domains"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "9"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! DOMAIN BOUNDARIES CALCULATED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Every full-duplex switch port is an independent collision domain (24 total). Each VLAN represents a distinct broadcast domain (3 total)."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_10() {
    local lvl="$1"; while true; do render_header "$lvl" "Layer 4 Transport Handshake & Control Flags"
    printf "%b\n" "${BG_META} [L4 TRANSPORT PROTOCOL AUDIT] ${NC}"
    printf "%s\n" "  A client initiates a web connection to a server. Host sends [SYN], server returns [SYN-ACK]."
    printf "%s\n\n" "  Immediately, the client host suffers an unrecoverable process crash before replying."
    printf "%b\n" "${BOLD}QUESTION: Which flag will the client kernel emit to abort the half-open socket?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} FIN"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} RST"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} PSH"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "10"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "2" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! RST FLAG ABORT IDENTIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} RST instantly tears down a connection without the 4-way FIN exchange, preventing socket buffer starvation."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_11() {
    local lvl="$1"; while true; do render_header "$lvl" "Well-Known Transport Port Mappings"
    printf "%b\n" "${BG_META} [APPLICATION IDENTIFICATION AUDIT] ${NC}"
    printf "%s\n" "  An engineer inspects packet captures showing traffic arriving on UDP Port 67."
    printf "%s\n\n" "  Simultaneously, another stream arrives on UDP Port 161."
    printf "%b\n" "${BOLD}QUESTION: What protocols are operating on these respective ports?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} DHCP Server and SNMP Polling"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} TFTP and NTP"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} DNS and Syslog"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "11"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! PORT MAP CONFIRMED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} UDP 67 = DHCP Server (Client is 68). UDP 161 = SNMP Polling (Traps use UDP 162)."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_12() {
    local lvl="$1"; while true; do render_header "$lvl" "IPv4 Header Fields & Loop Prevention"
    printf "%b\n" "${BG_META} [NETWORK LAYER PACKET AUDIT] ${NC}"
    printf "%s\n" "  A misconfigured routing loop causes an IPv4 packet to bounce between two routers."
    printf "%s\n\n" "  Each router decrements the 8-bit TTL field by 1 upon processing."
    printf "%b\n" "${BOLD}QUESTION: What occurs when the TTL reaches a value of 0?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Router drops the packet and emits an ICMP Type 11."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Router broadcasts the packet to locate an alternate gateway."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Packet resets TTL to 255 and traverses to the default route."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "12"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! TTL PURGE & ICMP NOTIFICATION IDENTIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Decrementing TTL prevents packets from circulating indefinitely. When TTL=0, the packet is discarded and an ICMP Type 11 message is sent to the source."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_13() {
    local lvl="$1"; while true; do render_header "$lvl" "Special IPv4 Address Spaces (RFC Standards)"
    printf "%b\n" "${BG_META} [IP ADDRESS CLASSIFICATION AUDIT] ${NC}"
    printf "%s\n" "  An ISP deploys an internal Carrier-Grade NAT (CGNAT) solution to conserve public IPs."
    printf "%s\n\n" "  Another technician notices a machine with address 169.254.12.33 after a cable disconnect."
    printf "%b\n" "${BOLD}QUESTION: Which RFC and purpose defines the CGNAT address block?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} RFC 1918 Private Address Space"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} RFC 6598 Shared Address Space"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} RFC 3021 Point-to-Point Links"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "13"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "2" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! RFC 6598 CGNAT SPECIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} RFC 6598 allocates 100.64.0.0/10 for Carrier-Grade NAT between customer equipment and ISP routers."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_14() {
    local lvl="$1"; while true; do render_header "$lvl" "IPv4 Subnet Calculations & Host Sizing"
    printf "%b\n" "${BG_META} [VLSM CALCULATION AUDIT] ${NC}"
    printf "%s\n" "  An organization requires a subnet that can host exactly 28 usable workstations."
    printf "%s\n\n" "  The engineer needs to minimize wasted addresses."
    printf "%b\n" "${BOLD}QUESTION: What is the optimal prefix length and subnet mask?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} /27 (255.255.255.224) providing 30 usable hosts"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} /28 (255.255.255.240) providing 28 usable hosts"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} /26 (255.255.255.192) providing 62 usable hosts"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "14"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! /27 MASK ACCURATELY SIZED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} /28 provides only 14 usable hosts (16 - 2). Sizing for 28 hosts requires /27 (30 usable hosts)."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_15() {
    local lvl="$1"; while true; do render_header "$lvl" "Host Subnet Mask & Default Gateway Logic"
    printf "%b\n" "${BG_META} [HOST BITWISE FORWARDING AUDIT] ${NC}"
    printf "%s\n" "  Host A (IP: 192.168.10.50 /26) sends a packet to Target B (192.168.10.70)."
    printf "%s\n\n" "  The host executes a bitwise AND operation between target IP and its configured mask."
    printf "%b\n" "${BOLD}QUESTION: How does Host A forward the initial Layer 2 frame?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} It broadcasts an ARP directly for Target B because both are in 192.168.10.0/26."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Target B is in a different subnet; frame goes to Default Gateway MAC."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Host A drops the packet as invalid."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "15"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "2" ]; then update_streak_success; render_tracer "192.168.10.50" "Bitwise AND Check" "Default Gateway MAC" "FORWARD"
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! GATEWAY LOGIC VERIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} With a /26 mask (block size 64), 192.168.10.50 belongs to subnet .0-.63, whereas .70 is in .64-.127. Being on a remote subnet, the frame must be addressed to the Default Gateway's MAC."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_16() {
    local lvl="$1"; while true; do render_header "$lvl" "IPv6 Address Compression Rules"
    printf "%b\n" "${BG_META} [IPV6 NOTATION COMPRESSION AUDIT] ${NC}"
    printf "%s\n" "  Consider the raw uncompressed IPv6 address:"
    printf "%b\n\n" "  ${C_CYAN}2001:0DB8:0000:0000:00A8:0000:0000:0001${NC}"
    printf "%b\n" "${BOLD}QUESTION: What is the valid compressed representation under RFC 5952?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} 2001:db8::a8::1"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} 2001:db8::a8:0:0:1"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} 2001:db8:0:0:a8::1"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "16"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "2" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! RFC 5952 FORMAT APPLIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} The '::' shorthand can only be used once in an address to prevent ambiguity. In ties, RFC 5952 dictates compressing the first/longest run."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_17() {
    local lvl="$1"; while true; do render_header "$lvl" "IPv6 Address Scopes & Multicast Targets"
    printf "%b\n" "${BG_META} [IPV6 CLASSIFICATION AUDIT] ${NC}"
    printf "%s\n" "  An engineer inspects three IPv6 addresses configured on a core router interface:"
    printf "%b\n\n" "  [A] ${C_CYAN}2001:db8:1::1${NC} | [B] ${C_YELLOW}fe80::1${NC} | [C] ${C_GREEN}ff02::2${NC}"
    printf "%b\n" "${BOLD}QUESTION: What address types are [A], [B], and [C]?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A]=GUA (Global Unicast), [B]=LLA (Link-Local), [C]=All-Routers Multicast"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [A]=ULA (Unique Local), [B]=GUA, [C]=Broadcast"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [A]=Multicast, [B]=Anycast, [C]=Loopback"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "17"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! IPV6 SCOPE TYPOLOGY MATCHED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} 2000::/3 = GUA (public internet routable). fe80::/10 = Link-Local (link-bound). ff02::2 = Link-local All-Routers multicast."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_18() {
    local lvl="$1"; while true; do render_header "$lvl" "EUI-64 Interface Identifier Math"
    printf "%b\n" "${BG_META} [IPV6 EUI-64 CALCULATION AUDIT] ${NC}"
    printf "%b\n" "  A router interface has MAC address ${C_CYAN}00:12:7F:44:55:66${NC}."
    printf "%s\n\n" "  The engineer configures SLAAC using EUI-64 on prefix 2001:db8:acad:1::/64."
    printf "%b\n" "${BOLD}QUESTION: What is the resulting 64-bit Interface Identifier?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} 0212:7fff:fe44:5566"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} 0012:7fff:fe44:5566"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} ffff:0012:7f44:5566"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "18"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! EUI-64 DERIVATION VALIDATED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Insert FFFE in the middle (0012:7fFF:FE44:5566) and invert bit 7 of the first byte (0000 0000 -> 0000 0010 = 02)."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_19() {
    local lvl="$1"; while true; do render_header "$lvl" "Neighbor Discovery Protocol (NDP) Mechanics"
    printf "%b\n" "${BG_META} [IPV6 L2 RESOLUTION AUDIT] ${NC}"
    printf "%s\n" "  IPv6 eliminates broadcast addressing and does not utilize legacy ARP."
    printf "%s\n\n" "  A host must resolve the Layer 2 MAC address of an on-link IPv6 neighbor."
    printf "%b\n" "${BOLD}QUESTION: Which NDP messages replace ARP Request and ARP Reply?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Router Solicitation and Router Advertisement"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Neighbor Solicitation and Neighbor Advertisement"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} DHCPv6 Request and DHCPv6 Ack"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "19"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "2" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! NS / NA RESOLUTION VERIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Neighbor Solicitation (NS) is sent to the target's solicited-node multicast to resolve its MAC. The target responds with a Neighbor Advertisement (NA)."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_20() {
    local lvl="$1"; while true; do render_header "$lvl" "Virtualization: Hypervisors vs Containers"
    printf "%b\n" "${BG_META} [COMPUTE VIRTUALIZATION AUDIT] ${NC}"
    printf "%s\n" "  An enterprise evaluates hosting options for high-density, low-latency microservices."
    printf "%s\n\n" "  Engineers compare Docker containers against VMware ESXi bare-metal VMs."
    printf "%b\n" "${BOLD}QUESTION: How do containers differ architecturally from virtual machines?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Containers bundle their own full guest operating system and virtual BIOS."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Containers share the host OS kernel and isolate user-space processes."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Containers require Type 2 hypervisors to bridge physical network NICs."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "20"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "2" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! CONTAINER ARCHITECTURE IDENTIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Containers share the underlying host kernel, avoiding the hypervisor and guest OS overhead of virtual machines."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_21() {
    local lvl="$1"; while true; do render_header "$lvl" "Cloud Service Architecture Boundaries"
    printf "%b\n" "${BG_META} [CLOUD SERVICE TIERS AUDIT] ${NC}"
    printf "%s\n" "  A corporate IT department migrates services to the public cloud."
    printf "%s\n\n" "  Deployment 1 uses AWS EC2 virtual servers; Deployment 2 uses Microsoft 365."
    printf "%b\n" "${BOLD}QUESTION: Which cloud delivery models correspond to Deployments 1 and 2?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Deployment 1 is IaaS; Deployment 2 is SaaS"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Deployment 1 is PaaS; Deployment 2 is IaaS"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Deployment 1 is SaaS; Deployment 2 is PaaS"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "21"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! CLOUD SERVICE MODELS CLASSIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} IaaS provisions raw compute/network instances where the customer manages the OS. SaaS delivers fully vendor-managed application services."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_22() {
    local lvl="$1"; while true; do render_header "$lvl" "Wireless RF Bands & Non-Overlapping Channels"
    printf "%b\n" "${BG_META} [WIRELESS SPECTRUM AUDIT] ${NC}"
    printf "%s\n" "  An enterprise WLAN deployment configures 2.4 GHz radios in an open office."
    printf "%s\n\n" "  The engineer needs to prevent co-channel interference across adjacent access points."
    printf "%b\n" "${BOLD}QUESTION: Which 2.4 GHz channels are non-overlapping in North America/ETSI?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Channels 1, 6, and 11"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Channels 2, 4, 6, and 8"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Channels 36, 40, and 44"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "22"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! 2.4 GHZ CHANNEL PLAN CONFIRMED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} In the 2.4 GHz spectrum, only channels 1, 6, and 11 have sufficient spacing (25 MHz center separation) to operate without overlapping interference."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_23() {
    local lvl="$1"; while true; do render_header "$lvl" "Wireless Security Evolution: WPA2 vs WPA3"
    printf "%b\n" "${BG_META} [WIRELESS ENCRYPTION AUDIT] ${NC}"
    printf "%s\n" "  A network audit flags legacy Pre-Shared Key (PSK) handshakes as vulnerable to"
    printf "%s\n\n" "  offline dictionary cracking attacks when 4-way handshakes are captured."
    printf "%b\n" "${BOLD}QUESTION: What protocol does WPA3 mandate to eliminate this vulnerability?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Simultaneous Authentication of Equals (SAE)"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Temporal Key Integrity Protocol (TKIP)"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Static WEP 128-bit keying"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "23"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! WPA3 SAE AUTHENTICATION VERIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} WPA3 replaces PSK with SAE (Simultaneous Authentication of Equals), providing forward secrecy and resistance to offline dictionary attacks."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_24() {
    local lvl="$1"; while true; do render_header "$lvl" "Split-MAC Architecture & CAPWAP Tunnels"
    printf "%b\n" "${BG_META} [WLAN ARCHITECTURE AUDIT] ${NC}"
    printf "%s\n" "  In a centralized Cisco Wireless deployment, Lightweight APs (LAPs) connect to a WLC."
    printf "%s\n\n" "  Engineers review the division of responsibilities between LAP and controller."
    printf "%b\n" "${BOLD}QUESTION: Which function is handled locally by the LAP in Split-MAC?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} 802.11 Authentication and Association processing"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Real-time MAC functions (Beacons, Probe replies, Frame acknowledgments)"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Radio Resource Management (RRM) channel allocations"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "24"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "2" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! REAL-TIME MAC FUNCTIONS IDENTIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Split-MAC offloads real-time functions (beacons, frame exchanges, buffering) to the AP, while management policies (auth, roaming, RRM) reside on the WLC."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_25() {
    local lvl="$1"; while true; do render_header "$lvl" "Virtual Routing and Forwarding (VRF) Segmentation"
    printf "%b\n" "${BG_META} [LAYER 3 VIRTUALIZATION AUDIT] ${NC}"
    printf "%s\n" "  Two corporate acquisitions need to connect across a single core router."
    printf "%s\n\n" "  Both companies utilize identical overlapping subnet ranges (192.168.1.0/24)."
    printf "%b\n" "${BOLD}QUESTION: What router virtualization technology isolates their routing tables?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Virtual Routing and Forwarding (VRF)"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} VLAN Trunking Protocol (VTP)"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Spanning Tree Protocol (STP)"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "25"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! VRF ISOLATION CONFIRMED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} VRF creates isolated Layer 3 routing tables on a single router, permitting overlapping IP schemes without routing conflicts."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_26() {
    local lvl="$1"; while true; do render_header "$lvl" "Layer 1 Physical Diagnostic Errors: Giants & Runts"
    printf "%b\n" "${BG_META} [PHYSICAL COUNTERS AUDIT] ${NC}"
    printf "%s\n" "  The output of 'show interfaces' reveals hundreds of 'Runts' accumulating on Gi0/2."
    printf "%s\n\n" "  A runt is defined as an ingress frame smaller than the standard minimum Ethernet size."
    printf "%b\n" "${BOLD}QUESTION: What is the minimum standard Ethernet frame size and typical cause?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} 64 bytes (caused by half-duplex collisions or electrical noise)"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} 1518 bytes (caused by jumbo frame misconfigurations)"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} 20 bytes (caused by missing IPv4 options)"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "26"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! RUNT MINIMUM IDENTIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Ethernet frames must be between 64 and 1518 bytes. Frames under 64 bytes (runts) stem from collisions or cable integrity faults."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_27() {
    local lvl="$1"; while true; do render_header "$lvl" "Interface Speed/Duplex Mismatch Symptoms"
    printf "%b\n" "${BG_META} [LAYER 1 TROUBLESHOOTING AUDIT] ${NC}"
    printf "%s\n" "  Switch-1 (Gi0/1) is hardcoded to 100/Full. Switch-2 (Gi0/1) is set to Auto-Negotiate."
    printf "%s\n\n" "  Link state shows UP/UP, but throughput is degraded with heavy CRC errors."
    printf "%b\n" "${BOLD}QUESTION: What duplex state did Switch-2 resolve to and why?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Half-Duplex (IEEE standard fallback when partner negotiation is absent)"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Full-Duplex"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Down/Down link fault"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "27"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! DUPLEX AUTO-FALLBACK IDENTIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} When one side is hardcoded, auto-negotiation fails to detect partner parameters, falling back to Half-Duplex and generating late collisions."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_28() {
    local lvl="$1"; while true; do render_header "$lvl" "WAN Topologies: Mesh Cabling Math"
    printf "%b\n" "${BG_META} [WAN ARCHITECTURE CALCULATION AUDIT] ${NC}"
    printf "%s\n" "  An enterprise designs a Full Mesh WAN topology connecting 6 regional headquarters."
    printf "%s\n\n" "  Every site must maintain a direct physical or logical link to every other site."
    printf "%b\n" "${BOLD}QUESTION: How many total point-to-point circuits are required?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} 15 circuits"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} 30 circuits"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} 6 circuits"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "28"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! FULL MESH LINKS CALCULATED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Full Mesh circuit requirements scale as N*(N-1)/2. For 6 sites: 6*5/2 = 15 circuits."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_29() {
    local lvl="$1"; while true; do render_header "$lvl" "Pluggable Transceiver Form Factors"
    printf "%b\n" "${BG_META} [HARDWARE TRANSCEIVER AUDIT] ${NC}"
    printf "%s\n" "  An infrastructure upgrade requires connecting access switches at 10 Gbps and"
    printf "%s\n\n" "  aggregation spine switches at 100 Gbps using hot-swappable optical modules."
    printf "%b\n" "${BOLD}QUESTION: Which transceiver form factors correspond to 10G and 100G?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} SFP+ for 10 Gbps and QSFP28 for 100 Gbps"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Standard SFP for 10 Gbps and SFP+ for 100 Gbps"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} GBIC for 10 Gbps and SFP+ for 100 Gbps"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "29"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! OPTICAL TRANSCEIVERS MATCHED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} SFP handles 1 Gbps, SFP+ supports 10 Gbps in the same footprint, and QSFP28 supports 100 Gbps via four 25 Gbps channels."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_30() {
    local lvl="$1"; while true; do render_header "$lvl" "Out-of-Band (OOB) Serial Console Pinouts"
    printf "%b\n" "${BG_META} [OOB MANAGEMENT AUDIT] ${NC}"
    printf "%s\n" "  A new Cisco router has zero configuration. The network is completely unreachable."
    printf "%s\n\n" "  The engineer uses an RJ-45 Rollover console cable connected to a laptop serial adapter."
    printf "%b\n" "${BOLD}QUESTION: How are the pinouts mapped on a Rollover cable?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Completely reversed (Pin 1 to Pin 8, Pin 2 to Pin 7, etc.)"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Identical to standard T568B straight-through"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Swapping only pins 1-2 and 3-6"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "30"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! ROLLOVER PINOUT VALIDATED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Rollover console cables reverse the pin sequence (1 to 8, 2 to 7) to bridge RS-232 serial signals to the Cisco RJ-45 console port."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_31() {
    local lvl="$1"; while true; do render_header "$lvl" "T568A vs T568B Twisted-Pair Color Sequencing"
    printf "%b\n" "${BG_META} [COPPER TERMINATION AUDIT] ${NC}"
    printf "%s\n" "  A technician terminates a patch cable using the standard T568B sequence."
    printf "%s\n\n" "  The punch-down tool aligns pairs 1, 2, 3, and 6 carefully."
    printf "%b\n" "${BOLD}QUESTION: What are the first three wire colors in the T568B standard?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} White/Orange, Orange, White/Green"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} White/Green, Green, White/Orange"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} White/Brown, Brown, Orange"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "31"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! T568B COLOR SEQUENCE CONFIRMED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} T568B begins White/Orange, Orange, White/Green. T568A begins White/Green, Green, White/Orange."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_32() {
    local lvl="$1"; while true; do render_header "$lvl" "IPv6 SLAAC & Duplicate Address Detection (DAD)"
    printf "%b\n" "${BG_META} [IPV6 AUTOCONFIGURATION AUDIT] ${NC}"
    printf "%s\n" "  A booting workstation autoconfigures an address using SLAAC."
    printf "%s\n\n" "  Before binding the IP, it must guarantee no conflicting device shares the address."
    printf "%b\n" "${BOLD}QUESTION: How does the host execute Duplicate Address Detection (DAD)?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Sends an NS for its own tentative address; if an NA returns, it flags a conflict."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Broadcasts an IPv4 ARP request to link-layer 255.255.255.255."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Queries the local DNS server via UDP 53."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "32"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! DAD MECHANISM VALIDATED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} During DAD, the host issues a Neighbor Solicitation for its tentative address from the unspecified address (::). If any node replies with an NA, the address is discarded."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_33() {
    local lvl="$1"; while true; do render_header "$lvl" "TCP Dynamic Windowing & Flow Control"
    printf "%b\n" "${BG_META} [L4 RELIABILITY AUDIT] ${NC}"
    printf "%s\n" "  A file server transmits data packets to a client workstation across a WAN link."
    printf "%s\n\n" "  The receiving client notices its incoming network buffer fills to capacity."
    printf "%b\n" "${BOLD}QUESTION: How does TCP dynamic windowing handle this buffer exhaustion?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Client advertises a smaller Window Size in return ACKs (down to 0)."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Client immediately transmits a FIN-ACK sequence."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Client converts the transport protocol from TCP to UDP."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "33"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! FLOW CONTROL WINDOWING VERIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} The TCP Window field advertises buffer capacity. When congested, the receiver throttles the sender by shrinking the window size."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_34() {
    local lvl="$1"; while true; do render_header "$lvl" "Next-Generation Firewall (NGFW) vs Traditional"
    printf "%b\n" "${BG_META} [SECURITY ENGINE AUDIT] ${NC}"
    printf "%s\n" "  A legacy firewall checks source/dest IP and Layer 4 ports."
    printf "%s\n\n" "  Malicious web applications bypass it by tunneling command-and-control over Port 443."
    printf "%b\n" "${BOLD}QUESTION: What capability distinguishes a Next-Gen Firewall (NGFW)?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Layer 7 Deep Packet Inspection, AVC, and TLS decryption"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} High-speed ASIC Layer 2 switching"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Operating exclusively as a stateless packet filter"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "34"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! NGFW CAPABILITIES CONFIRMED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} NGFWs perform Layer 7 inspection, decrypting SSL/TLS and identifying applications regardless of what transport port they use."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_35() {
    local lvl="$1"; while true; do render_header "$lvl" "SDN Architecture & Cisco Catalyst Center"
    printf "%b\n" "${BG_META} [CONTROLLER-BASED LOGIC AUDIT] ${NC}"
    printf "%s\n" "  In Software-Defined Networking (SDN), control plane logic is decoupled from hardware."
    printf "%s\n\n" "  Cisco Catalyst Center (DNA Center) communicates with edge switches."
    printf "%b\n" "${BOLD}QUESTION: Which API interface category manages the switches in the data plane?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Southbound APIs (e.g. NETCONF, RESTCONF, OpenFlow)"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Northbound APIs (RESTful HTTP)"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} East-West APIs"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "35"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! SOUTHBOUND APIS IDENTIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Southbound APIs connect the SDN controller down to managed network devices. Northbound APIs face applications and orchestration platforms."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_36() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: 'show interfaces' Status & Errors"
    printf "%b\n" "${BG_META} [CISCO IOS CLI OUTPUT AUDIT] ${NC}"
    printf "%s\n" "  GigabitEthernet0/1 is up, line protocol is up"
    printf "%b\n" "  ${C_RED}1452 input errors, 1421 CRC, 0 frame, 0 overrun, 0 ignored${NC}"
    printf "%b\n\n" "  ${C_RED}835 late collision, 1221 deferred${NC}"
    printf "%b\n" "${BOLD}QUESTION: What physical condition creates late collisions and CRC errors?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} A duplex mismatch (one side Half, one side Full) or faulty cable termination"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Missing IP default-gateway"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} OSPF MTU mismatch"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "27"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! DUPLEX MISMATCH & CRC ROOT CAUSE ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Late collisions occur when collisions happen after the first 64 bytes of transmission, a classic signature of duplex mismatch."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_37() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: 'show ip interface brief' Line States"
    printf "%b\n" "${BG_META} [CISCO IOS CLI OUTPUT AUDIT] ${NC}"
    printf "%s\n" "  Interface                  IP-Address      OK? Method Status                Protocol"
    printf "%b\n\n" "  GigabitEthernet0/0         10.1.1.1        YES manual ${C_YELLOW}up${NC}                    ${C_RED}down${NC}"
    printf "%b\n" "${BOLD}QUESTION: What does 'Status: UP / Protocol: DOWN' indicate?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Layer 1 carrier is detected, but Layer 2 framing/keepalive has failed."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} The interface is administratively disabled with 'shutdown'."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} The assigned IPv4 address is already used on another host."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "36"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! L2 ENCAPSULATION FAILURE IDENTIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Status UP = Layer 1 electrical/light sync OK. Protocol DOWN = Layer 2 issue (clock rate, encapsulation mismatch, or no keepalives)."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_38() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: 'show mac address-table' Inspection"
    printf "%b\n" "${BG_META} [CISCO IOS CLI OUTPUT AUDIT] ${NC}"
    printf "%s\n" "  Vlan    Mac Address       Type        Ports"
    printf "%s\n" "  ----    -----------       --------    -----"
    printf "%b\n" "    10    0011.2233.4455    ${C_GREEN}DYNAMIC${NC}     Gi0/2"
    printf "%s\n\n" "    10    ffff.ffff.ffff    STATIC      CPU"
    printf "%b\n" "${BOLD}QUESTION: What is the default aging timer for dynamically learned MAC entries?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} 300 seconds"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} 60 seconds"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} 86400 seconds"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "8"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! CAM AGING TIMER VERIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Dynamic MAC address table entries age out after 300 seconds of inactivity to free CAM memory."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_39() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: 'show ip arp' Cache Resolution"
    printf "%b\n" "${BG_META} [CISCO IOS CLI OUTPUT AUDIT] ${NC}"
    printf "%s\n" "  Protocol  Address          Age (min)  Hardware Addr   Type   Interface"
    printf "%s\n" "  Internet  192.168.1.1             -   c402.12a8.0001  ARPA   GigabitEthernet0/0"
    printf "%b\n\n" "  Internet  192.168.1.50           12   ${C_CYAN}0050.56a1.2233${NC}  ARPA   GigabitEthernet0/0"
    printf "%b\n" "${BOLD}QUESTION: What functional mapping does this table provide?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Resolves Layer 3 IP addresses to Layer 2 MAC addresses."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Resolves Layer 2 MAC addresses to physical switch interfaces."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Maps DNS domain names to public IP addresses."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "8"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! ARP CACHE RESOLUTION VERIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} ARP resolves Layer 3 IPs to Layer 2 MAC addresses. The CAM table resolves Layer 2 MACs to switch ports."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_40() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: 'show version' Hardware & Register"
    printf "%b\n" "${BG_META} [CISCO IOS CLI OUTPUT AUDIT] ${NC}"
    printf "%s\n" "  Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(2)SE4"
    printf "%s\n" "  System image file is \"flash:/c2960-lanbasek9-mz.150-2.SE4.bin\""
    printf "%b\n\n" "  ${C_YELLOW}Configuration register is 0x2102${NC}"
    printf "%b\n" "${BOLD}QUESTION: What does the standard register value 0x2102 instruct the router to do?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Load startup-config from NVRAM and boot IOS image from flash."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Bypass NVRAM completely."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Boot directly into ROMmon prompt."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "36"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! CONFIG REGISTER BOOT SEQUENCE CONFIRMED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} 0x2102 is standard normal boot (load NVRAM config). 0x2142 ignores NVRAM startup-config for password recovery."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_41() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: 'show ipv6 interface brief' Status"
    printf "%b\n" "${BG_META} [CISCO IOS CLI OUTPUT AUDIT] ${NC}"
    printf "%s\n" "  GigabitEthernet0/0     [up/up]"
    printf "%b\n" "      ${C_YELLOW}FE80::1${NC}"
    printf "%b\n\n" "      ${C_CYAN}2001:DB8:ACAD:1::1${NC}"
    printf "%b\n" "${BOLD}QUESTION: Can the link-local address FE80::1 be reused on another local interface?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Yes, because link-local addresses are unique only to their local link."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} No, all IPv6 addresses must be globally unique across the router."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Only if configured with EUI-64."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "17"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! LINK-LOCAL SCOPE CONFIRMED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Link-Local Addresses (fe80::/10) are bound strictly to the local Layer 2 link and can be reused on different interfaces."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_42() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: 'show controllers' Layer 1 Inspection"
    printf "%b\n" "${BG_META} [CISCO IOS CLI OUTPUT AUDIT] ${NC}"
    printf "%s\n" "  Router# show controllers serial 0/0/0"
    printf "%s\n" "  Interface Serial0/0/0"
    printf "%s\n" "  Hardware is PowerQUICC MPC860"
    printf "%b\n\n" "  ${C_CYAN}DTE V.35 TX and RX clocks detected${NC}"
    printf "%b\n" "${BOLD}QUESTION: What does this output tell the engineer about clocking?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Interface is a DTE and must receive clocking from the external DCE device."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Interface is a DCE and requires the 'clock rate' command locally."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} The cable is disconnected or broken."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "36"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! DTE CLOCKING IDENTIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} DTE devices receive clock signals from the DCE provider (e.g. CSU/DSU modem). Only DCE interfaces supply the clock rate."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_43() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Screen Scrolling: 'terminal length' Command"
    printf "%b\n" "${BG_META} [CLI NAVIGATION AUDIT] ${NC}"
    printf "%s\n" "  An engineer generates a 500-line output that constantly pauses with '--More--'."
    printf "%s\n\n" "  The engineer needs to capture the output in a single continuous stream."
    printf "%b\n" "${BOLD}QUESTION: Which CLI command disables the screen-pause pagination?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} terminal length 0"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} no pause"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} line vty 0 4 length 1"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "36"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! PAGINATION DISABLED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} 'terminal length 0' sets the current session window height to infinite, allowing uninterrupted screen outputs."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_44() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: 'show hosts' Name Cache"
    printf "%b\n" "${BG_META} [CISCO IOS CLI OUTPUT AUDIT] ${NC}"
    printf "%s\n" "  Default domain is cisco.com"
    printf "%s\n" "  Name/address lookup tracks cache: Flags (perm, temp, valid)"
    printf "%s\n" "  Host                  Flags      Age Type   Address(es)"
    printf "%b\n\n" "  server1.cisco.com     (temp, OK)  2   IP     192.168.10.15"
    printf "%b\n" "${BOLD}QUESTION: What subsystem built this entry?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} DNS Name Resolution (UDP Port 53)"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} ARP Layer 2 broadcasts"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} CDP neighbor discovery"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "11"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! DNS CACHE CONFIRMED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} 'show hosts' displays cached name-to-IP resolutions acquired via DNS or static 'ip host' CLI entries."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_45() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: Subnet Range Sizing /31 (RFC 3021)"
    printf "%b\n" "${BG_META} [POINT-TO-POINT IP SIZING AUDIT] ${NC}"
    printf "%s\n" "  Interface GigabitEthernet0/0/0"
    printf "%s\n\n" "   ip address 10.0.0.0 255.255.255.254"
    printf "%b\n" "${BOLD}QUESTION: Why is this /31 configuration valid on point-to-point links?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} RFC 3021 permits using network & broadcast as endpoint addresses on P2P links."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} It is invalid; routers reject all /31 subnet masks."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} Only IPv6 supports 2-address subnets."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "14"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! RFC 3021 USAGE VALIDATED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} RFC 3021 allows /31 prefixes on point-to-point circuits, utilizing both available bit combinations (0 and 1) for the two endpoints."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_46() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: TCP Port Exhaustion & Sockets"
    printf "%b\n" "${BG_META} [HOST SOCKET AUDIT] ${NC}"
    printf "%s\n" "  A network engineer runs 'netstat -an' on an application server:"
    printf "%s\n" "  Proto  Local Address          Foreign Address        State"
    printf "%b\n" "  TCP    192.168.1.10:443       10.20.1.5:49152        ${C_GREEN}ESTABLISHED${NC}"
    printf "%b\n\n" "  TCP    192.168.1.10:443       10.20.1.6:49153        ${C_YELLOW}TIME_WAIT${NC}"
    printf "%b\n" "${BOLD}QUESTION: What does the TIME_WAIT socket state represent?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} The endpoint is waiting sufficient time to ensure the remote host received the final ACK."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} The socket has crashed and is dropping packets."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} The client is initiating a 3-way SYN handshake."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "10"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! TIME_WAIT STATE CONFIRMED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} TIME_WAIT keeps the socket alive for 2xMSL (Maximum Segment Lifetime) to ensure retransmitted FINs are caught before closing."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_47() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: 'show interfaces' Giants Counter"
    printf "%b\n" "${BG_META} [CISCO IOS CLI OUTPUT AUDIT] ${NC}"
    printf "%s\n" "  GigabitEthernet0/1 is up, line protocol is up"
    printf "%s\n" "  MTU 1500 bytes, BW 1000000 Kbit/sec"
    printf "%b\n\n" "  ${C_RED}2400 input errors, 2400 giants, 0 CRC${NC}"
    printf "%b\n" "${BOLD}QUESTION: Why are 'Giants' accumulating on this interface?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} Frames arriving exceed the standard 1500 MTU (e.g. jumbo frames sent by server)."
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} Frames arriving are smaller than 64 bytes."
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} The link is operating at Half-Duplex."
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "26"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! JUMBO FRAME / GIANTS IDENTIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} A giant is an ingress frame larger than the interface configured MTU (typically 1518 bytes untagged). Occurs when servers transmit 9000-byte jumbo frames to a 1500 MTU port."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_48() {
    local lvl="$1"; while true; do render_header "$lvl" "CLI Diagnostic: Wi-Fi CAPWAP Port Tunnel Check"
    printf "%b\n" "${BG_META} [WLC CLI TELEMETRY AUDIT] ${NC}"
    printf "%s\n" "  A firewall sits between Lightweight APs and a Cisco 9800 WLC."
    printf "%s\n\n" "  LAPs register control sessions but client data traffic drops completely."
    printf "%b\n" "${BOLD}QUESTION: Which UDP ports must be permitted across the firewall?${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} UDP 5246 (Control Plane) and UDP 5247 (Data Plane)"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} TCP 80 and TCP 443"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} UDP 161 and UDP 162"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "24"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! CAPWAP UDP PORTS VERIFIED ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} CAPWAP uses UDP 5246 for DTLS encrypted control messages and UDP 5247 for client data transport."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_49() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: IPv4 Static Interface Assignment" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Assign IP 192.168.10.1/24 to interface Gi0/1 and enable it ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} interface GigabitEthernet0/1                                         ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} ip address 192.168.10.1 255.255.255.0                                 ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} no shutdown                                                            ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} ip address 192.168.10.1/24                                            ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[E]${NC} enable port                                                            ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the 3 blocks in sequence:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A] + [B] + [C]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [A] + [D] + [E]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [B] + [C] + [A]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "36"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! INTERFACE IP CONFIGURED [A + B + C] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Cisco IOS IPv4 interface configuration requires dotted-decimal subnet masks (255.255.255.0) and 'no shutdown' to change administrative status to UP."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_50() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: IPv6 Global Unicast & EUI-64" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Configure IPv6 address using EUI-64 on prefix 2001:db8:1::/64 ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} interface GigabitEthernet0/0                                         ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} ipv6 address 2001:db8:1::/64 eui-64                                   ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} ipv6 enable                                                            ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} ip address 2001:db8:1::/64                                            ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[E]${NC} ipv6 address autoconfig                                                ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the 2 blocks to assign the EUI-64 address:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A] + [B]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [A] + [E]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [C] + [D]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "18"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! EUI-64 CLI SYNTAX CONFIGURED [A + B] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} The 'ipv6 address <prefix>/64 eui-64' command dynamically builds the host 64-bit ID from the MAC address."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_51() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: IPv6 Routing Enablement" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Enable IPv6 unicast packet forwarding globally on a Cisco router ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} ipv6 unicast-routing                                                   ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} ip routing ipv6                                                        ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} ipv6 forward-all                                                       ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} router ipv6                                                            ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the mandatory global command:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [B]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [C]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "17"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! IPV6 UNICAST ROUTING ENABLED [A] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Cisco routers do not route IPv6 packets or send Router Advertisements (RA) until 'ipv6 unicast-routing' is enabled globally."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_52() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: IPv6 Link-Local Static Override" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Assign custom Link-Local address FE80::1 to interface Gi0/0 ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} interface GigabitEthernet0/0                                         ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} ipv6 address fe80::1 link-local                                        ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} ipv6 address fe80::1/10                                                ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} ipv6 link-local fe80::1                                                ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the 2 correct blocks:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A] + [B]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [A] + [C]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [A] + [D]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "17"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! LINK-LOCAL SYNTAX MATCHED [A + B] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Static link-local addresses require the 'link-local' keyword at the end without a prefix length."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_53() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: Default Gateway Assignment on L2 Switch" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Configure Default Gateway 192.168.1.254 on a Layer 2 switch ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} ip default-gateway 192.168.1.254                                      ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} ip route 0.0.0.0 0.0.0.0 192.168.1.254                                 ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} gateway 192.168.1.254                                                  ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} default-route 192.168.1.254                                            ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the valid command for an L2 management switch:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [B]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [C]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "15"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! L2 DEFAULT GATEWAY CONFIGURED [A] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Layer 2 switches do not run an active routing engine ('ip routing' is disabled). They require 'ip default-gateway' for out-of-subnet management traffic."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_54() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: Switch Management SVI Configuration" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Create Management SVI on VLAN 10 with IP 10.10.10.2/24 ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} interface vlan 10                                                      ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} ip address 10.10.10.2 255.255.255.0                                    ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} no shutdown                                                            ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} interface switchport 10                                                ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[E]${NC} ip management 10.10.10.2 255.255.255.0                                 ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the 3 blocks in sequence:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A] + [B] + [C]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [D] + [B] + [C]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [A] + [E] + [C]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "1"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! MANAGEMENT SVI BROUGHT UP [A + B + C] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} A Switch Virtual Interface (SVI) acts as the Layer 3 management IP for a VLAN on a switch."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_55() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: Static MAC Address Table Binding" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Statically map MAC 0011.2233.4455 to Gi0/5 in VLAN 10 ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} mac address-table static 0011.2233.4455 vlan 10 interface Gi0/5        ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} ip arp 0011.2233.4455 Gi0/5 vlan 10                                    ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} mac-table add 0011.2233.4455 interface Gi0/5                          ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} switchport static-mac 0011.2233.4455                                  ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the correct static CAM configuration command:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [B]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [C]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "8"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! STATIC CAM ENTRY INSTALLED [A] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Static MAC assignments prevent flooding and stay permanently in the CAM table without aging out."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_56() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: IPv4 Loopback Interface Creation" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Create diagnostic Loopback0 with address 1.1.1.1/32 ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} interface Loopback0                                                    ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} ip address 1.1.1.1 255.255.255.255                                    ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} ip address 1.1.1.1 255.255.255.0                                      ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} loopback enable                                                        ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the 2 correct blocks:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A] + [B]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [A] + [C]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [A] + [D]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "14"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! LOOPBACK CREATED [A + B] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} Loopbacks are virtual interfaces that remain constantly UP/UP unless manually shut down, making them ideal router IDs and diagnostic endpoints."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_57() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: Speed & Duplex Hardcoding" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Hardcode FastEthernet0/1 to 100 Mbps and Full Duplex ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} interface FastEthernet0/1                                              ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} speed 100                                                              ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} duplex full                                                            ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} negotiate 100-full                                                     ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[E]${NC} bandwidth 100000                                                       ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the 3 blocks in sequence:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A] + [B] + [C]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [A] + [D] + [E]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [B] + [C] + [A]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "27"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! HARDCODED SPEED/DUPLEX [A + B + C] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} When hardcoding one end of a link to speed 100 and duplex full, the remote end must also be hardcoded to prevent duplex mismatches."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_58() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: Local DNS Host Resolution Entry" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Map hostname 'logserver' to IP 10.0.0.50 locally in Cisco IOS ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} ip host logserver 10.0.0.50                                            ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} dns-map logserver 10.0.0.50                                            ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} hostname logserver 10.0.0.50                                          ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} name-server 10.0.0.50 logserver                                        ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the static host mapping command:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [B]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [C]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "44"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! STATIC HOST MAPPING INSTALLED [A] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} The 'ip host <name> <IP>' command configures a static DNS entry in the device local hosts table."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_59() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: Disable Automatic Telnet DNS Broadcasts" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Prevent CLI typo delays ('Translating... domain server') ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} no ip domain-lookup                                                    ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} no ip dns-broadcast                                                   ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} disable name-lookup                                                    ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} ip name-server disable                                                 ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the command to disable typo DNS lookups:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [B]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [C]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "11"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! TYPO DNS LOOKUPS DISABLED [A] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} 'no ip domain-lookup' stops IOS from treating misspelled CLI commands as domain names to resolve via broadcast."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

module_60() {
    local lvl="$1"; while true; do render_header "$lvl" "Syntax Drill: Erase NVRAM & Device Factory Reset" "SYNTAX FORGE"
    printf "%b\n\n" "${BG_META} [OBJECTIVE] Completely wipe startup configuration to restore factory defaults ${NC}"
    printf "%b\n" "${C_PURPLE}╔════ COMMAND VAULT (SYNTAX BLOCKS) ═════════════════════════════════════════╗${NC}"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[A]${NC} write erase                                                            ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[B]${NC} reload                                                                 ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[C]${NC} delete flash:config.text                                               ║"
    printf "%b\n" "║ ${BOLD}${C_YELLOW}[D]${NC} clear running-config                                                   ║"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    printf "%b\n" "${BOLD}DECISION: Select the 2 commands in sequence:${NC}"
    printf "%b\n" "  ${C_YELLOW}► [1]${NC} [A] + [B]"
    printf "%b\n" "  ${C_YELLOW}► [2]${NC} [D] + [B]"
    printf "%b\n" "  ${C_YELLOW}► [3]${NC} [C] + [A]"
    printf "%b\n\n" "  ${C_PURPLE}► [H] Open Intel Dossier (10s Timer)${NC}"
    ask_with_timer_or_manual "Select Option [1-3, H]: " "^[1-3]$" "40"
    [ $? -eq 99 ] && { [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Press [ENTER]..."; continue; }
    if [ "$USER_INPUT" == "1" ]; then update_streak_success
        printf "\n%b\n" "${BG_ACCEPT} ✔ CORRECT! NVRAM FLUSH & FACTORY RELOAD [A + B] ${NC}"
        printf "%b\n\n" "${BOLD}${C_GREEN}CORE INSIGHT:${NC} 'write erase' empties the NVRAM startup-config. Upon reload, the device boots into the initial System Configuration Dialog."
        read -rp "Press [ENTER] to advance..."; return 0
    else update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "\n%b\n\n" "${BG_DROP} ✖ WRONG (-1 INTEGRITY) ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; fi; done
}

apply_integrity_restore() {
    if [ "$INTEGRITY" -lt "$MAX_INTEGRITY" ]; then
        INTEGRITY=$((INTEGRITY + 1))
        printf "%b\n" "${C_GREEN}${BOLD}✔ SYSTEM INTEGRITY RESTORED! Current Blocks: $INTEGRITY/3${NC}"
    else
        printf "%b\n" "${C_GREEN}${BOLD}System Integrity already at maximum capacity (3/3)!${NC}"
    fi
}

run_apex_escalation_1() {
    local b_num="$1"; while true; do
        render_header "$b_num" "DATA CENTER FABRIC AUDIT" "APEX ESCALATION #1: SPINE-LEAF TRIAGE"
        printf "%b\n\n" "${BG_ESCALATION} ⚠ INCIDENT: HIGH LATENCY & PACKET CORRUPTION REPORTED ⚠ ${NC}"
        
        printf "%b\n" "${BOLD}[EVENT 1/3]${NC} A junior admin connects Spine-1 directly to Spine-2 to 'add redundancy'."
        read -rp "Decision [1: PERMIT, 2: REMOVE CABLE IMMEDIATELY]: " a1
        [ "$a1" != "2" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! Spines must never connect to other spines! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BOLD}[EVENT 2/3]${NC} Switch port Gi0/1 shows 'Late Collisions' incrementing rapidly."
        read -rp "Decision [1: Fix Duplex Mismatch, 2: Change IP address]: " a2
        [ "$a2" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! Late collisions indicate duplex mismatch! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BOLD}[EVENT 3/3]${NC} Access switch uplink must deliver 10 Gbps across 35 meters of copper."
        read -rp "Decision [1: Use Cat6, 2: Cat5e is sufficient]: " a3
        [ "$a3" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! Cat5e supports max 1 Gbps! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BG_ACCEPT} ✔ APEX ESCALATION #1 CLEARED: FABRIC RESTORED! ${NC}"
        apply_integrity_restore; update_streak_success; read -rp "Press [ENTER] to advance..."; return 0
    done
}

run_apex_escalation_2() {
    local b_num="$1"; while true; do
        render_header "$b_num" "IPV6 CRITICAL INFRASTRUCTURE AUDIT" "APEX ESCALATION #2: IPV6 MIGRATION"
        printf "%b\n\n" "${BG_ESCALATION} ⚠ CHECKPOINT 1 UNLOCK TRIAL (STAGE 21) ⚠ ${NC}"
        
        printf "%b\n" "${BOLD}[EVENT 1/3]${NC} Interface MAC is 0050.7966.6800. What is the EUI-64 Host ID?"
        read -rp "Decision [1: 0250:79ff:fe66:6800, 2: 0050:79ff:fe66:6800]: " b1
        [ "$b1" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! Bit 7 must be inverted (00 -> 02)! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BOLD}[EVENT 2/3]${NC} A host sends a Neighbor Solicitation for its own address. What is this?"
        read -rp "Decision [1: Duplicate Address Detection, 2: DHCP Lease Renewal]: " b2
        [ "$b2" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! This is DAD! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BOLD}[EVENT 3/3]${NC} Compress 2001:0000:0000:0000:0000:0000:0000:0001 under RFC 5952."
        read -rp "Decision [1: 2001::1, 2: 2001:0::1]: " b3
        [ "$b3" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! Continuous zeros become :: ! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BG_ACCEPT} ✔ CHECKPOINT 1 SAVED (STAGE 21 UNLOCKED)! ${NC}"
        CURRENT_CHECKPOINT=21
        CKPT_MISTAKES=$MISTAKES_COUNT
        CKPT_TIMEOUTS=$TIMEOUTS_COUNT
        CKPT_MAX_STREAK=$MAX_STREAK
        CKPT_START_TIME=$SESSION_START_TIME
        apply_integrity_restore; update_streak_success; read -rp "Press [ENTER] to advance..."; return 0
    done
}

run_apex_escalation_3() {
    local b_num="$1"; while true; do
        render_header "$b_num" "CAMPUS VLSM SUBNET EMERGENCY" "APEX ESCALATION #3: ADDRESS ALLOCATION"
        printf "%b\n\n" "${BG_ESCALATION} ⚠ OUT-OF-CAPACITY ESCALATION ⚠ ${NC}"
        
        printf "%b\n" "${BOLD}[EVENT 1/3]${NC} Subnet 192.168.1.0/28 needs the broadcast address."
        read -rp "Decision [1: 192.168.1.15, 2: 192.168.1.31]: " c1
        [ "$c1" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! /28 block is 16, broadcast is .15! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BOLD}[EVENT 2/3]${NC} ISP assigns 100.64.0.1 to your WAN. What RFC address range is this?"
        read -rp "Decision [1: RFC 6598 Carrier-Grade NAT, 2: RFC 1918 Private]: " c2
        [ "$c2" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! 100.64.0.0/10 is CGNAT! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BOLD}[EVENT 3/3]${NC} Point-to-point link between two core routers. What mask wastes zero IPs?"
        read -rp "Decision [1: /31, 2: /30]: " c3
        [ "$c3" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! /31 uses exactly 2 IPs under RFC 3021! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BG_ACCEPT} ✔ APEX ESCALATION #3 CLEARED: SUBNETTING VALIDATED! ${NC}"
        apply_integrity_restore; update_streak_success; read -rp "Press [ENTER] to advance..."; return 0
    done
}

run_apex_escalation_4() {
    local b_num="$1"; while true; do
        render_header "$b_num" "SWITCH DATA PLANE ATTACK MITIGATION" "APEX ESCALATION #4: CAM & ARP CRISIS"
        printf "%b\n\n" "${BG_ESCALATION} ⚠ CHECKPOINT 2 UNLOCK TRIAL (STAGE 41) ⚠ ${NC}"
        
        printf "%b\n" "${BOLD}[EVENT 1/3]${NC} Ingress frame with Unknown Unicast Dest MAC arrives on Gi0/2 (VLAN 20)."
        read -rp "Decision [1: Flood to all ports in VLAN 20 except Gi0/2, 2: Drop immediately]: " d1
        [ "$d1" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! Unknown unicast must be flooded! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BOLD}[EVENT 2/3]${NC} Host A bitwise-ANDs Dest IP 172.16.1.100 with its mask; Network ID does not match."
        read -rp "Decision [1: Send frame to Default Gateway MAC, 2: ARP directly for 172.16.1.100]: " d2
        [ "$d2" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! Different subnet traffic goes to Default Gateway MAC! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BOLD}[EVENT 3/3]${NC} An Ethernet frame arrives measured at 52 bytes total length."
        read -rp "Decision [1: Drop as Runt, 2: Accept as valid fragment]: " d3
        [ "$d3" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! Frames under 64 bytes are Runts! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BG_ACCEPT} ✔ CHECKPOINT 2 SAVED (STAGE 41 UNLOCKED)! ${NC}"
        CURRENT_CHECKPOINT=41
        CKPT_MISTAKES=$MISTAKES_COUNT
        CKPT_TIMEOUTS=$TIMEOUTS_COUNT
        CKPT_MAX_STREAK=$MAX_STREAK
        CKPT_START_TIME=$SESSION_START_TIME
        apply_integrity_restore; update_streak_success; read -rp "Press [ENTER] to advance..."; return 0
    done
}

run_apex_escalation_5() {
    local b_num="$1"; while true; do
        render_header "$b_num" "ENTERPRISE WIRELESS & SDN ARCHITECTURE" "APEX ESCALATION #5: FINAL CERTIFICATION"
        printf "%b\n\n" "${BG_ESCALATION} ⚠ FINAL APEX CHALLENGE ⚠ ${NC}"
        
        printf "%b\n" "${BOLD}[EVENT 1/4]${NC} Centralized WLC is blocked on firewall port UDP 5246. What drops?"
        read -rp "Decision [1: CAPWAP Control Tunnel drops, 2: Data plane drops only]: " e1
        [ "$e1" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! UDP 5246 is CAPWAP Control! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BOLD}[EVENT 2/4]${NC} What provides enterprise wireless resistance to offline dictionary attacks?"
        read -rp "Decision [1: WPA3 with SAE, 2: WPA2 with TKIP]: " e2
        [ "$e2" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! WPA3 SAE is required! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BOLD}[EVENT 3/4]${NC} In Split-MAC, which entity handles 802.11 client authentication?"
        read -rp "Decision [1: Centralized WLC, 2: Lightweight AP]: " e3
        [ "$e3" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! Authentication resides on the WLC! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BOLD}[EVENT 4/4]${NC} What is the non-overlapping 20 MHz channel allocation in 2.4 GHz?"
        read -rp "Decision [1: 1, 6, 11, 2: 1, 2, 3, 4]: " e4
        [ "$e4" != "1" ] && { update_streak_failure; INTEGRITY=$((INTEGRITY - 1)); printf "%b\n" "${BG_DROP} WRONG! Channels 1, 6, 11 are non-overlapping! ${NC}"; [ "$INTEGRITY" -le 0 ] && return 2; read -rp "Retry..."; continue; }
        
        printf "\n%b\n" "${BG_ACCEPT} ✔ APEX ESCALATION #5 CLEARED: 100% CCNA DOMAIN 1 PROFICIENCY ACHIEVED! ${NC}"
        apply_integrity_restore; update_streak_success; read -rp "Press [ENTER] to view final grade..."; return 0
    done
}

render_big_grade() {
    local num_str="$1"
    local l1="" l2="" l3="" l4=""

    for (( i=0; i<${#num_str}; i++ )); do
        case "${num_str:i:1}" in
            0) l1+=" ████  "; l2+="█    █ "; l3+="█    █ "; l4+=" ████  " ;;
            1) l1+="   ██ "; l2+="  ███  "; l3+="   ██ "; l4+=" █████ " ;;
            2) l1+=" ████  "; l2+="     █ "; l3+=" ████  "; l4+="██████ " ;;
            3) l1+=" ████  "; l2+="   ██  "; l3+="     █ "; l4+=" ████  " ;;
            4) l1+="█    █ "; l2+="█    █ "; l3+="██████ "; l4+="    █  " ;;
            5) l1+="██████ "; l2+="████   "; l3+="    ██ "; l4+="████   " ;;
            6) l1+=" ████  "; l2+="█      "; l3+="█████  "; l4+=" ████  " ;;
            7) l1+="██████ "; l2+="    █  "; l3+="   █   "; l4+="  █    " ;;
            8) l1+=" ████  "; l2+=" ████  "; l3+="█    █ "; l4+=" ████  " ;;
            9) l1+=" ████  "; l2+=" █████ "; l3+="     █ "; l4+=" ████  " ;;
            *) l1+="       "; l2+="       "; l3+="       "; l4+="       " ;;
        esac
    done

    printf "%b\n" "${C_GREEN}${BOLD}$l1${NC}"
    printf "%b\n" "${C_GREEN}${BOLD}$l2${NC}"
    printf "%b\n" "${C_GREEN}${BOLD}$l3${NC}"
    printf "%b\n" "${C_GREEN}${BOLD}$l4${NC}"
}

display_final_grade() {
    local end_time=$(date +%s)
    local elapsed=$((end_time - SESSION_START_TIME))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))

    local penalty_scaled=$(( (MISTAKES_COUNT * 25) + (TIMEOUTS_COUNT * 40) ))
    local total_penalty=$((penalty_scaled / 10))
    local streak_bonus=$((MAX_STREAK / 5))
    [ "$streak_bonus" -gt 6 ] && streak_bonus=6

    local final_grade=$((100 - total_penalty + streak_bonus))
    [ "$final_grade" -lt 0 ] && final_grade=0
    [ "$final_grade" -gt 100 ] && final_grade=100

    clear
    printf "%b\n" "${C_PURPLE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    printf "%b\n" "${C_PURPLE}║${NC}   ${BOLD}${C_CYAN}CCNA DOMAIN 1 (NETWORK FUNDAMENTALS) MASTER EVALUATION AUDIT${NC}         ${C_PURPLE}║${NC}"
    printf "%b\n\n" "${C_PURPLE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"

    printf "%b\n" "${BOLD}${C_BLUE}─── [SYSTEM PERFORMANCE METRICS] ───────────────────────────────────────────${NC}"
    printf "  ${BOLD}%-32s${NC} : ${C_CYAN}100 PTS${NC}\n" "Baseline Score"
    printf "  ${BOLD}%-32s${NC} : %02dm %02ds\n" "Total Simulation Time" "$minutes" "$seconds"
    printf "  ${BOLD}%-32s${NC} : %d incidents (${C_RED}-%d PTS${NC})\n" "Incorrect Decisions (-2.5 ea)" "$MISTAKES_COUNT" "$(( (MISTAKES_COUNT * 25) / 10 ))"
    printf "  ${BOLD}%-32s${NC} : %d expirations (${C_RED}-%d PTS${NC})\n" "Timer Expirations (-4.0 ea)" "$TIMEOUTS_COUNT" "$((TIMEOUTS_COUNT * 4))"
    printf "  ${BOLD}%-32s${NC} : %d flawless streak (${C_GREEN}+%d PTS${NC})\n" "Max Streak Bonus" "$MAX_STREAK" "$streak_bonus"
    printf "%b\n\n" "${BOLD}${C_BLUE}─────────────────────────────────────────────────────────────────────────────${NC}"

    printf "%b\n\n" "${BOLD}FINAL CCNA EVALUATION GRADE:${NC}"
    render_big_grade "$final_grade"
    printf "\n"
}

while true; do
    INTEGRITY=3
    STREAK=0
    CURRENT_CHECKPOINT=1
    SESSION_START_TIME=$(date +%s)
    MISTAKES_COUNT=0
    TIMEOUTS_COUNT=0
    MAX_STREAK=0

    CKPT_MISTAKES=0
    CKPT_TIMEOUTS=0
    CKPT_MAX_STREAK=0
    CKPT_START_TIME=$SESSION_START_TIME

    modules=()
    for ((m=1; m<=60; m++)); do modules+=($m); done

    for ((i = ${#modules[@]} - 1; i > 0; i--)); do
        j=$((RANDOM % (i + 1)))
        tmp=${modules[i]}
        modules[i]=${modules[j]}
        modules[j]=$tmp
    done

    esc_1_pos=10
    esc_2_pos=20
    esc_3_pos=35
    esc_4_pos=45
    esc_5_pos=58

    esc_done_1=false
    esc_done_2=false
    esc_done_3=false
    esc_done_4=false
    esc_done_5=false

    idx=0
    while [ "$idx" -lt "${#modules[@]}" ]; do
        current_num=$((idx + 1))

        if [ "$idx" -ge "$esc_1_pos" ] && [ "$esc_done_1" = false ]; then
            run_apex_escalation_1 "$current_num"
            if [ "$?" -eq 2 ]; then
                printf "\n%b\n" "${C_RED}INTEGRITY COLLAPSE! ROLLING BACK TO CHECKPOINT $CURRENT_CHECKPOINT...${NC}"
                INTEGRITY=3; STREAK=0; idx=$((CURRENT_CHECKPOINT - 1))
                if [ "$CURRENT_CHECKPOINT" -eq 1 ]; then
                    MISTAKES_COUNT=0; TIMEOUTS_COUNT=0; MAX_STREAK=0
                    SESSION_START_TIME=$(date +%s)
                    esc_done_1=false; esc_done_2=false; esc_done_3=false; esc_done_4=false; esc_done_5=false
                else
                    MISTAKES_COUNT=$CKPT_MISTAKES; TIMEOUTS_COUNT=$CKPT_TIMEOUTS; MAX_STREAK=$CKPT_MAX_STREAK
                    SESSION_START_TIME=$CKPT_START_TIME
                fi
                shuffle_remaining_modules "$idx"
                read -rp "Press [ENTER] to resume..."; continue
            fi
            esc_done_1=true
        fi

        if [ "$idx" -ge "$esc_2_pos" ] && [ "$esc_done_2" = false ]; then
            run_apex_escalation_2 "$current_num"
            if [ "$?" -eq 2 ]; then
                printf "\n%b\n" "${C_RED}INTEGRITY COLLAPSE! ROLLING BACK TO CHECKPOINT $CURRENT_CHECKPOINT...${NC}"
                INTEGRITY=3; STREAK=0; idx=$((CURRENT_CHECKPOINT - 1))
                if [ "$CURRENT_CHECKPOINT" -eq 1 ]; then
                    MISTAKES_COUNT=0; TIMEOUTS_COUNT=0; MAX_STREAK=0
                    SESSION_START_TIME=$(date +%s)
                    esc_done_1=false; esc_done_2=false; esc_done_3=false; esc_done_4=false; esc_done_5=false
                else
                    MISTAKES_COUNT=$CKPT_MISTAKES; TIMEOUTS_COUNT=$CKPT_TIMEOUTS; MAX_STREAK=$CKPT_MAX_STREAK
                    SESSION_START_TIME=$CKPT_START_TIME
                fi
                shuffle_remaining_modules "$idx"
                read -rp "Press [ENTER] to resume..."; continue
            fi
            esc_done_2=true
        fi

        if [ "$idx" -ge "$esc_3_pos" ] && [ "$esc_done_3" = false ]; then
            run_apex_escalation_3 "$current_num"
            if [ "$?" -eq 2 ]; then
                printf "\n%b\n" "${C_RED}INTEGRITY COLLAPSE! ROLLING BACK TO CHECKPOINT $CURRENT_CHECKPOINT...${NC}"
                INTEGRITY=3; STREAK=0; idx=$((CURRENT_CHECKPOINT - 1))
                if [ "$CURRENT_CHECKPOINT" -eq 1 ]; then
                    MISTAKES_COUNT=0; TIMEOUTS_COUNT=0; MAX_STREAK=0
                    SESSION_START_TIME=$(date +%s)
                    esc_done_1=false; esc_done_2=false; esc_done_3=false; esc_done_4=false; esc_done_5=false
                else
                    MISTAKES_COUNT=$CKPT_MISTAKES; TIMEOUTS_COUNT=$CKPT_TIMEOUTS; MAX_STREAK=$CKPT_MAX_STREAK
                    SESSION_START_TIME=$CKPT_START_TIME
                fi
                shuffle_remaining_modules "$idx"
                read -rp "Press [ENTER] to resume..."; continue
            fi
            esc_done_3=true
        fi

        if [ "$idx" -ge "$esc_4_pos" ] && [ "$esc_done_4" = false ]; then
            run_apex_escalation_4 "$current_num"
            if [ "$?" -eq 2 ]; then
                printf "\n%b\n" "${C_RED}INTEGRITY COLLAPSE! ROLLING BACK TO CHECKPOINT $CURRENT_CHECKPOINT...${NC}"
                INTEGRITY=3; STREAK=0; idx=$((CURRENT_CHECKPOINT - 1))
                if [ "$CURRENT_CHECKPOINT" -eq 1 ]; then
                    MISTAKES_COUNT=0; TIMEOUTS_COUNT=0; MAX_STREAK=0
                    SESSION_START_TIME=$(date +%s)
                    esc_done_1=false; esc_done_2=false; esc_done_3=false; esc_done_4=false; esc_done_5=false
                else
                    MISTAKES_COUNT=$CKPT_MISTAKES; TIMEOUTS_COUNT=$CKPT_TIMEOUTS; MAX_STREAK=$CKPT_MAX_STREAK
                    SESSION_START_TIME=$CKPT_START_TIME
                fi
                shuffle_remaining_modules "$idx"
                read -rp "Press [ENTER] to resume..."; continue
            fi
            esc_done_4=true
        fi

        if [ "$idx" -ge "$esc_5_pos" ] && [ "$esc_done_5" = false ]; then
            run_apex_escalation_5 "$current_num"
            if [ "$?" -eq 2 ]; then
                printf "\n%b\n" "${C_RED}INTEGRITY COLLAPSE! ROLLING BACK TO CHECKPOINT $CURRENT_CHECKPOINT...${NC}"
                INTEGRITY=3; STREAK=0; idx=$((CURRENT_CHECKPOINT - 1))
                if [ "$CURRENT_CHECKPOINT" -eq 1 ]; then
                    MISTAKES_COUNT=0; TIMEOUTS_COUNT=0; MAX_STREAK=0
                    SESSION_START_TIME=$(date +%s)
                    esc_done_1=false; esc_done_2=false; esc_done_3=false; esc_done_4=false; esc_done_5=false
                else
                    MISTAKES_COUNT=$CKPT_MISTAKES; TIMEOUTS_COUNT=$CKPT_TIMEOUTS; MAX_STREAK=$CKPT_MAX_STREAK
                    SESSION_START_TIME=$CKPT_START_TIME
                fi
                shuffle_remaining_modules "$idx"
                read -rp "Press [ENTER] to resume..."; continue
            fi
            esc_done_5=true
        fi

        m_id=${modules[idx]}
        "module_$m_id" "$current_num"
        if [ "$?" -eq 2 ]; then
            printf "\n%b\n" "${C_RED}INTEGRITY COLLAPSE! ROLLING BACK TO CHECKPOINT $CURRENT_CHECKPOINT...${NC}"
            INTEGRITY=3; STREAK=0; idx=$((CURRENT_CHECKPOINT - 1))
            if [ "$CURRENT_CHECKPOINT" -eq 1 ]; then
                MISTAKES_COUNT=0; TIMEOUTS_COUNT=0; MAX_STREAK=0
                SESSION_START_TIME=$(date +%s)
                esc_done_1=false; esc_done_2=false; esc_done_3=false; esc_done_4=false; esc_done_5=false
            else
                MISTAKES_COUNT=$CKPT_MISTAKES; TIMEOUTS_COUNT=$CKPT_TIMEOUTS; MAX_STREAK=$CKPT_MAX_STREAK
                SESSION_START_TIME=$CKPT_START_TIME
            fi
            shuffle_remaining_modules "$idx"
            read -rp "Press [ENTER] to resume..."; continue
        fi

        idx=$((idx + 1))
    done

    display_final_grade
    read -rp "Press [ENTER] to start a fresh audit run or Ctrl+C to exit..."
done