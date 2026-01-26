# Architecture Overview

## App Architecture (Menu Bar App)

```
┌─────────────────────────────────────────────────────────────┐
│                      WakeOnLANApp                           │
│                 (@main SwiftUI Entry)                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Creates
                         ▼
                  ┌──────────────┐
                  │ AppDelegate  │
                  │ (NSObject)   │
                  └──────┬───────┘
                         │
              ┌──────────┴──────────────┐
              │                         │
              ▼                         ▼
    ┌──────────────────┐      ┌────────────────┐
    │  NSStatusItem    │      │ TargetManager  │◄────────┐
    │ (Menu Bar Icon)  │      │ @StateObject   │         │
    └────────┬─────────┘      └────────┬───────┘         │
             │                         │                  │
             │ Shows                   │                  │
             ▼                         │                  │
    ┌──────────────────┐              │                  │
    │    NSPopover     │              │                  │
    │   (Menu Bar UI)  │              │                  │
    └────────┬─────────┘              │                  │
             │                         │                  │
             │ Contains                │                  │
             ▼                         │                  │
    ┌──────────────────┐              │                  │
    │MenuBarContentView│◄─────────────┘                  │
    │  (SwiftUI View)  │                                 │
    └────────┬─────────┘                                 │
             │                                            │
             │ Shows List & Controls                     │
             │                                            │
    ┌────────┼────────────────────────┐                  │
    │        │                        │                  │
    ▼        ▼                        ▼                  │
┌─────────┐ ┌──────────┐     ┌────────────────┐         │
│ Target  │ │  Target  │     │ TargetEditor   │─────────┘
│  Row    │ │   Row    │     │     View       │
└────┬────┘ └─────┬────┘     └────────────────┘
     │            │                   │
     │            │                   │
     │ Edit/Wake  │ Delete            │ Add/Update
     │            │                   │
     └────────────┴───────────────────┘
                  │
                  ▼
          ┌──────────────┐
          │  WOLSender   │
          │  (Service)   │
          └──────┬───────┘
                 │
                 │ Sends UDP Packet
                 ▼
          ┌──────────────┐
          │   Network    │
          │  (Magic Pkt) │
          └──────────────┘
```

## Data Flow

### Adding a Target
```
User Input → TargetEditorView → Validation → TargetManager.addTarget()
                                                    ↓
                                              UserDefaults
                                                    ↓
                                            ContentView Update
```

### Sending Magic Packet
```
User Clicks Wake → ContentView → WOLSender.sendMagicPacket()
                                        ↓
                                  Create Magic Packet
                                  (6×0xFF + 16×MAC)
                                        ↓
                                  Calculate Broadcast
                                  (IP & Subnet Mask)
                                        ↓
                                   Send UDP to Port 9
                                        ↓
                                  Network Interface
                                        ↓
                                   Target Device
```

## Key Components

### Application Layer
- **WakeOnLANApp**: SwiftUI app entry point
- **AppDelegate**: NSApplicationDelegate that manages menu bar lifecycle
  - Creates NSStatusItem (menu bar icon)
  - Manages NSPopover for UI display
  - Handles click events

### Models
- **WOLTarget**: Immutable data structure for target devices
  - Stores: name, IP, subnet mask, MAC address
  - Computes: broadcast address, formatted MAC

### Views
- **MenuBarContentView**: Main popover UI with target list
  - Manages: target selection, sheet presentation, alerts
  - Displays: empty state, target list, action buttons
  - Includes: Quit button for menu bar app

- **TargetEditorView**: Modal sheet for add/edit
  - Validates: IP addresses, subnet masks, MAC addresses
  - Handles: form input, error states

- **TargetRow**: Individual target display
  - Shows: device info, action buttons
  - Handles: hover states, inline actions

### Services
- **TargetManager**: State management & persistence
  - CRUD operations for targets
  - UserDefaults integration
  - Observable state updates

- **WOLSender**: Network packet generation
  - MAC address parsing
  - Magic packet creation
  - UDP socket management
  - Broadcast calculation

## Technologies Used

- **SwiftUI**: Modern declarative UI framework
- **AppKit**: NSStatusItem and NSPopover for menu bar integration
- **Combine**: Reactive state management
- **Foundation**: Core data types and persistence
- **BSD Sockets**: Low-level network programming
- **UserDefaults**: Simple key-value persistence

## Design Patterns

1. **Menu Bar App Pattern**
   - NSApplicationDelegate manages lifecycle
   - NSStatusItem provides menu bar presence
   - NSPopover for transient UI display

2. **MVVM (Model-View-ViewModel)**
   - Models: WOLTarget
   - Views: MenuBarContentView, TargetEditorView, TargetRow
   - ViewModels: TargetManager

3. **Repository Pattern**
   - TargetManager acts as repository
   - Abstracts persistence layer

4. **Service Layer**
   - WOLSender provides network services
   - Separated from UI concerns

5. **Dependency Injection**
   - @EnvironmentObject for shared state
   - Testable architecture

## Security Considerations

- No external network requests
- Local-only persistence (UserDefaults)
- No authentication required
- Broadcast packets only
- No sensitive data storage

## Performance Characteristics

- **Memory**: Minimal (<10MB typical)
- **CPU**: Negligible (event-driven)
- **Network**: Single UDP packet per wake
- **Storage**: <1KB per target
- **Launch Time**: Near-instant (native app)

## Future Enhancement Ideas

- Export/import targets (JSON)
- Scheduled wake times
- Ping status checking
- **Quick wake from menu bar** (submenu with target list)
- Multiple subnet support
- AppleScript support
- Global keyboard shortcuts
- Custom port selection
- Wake history log
- Status indicators (online/offline)
- Group organization for targets
- Notification center integration
