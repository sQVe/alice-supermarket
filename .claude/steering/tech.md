# Alice Supermarket - Technical Standards

## Technology Stack

### Game Engine

- **Godot Engine 4.x**: Primary development platform
- **GDScript**: Main programming language for game logic
- **Godot Scene System**: For UI and game object management

### Target Platforms

- **Primary**: Android mobile and tablet devices
- **Export**: Android APK via Godot's export system
- **Screen Support**: Various mobile screen sizes and orientations

### Development Environment

- **OS**: Linux (Arch Linux)
- **Editor**: Neovim with LSP integration
- **Version Control**: Git (assumed standard)
- **Godot LSP**: Port 6005 for script editing integration

## Asset Pipeline

### Graphics

- **Source**: Kenney asset library (established style)
- **Format**: PNG for sprites, appropriate Godot import settings
- **Organization**: Assets grouped by category (UI, characters, objects)

### Audio

- **Text-to-Speech**: Built-in or plugin-based TTS for accessibility
- **Languages**: Swedish and English audio support
- **Format**: OGG Vorbis recommended for Godot

## Core Systems Architecture

### Language & Localization

- **Primary Languages**: Swedish and English
- **Text Management**: Godot's translation system
- **Audio Localization**: TTS integration for both languages
- **Fallback**: English as default if Swedish unavailable

### Save System

- **Player Progress**: Persistent skill levels and unlocks
- **Game State**: Shop customization and currency
- **Storage**: Local device storage (Godot's user:// filesystem)
- **Format**: JSON or Godot's built-in save system

### Educational Tracking

- **Skill Progress**: Track learning outcomes per subject
- **Performance Metrics**: Success rates, time spent, accuracy
- **Adaptive Difficulty**: Adjust based on player performance
- **Privacy**: All data stored locally, no external transmission

## Performance Requirements

### Mobile Optimization

- **Target FPS**: 60 FPS on modern devices, 30 FPS minimum
- **Memory**: Efficient texture loading and scene management
- **Battery**: Optimize for extended play sessions
- **Loading Times**: Minimize scene transition delays

### Accessibility

- **Text-to-Speech**: Integrate TTS for all text elements
- **Visual**: High contrast options, scalable UI elements
- **Motor**: Large touch targets, simple gestures
- **Cognitive**: Clear visual hierarchy, consistent interactions

## Code Quality Standards

### Coding Conventions

- **Style**: Follow Godot's official GDScript style guide
- **Naming**: snake_case for variables, PascalCase for classes
- **Documentation**: Inline comments for complex logic
- **Organization**: Clear separation of concerns

### Quality Assurance

- **Automated Testing**: Unit tests for core learning logic
- **Manual Testing**: Regular playtesting with target age group
- **Code Review**: Peer review for significant changes
- **Linting**: Automated formatting and style checking

### Formatting & Linting

- **Tool**: gdformat for automatic code formatting
- **Integration**: Pre-commit hooks for consistency
- **Standards**: Enforce consistent indentation and style
- **Setup**: Configure in development environment

## Security & Privacy

### Data Protection

- **Local Storage**: All user data remains on device
- **No Analytics**: No third-party tracking initially
- **Child Safety**: COPPA compliance for 4-7 year age group
- **Permissions**: Minimal Android permissions required

### Error Handling

- **Graceful Degradation**: Continue play if non-critical systems fail
- **User Feedback**: Clear, age-appropriate error messages
- **Logging**: Development logging without sensitive information
- **Recovery**: Auto-save to prevent progress loss

## Third-Party Integration

### Current Dependencies

- **Kenney Assets**: Game art and UI elements
- **Godot TTS**: Text-to-speech integration (plugin or built-in)

### Future Considerations

- **Analytics**: Consider privacy-focused analytics if needed
- **Cloud Sync**: Optional future feature for multi-device play
- **Content Updates**: Mechanism for adding new learning content

## Development Workflow

### Testing Strategy

- **Automated**: Focus on educational logic and progression systems
- **Manual**: Regular playtesting for user experience
- **Device Testing**: Test on various Android devices and screen sizes
- **Age Group Testing**: Validate with actual 4-7 year old users

### Deployment

- **Build Process**: Automated builds for testing
- **Export Settings**: Optimized Android export configuration
- **Signing**: Proper keystore management for release builds
- **Distribution**: Google Play Store preparation (future)
